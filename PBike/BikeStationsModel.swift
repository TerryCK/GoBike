//
//  BikeStationInfo.swift
//  PBike
//
//  Created by 陳 冠禎 on 2016/10/16.
//  Copyright © 2016年 陳 冠禎. All rights reserved.
//

import Kanna
import Alamofire
import SWXMLHash
import Foundation
import SwiftyJSON
import CoreLocation

typealias DownloadComplete = () -> ()

final class BikeStationsModel: BikeModelProtocol, Parsable {
    
    var stations: [Station] { return _stations }
    var countOfAPIs = 0
    var netWorkDataSize = 0
    var citys: [City] = []
    var bikeApis = BikeStationAPI().APIs
    private var _stations: [Station] = []
    
    func getData(completed: @escaping DownloadComplete) {
        
        self._stations.removeAll()
        countOfAPIs = 0
        citys.removeAll()
        
        //        var stations = [Station]()
        
        for api in bikeApis {
            guard api.isHere else { continue }
            
            self.countOfAPIs += 1
            
            citys.append(api.city)
            
            let url = api.city.rawValue
            
            guard let apiURL = URL(string: url) else { return }
            let city = api.city
            
            switch api.dataType {
                
            case .xml, .html:
                
                Alamofire.request(apiURL).responseString { response in
                    guard response.result.isSuccess else { return }
                    
                    let dataSize = response.data! as NSData
                    self.netWorkDataSize += (dataSize.length)
                    
                    
                    if api.dataType == .html {
                        guard let html = response.result.value,
                            let stations = self.parse(city: city, dataFormat: html) else {
                                print("error: BikeStationsModel .html " )
                                return
                        }
                        
                        self._stations.append(contentsOf: stations)
                        
                        
                    } else {
                        guard let xmlToParse = response.result.value else {
                            print("error, can't unwrap response data")
                            return
                        }
                        
                        let xml = SWXMLHash.parse(xmlToParse)
                        
                        do {
                            guard let stationsXML:[Station] = try xml["BIKEStationData"]["BIKEStation"]["Station"].value(),
                                let stations:[Station] = self.parse(city: city, dataFormat: stationsXML) else { return }
                            
                            self._stations.append(contentsOf: stations)
                            
                        } catch {
                            print("xml parse error:", error)
                        }
                    }
                    completed()  // main
                }
                
            case .json:
                
                Alamofire.request(apiURL).validate().responseJSON { [unowned self] response in
                    let dataSize = response.data! as NSData
                    self.netWorkDataSize += (dataSize.length)
                    
                    switch response.result {
                    case .success(let value):
                        
                        let json = JSON(value)
                        guard let stations:[Station] = self.parse(city: city, dataFormat: json) else {
                            print("station is nil plz check parseJson")
                            return
                        }
                        self._stations.append(contentsOf: stations)
                        completed()
                        
                    case .failure(let error):
                        print("JSON parse error:", error)
                    }
                }//Alamofire
            } // switch
        }//for lop
    }
}








