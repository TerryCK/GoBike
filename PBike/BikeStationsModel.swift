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
    
    var  citys:        [City]      { get }
    var  stations:     [Station]   { get }
    var  countOfAPIs:  Int         { get }
    func downloadInfoOfBikeFromAPI(completed:@escaping DownloadComplete)
    func statusOfStationImage(station:[Station], index:Int) -> String
    func findLocateBikdAPI2Download(userLocation: CLLocationCoordinate2D)
    var  netWorkDataSize: Int { get }
    
}


class BikeStationsModel: BikeStationDelegate {
    
    internal var stations: [Station] {
        return _stations
    }
    
    internal var countOfAPIs = 0
    internal var netWorkDataSize = 0
    var citys: [City] = []
    var longitude = ""
    var lativtude = ""
    var _stations: [Station] = []
    var apis = Bike().apis
    
    func downloadInfoOfBikeFromAPI(completed:@escaping DownloadComplete) {
        //Alamofire download

        self._stations.removeAll()
        countOfAPIs = 0
        citys.removeAll()
        
        for api in apis {
            guard api.isHere else {
                continue
            }
            self.countOfAPIs += 1
            citys.append(api.city)
//            print("User in here: \(api.city)", self.countOfAPIs)
            
            guard let currentBikeURL = URL(string: api.url) else {
                print("URL error")
                return
            }
            
            switch api.dataType {
            case .XML, .html:
                Alamofire.request(currentBikeURL).responseString { response in
//                    print("資料來源: \(response.request!)\n 伺服器傳輸量: \(response.data!)\n")
//                    print("\nsuccess", api.city,"\n")
                    guard response.result.isSuccess else {
                        print("response is failed")
                        return
                    }
                    
                    let dataSize = response.data! as NSData
                    self.netWorkDataSize += (dataSize.length)
//                    print("netWorkDataSize", self.netWorkDataSize.currencyStyle, "bytes")
                    
                    // html
                    if api.dataType == .html {
                        guard let html = response.result.value else {
                            print("error: BikeStationsModel .html " )
                            return
                        }
                        guard let stations = self.parseHTML2Object(city: api.city, html: html) else {
                            print("error: BikeStationsModel .html " )
                            return
                        }
                        
                        self._stations.append(contentsOf: stations)
                        
                        // xml
                    } else {
                        guard let xmlToParse = response.result.value else {
                            print("error, can't unwrap response data")
                            return
                        }
                        let xml = SWXMLHash.parse(xmlToParse)
                        do {
                            guard let stationsXML:[StationXMLObject] = try xml["BIKEStationData"]["BIKEStation"]["Station"].value() else {
                                return
                            }
                            if let stations:[Station] = self.parseXML2Object(city: api.city, xml: stationsXML) {
                                self._stations.append(contentsOf: stations)
                            }
                            
                        } catch {
                            print("xml parse error:", error)
                        }
                    }
                    completed() // main
                }
                
            case .JSON:
                Alamofire.request(currentBikeURL).validate().responseJSON { response in
//                    print("資料來源: \(response.request!)\n 伺服器傳輸量: \(response.data!)\n")
//                    print("\nsuccess", api.city,"\n")
                    let dataSize = response.data! as NSData
                    self.netWorkDataSize += (dataSize.length)
//                    print("netWorkDataSize", self.netWorkDataSize.currencyStyle, "bytes")
                    
                    switch response.result {
                    case .success(let value):
                        
                        let json = JSON(value)
                        guard let stations:[Station] = self.parseJSON2Object(city: api.city, json: json) else {
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
