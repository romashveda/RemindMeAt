//
//  UIColorExtension.swift
//  RemindMeAt
//
//  Created by Artem Rieznikov on 13.02.18.
//  Copyright © 2018 SoftServe Academy. All rights reserved.
//

import UIKit

@objc extension UIColor {
    /** Hex string of a UIColor instance, fails to empty string. */
    public func hexString() -> String  {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        guard r >= 0 && r <= 1 && g >= 0 && g <= 1 && b >= 0 && b <= 1 else {
            return ""
        }
        
        return String(format: "#%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255))
    }
    
    /**
     The UIColor from Hex string, fails to UIColor.clear
     - parameter hexString: representation of color in String HEX form #RRGGBB
     */
    public static func fromHexString(_ hexString: String) -> UIColor {
        var result = UIColor.clear
        guard hexString.hasPrefix("#") else {
            return result
        }
        
        let hexString: String = String(hexString[String.Index.init(encodedOffset: 1)...])
        var hexValue:  UInt32 = 0
        
        guard Scanner(string: hexString).scanHexInt32(&hexValue) else {
            return result
        }
        
        let divisor = CGFloat(255)
        let red     = CGFloat((hexValue & 0xFF0000) >> 16) / divisor
        let green   = CGFloat((hexValue & 0x00FF00) >>  8) / divisor
        let blue    = CGFloat( hexValue & 0x0000FF       ) / divisor
        result = UIColor(red: red, green: green, blue: blue, alpha: 1)

        return result
    }
    
}
