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
    static func getImage(by station: [Station], at index: Int) -> String

}

enum StationStatus: String, ImageSetable {
    case less   =  "pinLess"
    case med    =  "pinMed"
    case full   =  "pinFull"
    case empty  =  "pinEmpty"
    case unknow =  "pinUnknow"

    
    static func getImage(by station: [Station], at index: Int) -> String {
        var pinImage = self.unknow
        
        guard let numberOfBike = station[index].bikeOnSite else {
            return pinImage.rawValue
        }

        switch numberOfBike {

        case 1...5:
            pinImage = .less
        case 5...200:
            pinImage = station[index].slot == 0 ? self.full : self.med
        case 0:
            pinImage = .empty
        default:
            pinImage  = .unknow
        }
        return pinImage.rawValue
    }
}
