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

public extension String {
    
    //right is the first encountered string after left
    func between(_ left: String, _ right: String) -> String? {
        guard let leftRange = range(of: left), let rightRange = range(of: right, options: .backwards)
            , left != right && leftRange.upperBound < rightRange.lowerBound
            else { return nil }
        
        let sub = self.substring(from: leftRange.upperBound)
        let closestToLeftRange = sub.range(of: right)!
        return sub.substring(to: closestToLeftRange.lowerBound)
    }
    
    var length: Int {
        get {
            return self.characters.count
        }
    }
    
    func substring(to : Int) -> String? {
        if (to >= length) {
            return nil
        }
        let toIndex = self.index(self.startIndex, offsetBy: to)
        return self.substring(to: toIndex)
    }
    
    func substring(from : Int) -> String? {
        if (from >= length) {
            return nil
        }
        let fromIndex = self.index(self.startIndex, offsetBy: from)
        return self.substring(from: fromIndex)
    }
    
    func substring(_ r: Range<Int>) -> String {
        let fromIndex = self.index(self.startIndex, offsetBy: r.lowerBound)
        let toIndex = self.index(self.startIndex, offsetBy: r.upperBound)
        return self.substring(with: Range<String.Index>(uncheckedBounds: (lower: fromIndex, upper: toIndex)))
    }
    
    func character(_ at: Int) -> Character {
        return self[self.index(self.startIndex, offsetBy: at)]
    }
    // url encode
    var urlEncode:String? {
        return self.addingPercentEncoding(withAllowedCharacters: NSCharacterSet(charactersIn: "!*'\\\\\"();:@&=+$,/?%#[]% ").inverted)
    }
    // url decode
    var urlDecode: String? {
        return self.removingPercentEncoding
    }
}

extension Double {
    var km: String {
        return String(format:"%.1f", self/1000) }
    
    var format: Double {
        return Double(String(format:"%.2f", self))!
    }
    var toRadian: CGFloat {
        get { return CGFloat(self * (Double.pi/180))
        }
    }
    
}

public extension Int {
    var minLimit:Int {
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

extension BikeStationsModel {
    func enumerate(indexer: XMLIndexer, level: Int) {
        for child in indexer.children {
            let name = child.element!.name
            print("\(level) \(name)")
            enumerate(indexer: child, level: level + 1)
        }
    }
}


        
  
