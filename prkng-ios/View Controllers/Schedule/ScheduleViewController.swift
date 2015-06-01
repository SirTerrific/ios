//
//  ScheduleViewController.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 02/04/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

class ScheduleViewController: AbstractViewController, UIScrollViewDelegate {
    
    var spot : ParkingSpot
    var delegate : ScheduleViewControllerDelegate?
    private var scheduleItems : Array<ScheduleItemModel>
    
    private var headerView : ScheduleHeaderView
    private var scrollView : UIScrollView
    private var contentView : UIView
    private var columnViews : Array<ScheduleColumnView>
    private var scheduleItemViews : Array<ScheduleItemView>
    private var dayIndicator : ScheduleDayIndicatorView
    
    private(set) var HEADER_HEIGHT : CGFloat
    private(set) var DAY_INDICATOR_HEIGHT : CGFloat
    private(set) var COLUMN_SIZE : CGFloat
    private(set) var COLUMN_HEADER_HEIGHT : CGFloat
    private(set) var CONTENTVIEW_HEIGHT : CGFloat
    private(set) var ITEM_HOUR_HEIGHT : CGFloat
    
    init(spot : ParkingSpot) {
        self.spot = spot
        headerView = ScheduleHeaderView()
        scrollView = UIScrollView()
        contentView = UIView()
        scheduleItems = []
        columnViews = []
        scheduleItems = []
        scheduleItemViews = []
        dayIndicator = ScheduleDayIndicatorView()
        
        HEADER_HEIGHT = 142.0
        COLUMN_SIZE = UIScreen.mainScreen().bounds.size.width / 3.0
        DAY_INDICATOR_HEIGHT = 50.0
        CONTENTVIEW_HEIGHT = UIScreen.mainScreen().bounds.size.height - HEADER_HEIGHT - DAY_INDICATOR_HEIGHT - 71.0
        COLUMN_HEADER_HEIGHT = 45.0
        ITEM_HOUR_HEIGHT = (CONTENTVIEW_HEIGHT - COLUMN_HEADER_HEIGHT) / 24.0
        
        super.init(nibName: nil, bundle: nil)
        
        for dayAgenda in sortedAgenda() {
            
            var column : Int = 0
            for period in dayAgenda {
                
                if (period != nil) {
                    var startF : CGFloat = CGFloat(period!.start)
                    var endF : CGFloat = CGFloat(period!.end)
                    scheduleItems.append(ScheduleItemModel(startF: startF, endF: endF, column : column, limit: period!.timeLimit ))
                }
                ++column
            }
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = Styles.Colors.stone
        setupViews()
        setupConstraints()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateValues()
    }
    
    override func viewWillLayoutSubviews() {
        
        // forbidden views should be on top
        for column in columnViews {
            for view in column.subviews {
                if let subview =  view as? ScheduleItemView {
                    if(!subview.limited) {
                        column.bringSubviewToFront(subview)
                    }
                }
            }
        }
        
        super.viewWillLayoutSubviews()
    }
    
    func setupViews() {
        scrollView.backgroundColor = Styles.Colors.cream2
        scrollView.delegate = self
        scrollView.showsHorizontalScrollIndicator = false
        self.view.addSubview(scrollView)
        
        self.view.addSubview(headerView)
        headerView.layer.shadowColor = UIColor.blackColor().CGColor
        headerView.layer.shadowOffset = CGSize(width: 0, height: 0.5)
        headerView.layer.shadowOpacity = 0.2
        headerView.layer.shadowRadius = 0.5
        headerView.scheduleButton.addTarget(self, action: "dismiss", forControlEvents: UIControlEvents.TouchUpInside)
        
        scrollView.addSubview(contentView)
        
        for i in 0...6 {
            var columnView : ScheduleColumnView = ScheduleColumnView()
            contentView.addSubview(columnView)
            columnViews.append(columnView)
            columnView.setActive(false)
        }
        
        columnViews[0].setActive(true)
        
        dayIndicator.userInteractionEnabled = false
        view.addSubview(self.dayIndicator)
        
        for scheduleItem in scheduleItems {
            var scheduleItemView : ScheduleItemView = ScheduleItemView(model : scheduleItem)
            columnViews[scheduleItem.columnIndex!].addSubview(scheduleItemView)
            scheduleItemViews.append(scheduleItemView)
        }
        
    }
    
    func setupConstraints () {
        
        headerView.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.view)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.height.equalTo(self.HEADER_HEIGHT)
        }
        
