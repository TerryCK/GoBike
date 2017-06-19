//
//  getTheUserLocationBikeStationInfo.swift
//  PBike
//
//  Created by 陳 冠禎 on 2017/5/8.
//  Copyright © 2017年 陳 冠禎. All rights reserved.
//

import CoreLocation

//extension BikeStationsModel {

//     func getAPIFrom(userLocation: CLLocationCoordinate2D) {
//        let latitude = userLocation.latitude
//        let longitude = userLocation.longitude
//        print("userLocation", userLocation)
//        for index in 0..<bikeApis.count {
//
//            switch (bikeApis[index].city, latitude, longitude) {
//            case (.taipei, 24.96...25.14, 121.44...121.65):
//                bikeApis[index].isHere = true
//            case (.newTaipei, 24.75...25.33, 121.15...121.83):
//                bikeApis[index].isHere = true
//            case (.taoyuan, 24.81...25.11, 120.9...121.4):
//                bikeApis[index].isHere = true
//            case (.hsinchu, 24.67...24.96, 120.81...121.16):
//                bikeApis[index].isHere = true
//            case (.taichung, 24.03...24.35, 120.40...121.00):
//                bikeApis[index].isHere = true
//            case (.changhua, 23.76...24.23, 120.06...120.77):
//                bikeApis[index].isHere = true
//            case (.tainan, 22.72...23.47, 119.94...120.58):
//                bikeApis[index].isHere = true
//            case (.kaohsiung, 22.46...22.73, 120.17...120.44):
//                bikeApis[index].isHere = true
//            case (.pingtung, 22.62...22.71, 120.430...120.53):
//                bikeApis[index].isHere = true
//            default:
////                 bikeApis[index].isHere = true
//                                break
//            }
//        }
//    }
//}





//extension BikeStationsModel {
//
//    func getAPIBy(userLocation: CLLocationCoordinate2D) -> [City] {
//        let latitude = userLocation.latitude
//        let longitude = userLocation.longitude
//        var citys = [City]()
//        switch (latitude, longitude) {
//        case (24.96...25.14, 121.44...121.65):
//            citys.append(.taipei)
//        case (24.75...25.33, 121.15...121.83):
//            citys.append(.newTaipei)
//        case (24.81...25.11, 120.9...121.4):
//            citys.append(.taoyuan)
//        case (24.67...24.96, 120.81...121.16):
//            citys.append(.hsinchu)
//        case (24.03...24.35, 120.40...121.00):
//            citys.append(.taichung)
//        case (23.76...24.23, 120.06...120.77):
//            citys.append(.changhua)
//        case (22.72...23.47, 119.94...120.58):
//            citys.append(.tainan)
//        case (22.46...22.73, 120.17...120.44):
//            citys.append(.kaohsiung)
//        case (22.62...22.71, 120.430...120.53):
//            citys.append(.pingtung)
//        default:
//            //                 bikeApis[index].isHere = true
//            break
//        }
//        return citys
//    }
//}

