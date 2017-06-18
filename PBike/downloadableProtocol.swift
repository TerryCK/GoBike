//
//  downloadableProtocol.swift
//  PBike
//
//  Created by 陳 冠禎 on 2017/6/17.
//  Copyright © 2017年 陳 冠禎. All rights reserved.
//

import Foundation
import SWXMLHash
import Alamofire
import SwiftyJSON

protocol Downloadable: Parsable {
    func getStations(from apis:[API], completeHandler: @escaping () -> [Station])
}

extension Downloadable {
    
    func getStations(from apis:[API], completeHandler: @escaping ([Station]) -> Void) {
        var stations = [Station]()
        for api in apis {
            let url = api.city.rawValue
            let newStations = getData(api , url)
            stations.append(contentsOf: newStations)
        }
        completeHandler(stations)
    }
    
    private func getData(_ api: API, _ url: String) -> [Station] {
        let isJSON:Bool = api.dataType == .json ? true : false
        var stations = [Station]()
        if isJSON {
            stations = getJSONStation(from: api, with: url)
        } else {
            stations = getXMLStation(from: api, with: url)
        }
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
                stations = parsed
            } else {
                guard let parsed = self.parse(city: api.city, dataFormat: data) else { return }
                stations = parsed
            }
        }
        return stations
    }
    
    
    private func getJSONStation(from api: API , with url: String) -> [Station] {
        var stations  = [Station]()
        Alamofire.request(url).validate().responseJSON {  response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                guard let parsed:[Station] = self.parse(city: api.city, dataFormat: json) else {
                    print("station is nil plz check parseJson")
                    return
                }
                stations = parsed
            case .failure(let error):
                print("JSON parse error:", error)
            }
        }
        return stations
    }
}