        scrollView.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.headerView.snp_bottom)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.bottom.equalTo(self.view)
        }
        
        contentView.snp_makeConstraints { (make) -> () in
            make.height.equalTo(self.CONTENTVIEW_HEIGHT)
            make.width.equalTo(self.COLUMN_SIZE * 7.0)
            make.edges.equalTo(self.scrollView)
        }
        
        var columnIndex = 0
        for column in columnViews {
            column.snp_makeConstraints({ (make) -> () in
                make.top.equalTo(self.contentView)
                make.bottom.equalTo(self.contentView)
                make.width.equalTo(self.COLUMN_SIZE)
                make.left.equalTo(self.contentView).with.offset(self.COLUMN_SIZE * CGFloat(columnIndex))
            });
            columnIndex++;
        }
        
        var itemIndex = 0
        for itemView in scheduleItemViews {
            
            
            var scheduleItem = scheduleItems[itemIndex]
            
            var columnView = columnViews[scheduleItem.columnIndex!]
            
            itemView.snp_makeConstraints({ (make) -> () in
                make.top.equalTo(columnView).with.offset((self.ITEM_HOUR_HEIGHT * scheduleItem.yIndexMultiplier!) + self.COLUMN_HEADER_HEIGHT)
                make.height.equalTo(self.ITEM_HOUR_HEIGHT * scheduleItem.heightMultiplier!)
                make.left.equalTo(columnView)
                make.right.equalTo(columnView)
            })
            
            itemIndex++;
        }
        
        dayIndicator.snp_makeConstraints { (make) -> () in
            make.bottom.equalTo(self.view)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.height.equalTo(self.DAY_INDICATOR_HEIGHT)
        }
        // items
    }
    
    func updateValues () {
        headerView.titleLabel.text = spot.name
        dayIndicator.setDays(sortedDays())
        
        var columnTitles = sortedColumnTitles()
        var index = 0
        for columnView in columnViews {
            columnView.setTitle(columnTitles[index++])
        }
    }
    
    // UIScrollViewDelegate
    
    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        var kMaxIndex : CGFloat  = 7
        
        var targetX : CGFloat = scrollView.contentOffset.x + velocity.x * 60.0
        var targetIndex : CGFloat = round(targetX / COLUMN_SIZE)
        if (targetIndex < 0) {
            targetIndex = 0
        }
        if (targetIndex > kMaxIndex) {
            targetIndex = kMaxIndex;
        }
        
        targetContentOffset.memory.x = targetIndex * (self.view.frame.size.width / 3.0)
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        var maxOffset : Float = Float(COLUMN_SIZE * 4.0)
        var ratio : Float = 0.0
        
        if (scrollView.contentOffset.x != 0) {
            ratio = Float(scrollView.contentOffset.x) / maxOffset
        }
        
        self.dayIndicator.setPositionRatio(CGFloat(ratio))
        
    }
    
    
    func dismiss () {
        self.delegate!.hideScheduleView()
    }
    
    
    // Helper
    
    func sortedDays() -> Array<String> {
        var array : Array<String> = []
        
        var days : Array<String> = []
        
        days.append("monday".localizedString.uppercaseString[0])
        days.append("tuesday".localizedString.uppercaseString[0])
        days.append("wednesday".localizedString.uppercaseString[0])
        days.append("thursday".localizedString.uppercaseString[0])
        days.append("friday".localizedString.uppercaseString[0])
        days.append("saturday".localizedString.uppercaseString[0])
        days.append("sunday".localizedString.uppercaseString[0])
        
        let today = DateUtil.dayIndexOfTheWeek()
        
        for var i = today; i < 7; ++i {
            array.append(days[i])
        }
        
        for var j = 0; j < today; ++j {
            array.append(days[j])
        }
        
        
        return array
    }
    
    
    func sortedAgenda() -> Array<Array<TimePeriod?>>{
        var array : Array<Array<TimePeriod?>> = []
        
        let today = DateUtil.dayIndexOfTheWeek()
        
        for r in 0...(spot.rules.count - 1) {
            
            var dayArray : Array<TimePeriod?> = []
            
            for var i = today; i < 7; ++i {
                dayArray.append(spot.rules[r].agenda[i])
            }
            
            for var j = 0; j < today; ++j {
                dayArray.append(spot.rules[r].agenda[j])
            }
            
            array.append(dayArray)
        }
        
        return array
    }
    
    func sortedColumnTitles() -> Array<String> {
        var array : Array<String> = []
        
        var days : Array<String> = []
        
        days.append("monday".localizedString.uppercaseString[0...2])
        days.append("tuesday".localizedString.uppercaseString[0...2])
        days.append("wednesday".localizedString.uppercaseString[0...2])
        days.append("thursday".localizedString.uppercaseString[0...2])
        days.append("friday".localizedString.uppercaseString[0...2])
        days.append("saturday".localizedString.uppercaseString[0...2])
        days.append("sunday".localizedString.uppercaseString[0...2])
        
        let today = DateUtil.dayIndexOfTheWeek()
        
        for var i = today; i < 7; ++i {
            array.append(days[i])
        }
        
        for var j = 0; j < today; ++j {
            array.append(days[j])
        }
        
        array[0] = "today".localizedString.uppercaseString
        
        return array
    }
    
    
}



