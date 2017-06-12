//
//  File.swift
//  GoBike
//
//  Refactoring by 陳 冠禎 on 2017/6/8.
//  Copyright © 2017年 陳 冠禎. All rights reserved.
//

enum BikeStationStatus: String {
    case less   =  "pinLess"
    case med    =  "pinMed"
    case full   =  "pinFull"
    case empty  =  "pinEmpty"
    case unknow =  "pinUnknow"
}


extension BikeModelProtocol {
    
    static func getStatusImage(from station: [Station], at index: Int) -> String {
        
        var pinImage  = BikeStationStatus.unknow
        
        guard let numberOfBike = station[index].bikeOnSite else { return pinImage.rawValue }
        switch numberOfBike {
        case 1...5:
            pinImage = .less
        case 5...200:
            pinImage = station[index].slot == 0 ? BikeStationStatus.full : BikeStationStatus.med
        case 0:
            pinImage = .empty
        default:
            pinImage  = .unknow
        }
        return pinImage.rawValue
    }
    
}
