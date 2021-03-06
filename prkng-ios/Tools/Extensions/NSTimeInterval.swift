//
//  NSself.swift
//  prkng-ios
//
//  Created by Antonino Urbano on 2015-06-26.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

extension NSTimeInterval {
    
    func toString(condensed condensed: Bool) -> String {
        
        let testFormat = NSDateFormatter.dateFormatFromTemplate("j", options: 0, locale: NSLocale.currentLocale())
        let is24Hour = testFormat?.rangeOfString("a") == nil
        
        if is24Hour {
            let hours = Int((self / 3600))
            let minutes  = Int((self / 60) % 60)
            
            if (minutes != 0) {
                return String(format: "%ldh%02ld", hours, minutes)
            } else {
                return String(format: "%ldh", hours)
            }
            
        } else {
            var amPm = ""
            
            if !condensed {
                amPm = " "
            }
            
            if(self >= 12.0 * 3600.0 && self != 24.0 * 3600.0) {
                amPm += "PM"
            } else {
                amPm += "AM"
            }
            
            var hours = Int((self / 3600))
            hours = hours >= 13 ? hours - 12 : hours
            hours = hours == 0 ? 12 : hours
            let minutes  = Int((self / 60) % 60)
            
            if (minutes != 0) {
                return String(format: "%ld:%02ld%@", hours, minutes, amPm)
            } else {
                return String(format: "%ld%@", hours, amPm)
            }
        }
        
    }
    
    func toAttributedString(condensed condensed: Bool, firstPartFont: UIFont, secondPartFont: UIFont) -> NSAttributedString {
        
        let attrs = [NSFontAttributeName: firstPartFont]
        
        let testFormat = NSDateFormatter.dateFormatFromTemplate("j", options: 0, locale: NSLocale.currentLocale())
        let is24Hour = testFormat?.rangeOfString("a") == nil
        
        if is24Hour {
            var text = ""
            let hours = Int((self / 3600))
            let minutes  = Int((self / 60) % 60)
            
            if (minutes != 0) {
                text = String(format: "%ldh%02ld", hours, minutes)
            } else {
                text =  String(format: "%ldh", hours)
            }
            
            let attrText = NSMutableAttributedString(string: text, attributes: attrs)
            return attrText
            
        } else {
            var amPm = ""
            
            if !condensed {
                amPm = " "
            }
            
            if(self >= 12.0 * 3600.0 && self != 24.0 * 3600.0) {
                amPm += "PM"
            } else {
                amPm += "AM"
            }
            
            let amPmAttrs = [NSFontAttributeName: secondPartFont]
            let amPmAttributed = NSAttributedString(string: amPm, attributes: amPmAttrs)
            
            var text = ""
            var hours = Int((self / 3600))
            hours = hours >= 13 ? hours - 12 : hours
            hours = hours == 0 ? 12 : hours
            let minutes  = Int((self / 60) % 60)
            
            if (minutes != 0) {
                text = String(format: "%ld:%02ld", hours, minutes)
            } else {
                text = String(format: "%ld", hours)
            }
            
            let attrText = NSMutableAttributedString(string: text, attributes: attrs)
            attrText.appendAttributedString(amPmAttributed)
            return attrText
            
        }
        
    }
    
    func untilAttributedString(firstPartFont: UIFont, secondPartFont: UIFont) -> NSAttributedString {
        
        let attributedString = NSMutableAttributedString(string: "until".localizedString + " ", attributes: [NSFontAttributeName: firstPartFont])
        attributedString.appendAttributedString(self.toAttributedString(condensed: true, firstPartFont: firstPartFont, secondPartFont: secondPartFont))
        return attributedString
    }
    
}