class ScheduleItemModel {
    
    var startTime : String?
    var startTimeAmPm : String?
    var endTime : String?
    var endTimeAmPm : String?
    
    var heightMultiplier : CGFloat?
    var yIndexMultiplier : CGFloat?
    
    var columnIndex : Int?
    
    var timeLimitText : String?
    
    init (startF : CGFloat, endF : CGFloat, column : Int, limit: NSTimeInterval) {
        
        columnIndex = column
        
        heightMultiplier = (endF - startF) / 3600
        yIndexMultiplier = startF / 3600
        
        if(heightMultiplier < 4) {
            heightMultiplier = 4
        }
        
    
        var startTm = startF
        if(startF >= 13.0 * 3600.0) {
            startTimeAmPm = "PM"
            startTm = startF - (12 * 3600.0)
        } else {
            startTimeAmPm = "AM"
        }
        let startHours = Int((startTm / 3600))
        let startMinutes  = Int((startTm / 60) % 60)
        startTime =  String(NSString(format: "%02ld:%02ld", startHours, startMinutes))
        
        
        var endTm = endF
        if(endF >= 13 * 3600.0) {
            endTimeAmPm = "PM"
            endTm = endTm - (12 * 3600.0)
        } else {
            endTimeAmPm = "AM"
        }
        
        
        let endHours = Int((endTm / 3600))
        let endMinutes  = Int((endTm / 60) % 60)
        endTime =  String(NSString(format: "%02ld:%02ld", endHours, endMinutes))
        
        
        if (limit > 0) {
            let limitHours = Int((limit / 3600))
            let limitMinutes  = Int((limit / 60) % 60)
            timeLimitText =  String(NSString(format: "%01ld:%02ld", limitHours, limitMinutes))
        }
    }
    
    
}


protocol ScheduleViewControllerDelegate {
    func hideScheduleView()
}
