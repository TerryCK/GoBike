//
//  Extension.swift
//  PBike
//
//  Created by 陳 冠禎 on 2017/2/2.
//  Copyright © 2017年 陳 冠禎. All rights reserved.
//
import UIKit
import SWXMLHash
import Foundation
import CoreLocation


extension Double {
    var km: String { return String(format:"%.1f", self/1000) }
    
    var format: Double { return Double(String(format:"%.2f", self))!  }
    var toRadian: CGFloat { return CGFloat(self * (Double.pi/180)) }
    var percentage: String {  return String(format: "%.1f", self * 100) }
    
    var convertToHMS: String {
        
        let minutes = Int(self.truncatingRemainder(dividingBy: 3600) / 60)
        let hours = Int(self / 3600)
        var result: String = ""
        result += hours > 0 ? "\(hours) 小時 " : ""
        result += "\(minutes + 1) 分鐘 "
        return result
    }
    
}

public extension Int {
    var minLimit: Int {
        return self <= 0 ? 0 : self
    }
    
    var currencyStyle: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumIntegerDigits = 0
        formatter.maximumFractionDigits = 0
        let result = formatter.string(from: self as NSNumber)
        return result!
    }
    
    var convertToHMS: String {
        
        let tempSeconds = self > 0 ? self : self * -1
        let minutes: Int = tempSeconds / 60
        let seconds: Int  = tempSeconds % 60
        let zero: String  = 0...9 ~= seconds ? "0" : ""
        let result: String = "\(minutes):\(zero)\(seconds) "
        
        // unit test 1
        return result
        
    }
}
