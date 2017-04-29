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

protocol BikeStationDelegate {
    
    var  citys: [String] { get }
    var  stations: [Station] { get }
    var  countOfAPIs:Int { get }
    func downloadInfoOfBikeFromAPI(completed:@escaping DownloadComplete)
    func statusOfStationImage(station:[Station], index:Int) -> String
    func findLocateBikdAPI2Download(userLocation: CLLocationCoordinate2D)
    
}


class BikeStation:BikeStationDelegate {
    
    internal var stations: [Station] {
        return _stations
    }
    
    internal var countOfAPIs = 0
    var netWorkDataSize = 0
    var Bike_URL = "http://pbike.pthg.gov.tw/xml/stationlist.aspx"
    var citys: [String] = []
    var longitude = ""
    var lativtude = ""
    var _stations: [Station] = []
    var apis = Bike().apis
    
    func downloadInfoOfBikeFromAPI(completed:@escaping DownloadComplete) {
        //Alamofire download
        
        #if CityBike
            
            self.Bike_URL = "http://www.c-bike.com.tw/xml/stationlistopendata.aspx"
            
            self.bikeOnService = 2500
            print("*****************\n")
            print("CityBike Version")
            print("\n*****************")
            
        #elseif PBike
            
            self.Bike_URL = "http://pbike.pthg.gov.tw/xml/stationlist.aspx"
            self.bikeOnService = 500
            print("*****************\n")
            print("PBike Version")
            print("\n*****************")
            
        #elseif GoBike
            
            
            print("*****************\n")
            print("GoBike Version")
            print("\n*****************")
            
        #endif
        
        
        self._stations.removeAll()
        countOfAPIs = 0
        
        citys.removeAll() //inital
        
        for api in apis {
            
            guard api.isHere else {
                continue
            }
            
            self.countOfAPIs += 1
            citys.append(api.city)
            print("User in here: \(api.city)", self.countOfAPIs)
            guard let currentBikeURL = URL(string: api.url) else {
                print("URL error")
                return
            }
            
            switch api.dataType {
            case .XML, .html:
                Alamofire.request(currentBikeURL).responseString { response in
                    print("資料來源: \(response.request!)\n 伺服器傳輸量: \(response.data!)\n")
                    guard response.result.isSuccess else {
                        print("response is failed")
                        return
                    }
                    
                    let dataSize = response.data! as NSData
                    self.netWorkDataSize += (dataSize.length)
                    print("netWorkDataSize", self.netWorkDataSize.currencyStyle, "bytes")
                    
                    // html
                    if api.dataType == .html {
                        if let html = response.result.value {
                            self.parseHTML(city: api.city,html: html)
                        } else {
                            print("Can not parseHTML, please check parseHTML func" )
                        }
                    }
                        
                        // xml
                    else {
                        guard let xmlToParse = response.result.value else {
                            print("error, can't unwrap response data")
                            return
                        }
                        let xml = SWXMLHash.parse(xmlToParse)
                        do {
                            guard let stationsXML:[StationXML] = try xml["BIKEStationData"]["BIKEStation"]["Station"].value() else {
                                return
                            }
                            let stations:[Station] = self.xmlToStation(key:api.city ,stations: stationsXML)
                            self._stations.append(contentsOf: stations)
                       
                        } catch {
                            print("xml parse error:", error)
                        }
                    }
                    completed() // main
                }
                
            case .JSON:
                Alamofire.request(currentBikeURL).validate().responseJSON { response in
                    print("資料來源: \(response.request!)\n 伺服器傳輸量: \(response.data!)\n")
                    print("success", api.city)
                    let dataSize = response.data! as NSData
                    self.netWorkDataSize += (dataSize.length)
                    print("netWorkDataSize", self.netWorkDataSize.currencyStyle, "bytes")
                    
                    switch response.result {
                    case .success(let value):
                        
                        let json = JSON(value)
                        guard let stations:[Station] = self.parseJSON2Object(api.city, json: json) else {
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
