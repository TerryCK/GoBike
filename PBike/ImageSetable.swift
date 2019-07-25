//
//  StationStatus
//  GoBike
//
//  Refactoring by 陳 冠禎 on 2017/6/8.
//  Modified by    陳 冠禎 on 2017/6/17.
//  Copyright © 2017年 陳 冠禎. All rights reserved.
//

import UIKit

protocol ImageSetable {
     static func status(by station: Station) -> Self
}

enum StationStatus: String, ImageSetable {
    case less   =  "pinLess"
    case med    =  "pinMed"
    case full   =  "pinFull"
    case empty  =  "pinEmpty"
    case unknow =  "pinUnknow"

    static func status(by station: Station) -> StationStatus {
        switch station.bikeOnSite {
        case .some(1...5)      : return .less
        case .some(5...200)    : return station.slot == 0 ? full : med
        case .some(0)          : return .empty
        default          : return .unknow
        }
    }
    
    var image: UIImage {
        return UIImage(named: rawValue) ?? #imageLiteral(resourceName: "pinUnknow")
    }
}
