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
     static func getImage(by station: Station) -> UIImage
}

enum StationStatus: String, ImageSetable {
    case less   =  "pinLess"
    case med    =  "pinMed"
    case full   =  "pinFull"
    case empty  =  "pinEmpty"
    case unknow =  "pinUnknow"

    
    static func getImage(by station: Station) -> UIImage {
        var pinImage = self.unknow
        
        guard let numberOfBike = station.bikeOnSite else {
            return #imageLiteral(resourceName: "pinUnknow")
        }

        switch numberOfBike {

        case 1...5:
            pinImage = .less
        case 5...200:
            pinImage = station.slot == 0 ? self.full : self.med
        case 0:
            pinImage = .empty
        default:
            pinImage  = .unknow
        }
        
        return UIImage(named: pinImage.rawValue) ?? #imageLiteral(resourceName: "pinUnknow")
    }
}
