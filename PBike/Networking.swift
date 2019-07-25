//
//  downloadableProtocol.swift
//  Rename Networking.swift  2017/6/27
//  GoBike
//
//  Created by 陳 冠禎 on 2017/6/17.
//  Add feature world API provide by "https://api.citybik.es/"
//
//  Copyright © 2017年 陳 冠禎. All rights reserved.
//

import Alamofire
import SWXMLHash
import SwiftyJSON

typealias downlocatCompleted = ([Station]) -> Void

protocol Downloadable: Parsable, WorldAPIGetable {
    func downloadData(from apis: [API], completed: @escaping completeHandle)
}

extension Downloadable {
    
    func downloadData(from apis: [API], completed: @escaping completeHandle) {
        var stations = [Station]()
        var counter = 1
        
        apis.forEach { (city) in
            getData(from: city, with: city.api) { (newStations) in
                stations.append(contentsOf: newStations)
                if counter == apis.count {
                    completed(stations, apis)
                } else {
                    counter += 1
                }
            }
        }
    }
    
    private func getData(from api: API, with url: String, completed: @escaping downlocatCompleted) {
        let isJSON: Bool = api.dataType == .json ? true : false
        
        if isJSON {
            getJSONStation(from: api, with: url, completed: completed)
        } else {
            getXMLStation(from: api, with: url, completed: completed)
        }
    }
    
    private func getXMLStation(from api: API, with url: String, completed: @escaping downlocatCompleted) {
        
        Alamofire.request(url).responseString {  response in
            guard response.result.isSuccess,
                let data = response.result.value else {
                    return
            }
            
            let isXML: Bool = api.dataType == .xml ? true : false
            
            if isXML {
                if let data = getXMLData(data: data),
                    let parsed = self.parse(city: api.city, dataFormat: data){
                    completed(parsed)
                }
            }
//            else {
//
//                if let parsed = self.parse(city: api.city, dataFormat: data) {
//                    completed(parsed)
//                }
//            }
        }
        
        
        func getXMLData(data: String) -> [Station]? {
            let xml = SWXMLHash.parse(data)
            return try? xml["BIKEStationData"]["BIKEStation"]["Station"].value()
        }
        
    }
    
    private func getJSONStation(from api: API, with url: String, completed: @escaping downlocatCompleted) {
        print("url", url)
        Alamofire.request(url).validate().responseJSON { response in
            switch response.result {
                
            case .success(let value):
                let json = JSON(value)
                
                if let parsed = self.parse(city: api.city, dataFormat: json)  {
                    completed(parsed)
                }
                
            case .failure(let error):
                print("JSON parse error:", error)
            }
        }
    }
}

extension WorldAPIGetable {
    
    func getWorldsAPIs(url: String, completed: @escaping (([API]) -> Void)) {
        Alamofire.request(url).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                let parsed = self.parse(url: url, dataFormat: json)
                let result = self.getAPIs(from: parsed)
                
                completed(result)
                
            case .failure(let error):
                print("JSON parse error:", error)
            }
        }
    }
    
    private func getAPIs(from worlds: [World]) -> [API] {
        var results = [API]()
        for world in worlds {
            
            let prefix = "https://api.citybik.es/"
            let endpoint = world.href
            let api = prefix + endpoint
            let obj = API(city: .worlds, dataType: .json, api: api)
            results.append(obj)
        }
        return results
    }
    
}
