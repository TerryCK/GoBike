////
////  Model.swift
////  PBike
////
////  Created by 陳 冠禎 on 2017/5/22.
////  Copyright © 2017年 陳 冠禎. All rights reserved.
////
//
import CoreLocation

typealias completeHandle = ([Station], [API]) -> ()

protocol BikeStationModelProtocol: Downloadable {
    func getStations(userLocation: CLLocationCoordinate2D, completed: @escaping completeHandle)
    
    func getCitys(userLocation: CLLocationCoordinate2D) -> [City]
    func getAPIs(from citys: [City]) -> [API]
    func getStations(from API: String) -> [Station]
    
}

extension BikeStationModelProtocol {
    
    func getStations(userLocation: CLLocationCoordinate2D, completed: @escaping completeHandle) {
        let citys = getCitys(userLocation: userLocation)
        let apis = getAPIs(from: citys)
        
        downloadData(from: apis) { (stations, apis) in
            completed(stations, apis)
        }
    }
}

extension BikeStationModelProtocol {
    fileprivate func getCitys(userLocation: CLLocationCoordinate2D) -> [City] {
        let isDebugMod: Bool = true
        let latitude = userLocation.latitude
        let longitude = userLocation.longitude
        var citys = [City]()
        switch (latitude, longitude) {
            
        case (24.96...25.14, 121.44...121.65):
            citys.append(.taipei)
        case (24.75...25.33, 121.15...121.83):
            citys.append(.newTaipei)
        case (24.81...25.11, 120.9...121.4):
            citys.append(.taoyuan)
        case (24.67...24.96, 120.81...121.16):
            citys.append(.hsinchu)
        case (24.03...24.35, 120.40...121.00):
            citys.append(.taichung)
        case (23.76...24.23, 120.06...120.77):
            citys.append(.changhua)
        case (22.72...23.47, 119.94...120.58):
            citys.append(.tainan)
        case (22.46...22.73, 120.17...120.44):
            citys.append(.kaohsiung)
        case (22.62...22.71, 120.430...120.53):
            citys.append(.pingtung)
        default:
            break
        }
        
        if isDebugMod {
            let testAPI: [City] = [.taipei, .newTaipei, .changhua, .taoyuan, .hsinchu, .pingtung, .kaohsiung, .taichung, .tainan]
            citys = testAPI
            print("\n** Is Debug Mode !! **\n")
        }
        
        print("citys:\n", citys , "\n")
        return citys
    }
    
    fileprivate func getAPIs(from citys: [City]) -> [API] {
        var apis = [API]()
        let dic = BikeStationAPI().APIs
        for city in citys {
            if let api = dic[city] {
                apis.append(api)
            }
        }
        return apis
    }
}
