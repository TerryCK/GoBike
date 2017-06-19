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
    func downloadData(from apis:[API]) -> [Station]
    func downloadData(from apis:[API], completed: @escaping downlocatCompleted)
}

extension Downloadable {
    func downloadData(from apis:[API], completed: @escaping downlocatCompleted) {
     var stations = [Station]()
        for api in apis {
            let url = api.city.rawValue
            let newStations = getData(from: api, with: url)
            stations.append(contentsOf: newStations)

        }
        
    }
    
    func downloadData(from apis:[API]) -> [Station] {
        var stations = [Station]()
        for api in apis {
            let url = api.city.rawValue
            let newStations = getData(from: api, with: url)
            stations.append(contentsOf: newStations)
        }
        return stations
    }
    
    private func getData(from api: API, with url: String) -> [Station] {
        let isJSON:Bool = api.dataType == .json ? true : false
        let stations = isJSON ? getJSONStation(from: api, with: url) : getXMLStation(from: api, with: url)
        return stations
    }
    
    
    private func getXMLData(data: String) -> [Station]? {
        let xml = SWXMLHash.parse(data)
        guard let data:[Station] = try? xml["BIKEStationData"]["BIKEStation"]["Station"].value() else { return nil }
        return data
    }
    
    
    private func getXMLStation(from api: API , with url: String) -> [Station] {
        var stations = [Station]()
        
        Alamofire.request(url).responseString {  response in
            
            guard response.result.isSuccess else { return }
            guard let data = response.result.value else { return }
            let isXML: Bool = api.dataType == .xml ? true : false
            if isXML {
                guard let data = self.getXMLData(data: data),
                    let parsed = self.parse(city: api.city, dataFormat: data) else { return }
                stations.append(contentsOf: parsed)
                
            } else {
                guard let parsed = self.parse(city: api.city, dataFormat: data) else { return }
                stations.append(contentsOf: parsed)
            }
        }
        return stations
    }
    
    
    
    
    private func getJSONStation(from api: API , with url: String) -> [Station] {
        
        var stations = [Station]()
        
        Alamofire.request(url).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                guard let parsed:[Station] = self.parse(city: api.city, dataFormat: json) else {
                    print("station is nil plz check parseJSON")
                    return
                }
                stations.append(contentsOf: parsed)
            case .failure(let error):
                print("JSON parse error:", error)
            }
            
             print("(內)Stations:", stations)
        }
        
        print("(外)Stations:", stations)   // 不會執行
        return stations
    }
    
}
