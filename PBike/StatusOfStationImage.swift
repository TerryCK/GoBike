//
//  File.swift
//  PBike
//
//  Created by 陳 冠禎 on 2017/5/8.
//  Copyright © 2017年 陳 冠禎. All rights reserved.
//


extension BikeStationsModel: BikeAPIDelegate {
    
    func statusOfStationImage(station: [Station], index: Int) -> String {
        var pinImage = ""
        
        if let numberOfBike = station[index].currentBikeNumber {
            
            switch numberOfBike {
            case 1...5:
                pinImage = "pinLess"
                
            case 5...200:
                pinImage = station[index].parkNumber == 0 ? "pinFull" : "pinMed"
                
            case 0:
                pinImage = "pinEmpty"
                
            default:
                pinImage  = "pinUnknow"
                
            }
        }
        return pinImage
    }
}
