//
//  downloadableProtocol.swift
//  PBike
//
//  Created by 陳 冠禎 on 2017/6/17.
//  Copyright © 2017年 陳 冠禎. All rights reserved.
//


import Alamofire
import SWXMLHash
import SwiftyJSON

typealias downlocatCompleted = ([Station]) -> ()

protocol Downloadable: Parsable {
    func downloadData(from apis:[API], completed: @escaping completeHandle)
}


extension Downloadable {
    func downloadData(from apis:[API], completed: @escaping completeHandle) {
        var stations = [Station]()
        var counter = 1
        
        for api in apis {
            let url = api.city.rawValue
            
            getData(from: api, with: url) { (newStations) in
                
                stations.append(contentsOf: newStations)
                if counter == apis.count {
                    completed(stations, apis)
                }  else {
                    counter += 1
                }
            }
        }
    }
    
    private func getData(from api: API, with url: String, completed: @escaping downlocatCompleted) {
        let isJSON:Bool = api.dataType == .json ? true : false
        if isJSON {
            getJSONStation(from: api, with: url) { (stations) in completed(stations) }
        } else {
            getXMLStation(from: api, with: url) { (stations) in completed(stations) }
        }
    }
    
    
    private func getXMLData(data: String) -> [Station]? {
        let xml = SWXMLHash.parse(data)
        guard let data:[Station] = try? xml["BIKEStationData"]["BIKEStation"]["Station"].value() else { return nil }
        return data
    }
    
    
    private func getXMLStation(from api: API , with url: String, completed: @escaping downlocatCompleted){
        Alamofire.request(url).responseString {  response in
            guard response.result.isSuccess else { return }
            guard let data = response.result.value else { return }
            let isXML: Bool = api.dataType == .xml ? true : false
            if isXML {
                guard let data = self.getXMLData(data: data),
                    let parsed = self.parse(city: api.city, dataFormat: data) else { return }
                completed(parsed)
            } else {
                guard let parsed = self.parse(city: api.city, dataFormat: data) else { return }
                completed(parsed)
            }
        }
    }
    
    
    
    
    private func getJSONStation(from api: API , with url: String, completed: @escaping downlocatCompleted) {
        Alamofire.request(url).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                guard let parsed:[Station] = self.parse(city: api.city, dataFormat: json) else {
                    print("station is nil plz check parseJSON")
                    return
                }
                
                completed(parsed)
                
            case .failure(let error):
                print("JSON parse error:", error)
            }
        }
    }
    
}
