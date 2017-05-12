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

protocol BikeStationDelegate  {
    
    var  citys:        [City]      { get }
    var  stations:     [Station]   { get }
    var  countOfAPIs:  Int         { get }
    func downloadInfoOfBikeFromAPI(completed: @escaping DownloadComplete)
    func statusOfStationImage(station: [Station], index: Int) -> String
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
    
    init(){
        print("BikeStationsModel init")
    }
    
    deinit {
        print("BikeStationsModel deinit")
    }
    
    func downloadInfoOfBikeFromAPI(completed: @escaping DownloadComplete) {
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
            guard let currentBikeURL = URL(string: api.url) else {
                print("URL error")
                return
            }
            
            switch api.dataType {
            case .XML, .html:
                Alamofire.request(currentBikeURL).responseString {  response in
                    guard response.result.isSuccess else {
                        print("response is failed")
                        return
                    }
                    
                    let dataSize = response.data! as NSData
                    self.netWorkDataSize += (dataSize.length)
                    
                    // html
                    if api.dataType == .html {
                        guard let html = response.result.value,
                            let stations = self.parseHTML2Object(city: api.city, html: html) else {
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
                            guard let stationsXML:[StationXMLObject] = try xml["BIKEStationData"]["BIKEStation"]["Station"].value(),
                                  let stations:[Station] = self.parseXML2Object(city: api.city, xml: stationsXML) else {
                                  return
                            }
                                self._stations.append(contentsOf: stations)
                            
                            
                        } catch {
                            print("xml parse error:", error)
                        }
                    }
                    completed() // main
                }
                
            case .JSON:
                Alamofire.request(currentBikeURL).validate().responseJSON {  response in
                    let dataSize = response.data! as NSData
                    self.netWorkDataSize += (dataSize.length)
                    
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




