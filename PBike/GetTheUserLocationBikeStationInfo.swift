//
//  getTheUserLocationBikeStationInfo.swift
//  PBike
//
//  Created by 陳 冠禎 on 2017/5/8.
//  Copyright © 2017年 陳 冠禎. All rights reserved.
//

import Foundation
import CoreLocation

extension BikeStationsModel {
    
    
    
    func findLocateBikdAPI2Download(userLocation: CLLocationCoordinate2D) {
       
        let latitude = userLocation.latitude.format //(%.2 double)
        let longitude = userLocation.longitude.format
        
        for index in 0..<apis.count {
            
            switch (apis[index].city, latitude, longitude){
            case (.Taipei, 24.96...25.14, 121.44...121.65):
                apis[index].isHere = true
                
                
            case (.NewTaipei, 24.75...25.33, 121.15...121.83):
                apis[index].isHere = true
                
                
            case (.Taoyuan, 24.81...25.11, 120.9...121.4):
                apis[index].isHere = true
                
                
            case (.Hsinchu, 24.67...24.96, 120.81...121.16):
                apis[index].isHere = true
                
                
            case (.Taichung, 24.03...24.35, 120.40...121.00):
                apis[index].isHere = true
                
                
            case (.Changhua, 23.76...24.23, 120.06...120.77):
                apis[index].isHere = true
                
                
            case (.Tainan, 22.72...23.47, 119.94...120.58):
                apis[index].isHere = true
                
                
            case (.Kaohsiung, 22.46...22.73, 120.17...120.44):
                apis[index].isHere = true
                
                
            case (.Pingtung, 22.62...22.71, 120.430...120.53):
                apis[index].isHere = true
                
                
            default:
//                 apis[index].isHere = true
                                break
                //show alart
                
            }
            //            print("set",apis[index].city,"to" ,apis[index].isHere)
        }
    }
    
}
