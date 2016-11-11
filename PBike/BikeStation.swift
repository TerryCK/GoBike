//
//  BikeStationInfo.swift
//  PBike
//
//  Created by 陳 冠禎 on 2016/10/16.
//  Copyright © 2016年 陳 冠禎. All rights reserved.
//

import Foundation
import Alamofire
import SWXMLHash
import ReachabilitySwift

class BikeStation {
    let reachability = Reachability()!
    var _date: String!
    
    var bikeOnService:Int = 0
    var stations:[Station] {
        return _stations
    }
    var PBike_URL = "http://pbike.pthg.gov.tw/xml/stationlist.aspx"
    var AppBikeVersion:BikeVision = BikeVision.PBike
    var longitude = ""
    var lativtude = ""
    
    var _stations:[Station] = []
    
    var date:String! {
        if _date == nil {
            _date = ""
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .none
        let currentDate = dateFormatter.string(from: Date())
        self._date = "Today, \(currentDate)"
        
        return _date
    }
    
    
    func downloadPBikeDetails(completed:@escaping DownloadComplete){
        //Alamofire download
        
        
        //version check
        
        //        let cityBike = Bundle.main.object(forInfoDictionaryKey: "CiyBike")
        //        print("cityBike : \(cityBike)")
        
        #if CityBike
            self.PBike_URL = "http://www.c-bike.com.tw/xml/stationlistopendata.aspx"
            
            print("*****************\n")
            print("CityBike Version")
            print("\n*****************")
            self.AppBikeVersion = .CityBike
            self.bikeOnService = 2500
            
        #else
            self.PBike_URL = "http://pbike.pthg.gov.tw/xml/stationlist.aspx"
            
            print("*****************\n")
            print("PBike Version")
            print("\n*****************")
            self.AppBikeVersion = .PBike
            self.bikeOnService = 500
        
        #endif
        

        //        let test = false //測試連線模式
        //        switch test{
        switch reachability.isReachable {
            
        case true:
            
            func catchPBikeDataOffline(){
                
            }
            if let currentPBikeURL = URL(string: PBike_URL){
                Alamofire.request(currentPBikeURL).responseString {response in
                    print("資料來源: \(response.request!)")
                    print("伺服器量: \(response.data!)")
                    print("結果: \(response.result)")
                    print("連線模式")
                    
                    if response.result.isSuccess {
                        if let xmlString = response.result.value {
                            let xml = SWXMLHash.parse(xmlString)
                            //                            print("xml: \(xml)")
                            if let stations:[Station] = try! xml["BIKEStationData"]["BIKEStation"]["Station"].value(){
                                print("AppBikeVersion : \(self.AppBikeVersion)")
                                
                                switch (self.AppBikeVersion) {
                                case .PBike:
                                    
                                    let count = stations.count - 1
                                    var _temp = 0.0
                                    print("座標交換以符合座標格式")
                                    //do exchange for PBike Lat & Lon
                                    var arrs: [Station] = stations
                                    
                                    for index in 0...count{
                                        _temp = arrs[index].latitude
                                        arrs[index].latitude = arrs[index].longitude
                                        arrs[index].longitude = _temp
                                    }
                                    self._stations = arrs
                                    print(" 已交換處理self._stations: arrs")
                                    
                                    
                                case .CityBike:
                                    self._stations = stations
                                    print("self._stations: stations")
                                    
                                }
                                
                                
                            }
                        }
                        print("PBick Station Data has been downloaded online")
                        
                        
                        
                    }else{
                        print("data download error")
                        
                        if let offlineURL = Bundle.main.url(forResource: "stationlist", withExtension: "xml"){
                            print("not found any network please turn on your Wifi or cellular ")
                            print("Offline mode")
                            let data = try? Data(contentsOf: offlineURL)
                            if let xmlString = data {
                                let xml = SWXMLHash.parse(xmlString)
                                if let stations:[Station] = try! xml["BIKEStationData"]["BIKEStation"]["Station"].value(){
                                    self._stations = stations
                                    print("PBick Station Data from offline")
                                }else{ print("data download error") }
                            }
                            completed() //else
                        }
                        
                    }
                    
                    completed() // main
                }
            }
            
        case false: //not connect network
            
            if let offlineURL = Bundle.main.url(forResource: "stationlist", withExtension: "xml"){
                print("not found any network please turn on your Wifi or cellular ")
                print("Offline mode")
                let data = try? Data(contentsOf: offlineURL)
                if let xmlString = data {
                    let xml = SWXMLHash.parse(xmlString)
                    if let stations:[Station] = try! xml["BIKEStationData"]["BIKEStation"]["Station"].value(){
                        self._stations = stations
                        print("PBick Station Data from offline")
                    }else{ print("data download error") }
                }
                
                
                completed()
            }
        }
    }
    
    
    
    struct Station:XMLIndexerDeserializable {
        var name: String?
        var location:String
        var parkNumber:Int?
        var currentBikeNumber:Int?
        var longitude:Double
        var latitude:Double
        
        static func deserialize(_ node: XMLIndexer) throws -> Station { return try Station(
            name: node["StationName"].value(),
            location: node["StationAddress"].value(),
            parkNumber: node["StationNums2"].value(),
            currentBikeNumber: node["StationNums1"].value(),
            longitude: node["StationLon"].value(),
            latitude: node["StationLat"].value()
            
            )
        }
    }
    
    func enumerate(indexer: XMLIndexer, level: Int) {
        for child in indexer.children {
            let name = child.element!.name
            print("\(level) \(name)")
            
            enumerate(indexer: child, level: level + 1)
        }
    }
    func current(station:[Station], index:Int) -> Int {
        return { station[index].currentBikeNumber! + station[index].parkNumber! }()
    }
    
    //計算邏輯：半夜Pbike在站數 - 目前Bike在站數
    func numberOfBikeIsUsing(station: [Station], count:Int) -> Int {
        var bikesInStation = 0
        var bikesInUsing = 0
        
        for index in 0...(count - 1) {
            bikesInStation += station[index].currentBikeNumber!
        }
        bikesInUsing = bikeOnService - bikesInStation
        //取得方法：半夜無人使用之bike在站數(取得營運總車數)
        if bikesInStation <= 0 {
            bikesInStation = 0
        }
        return bikesInUsing
    }
    
    func bikesInStation(station: [Station], count:Int) -> Int {
        var currentBikeNumber = 0
        for index in 0...(count - 1) {
            currentBikeNumber += station[index].currentBikeNumber!
        }
        
        return currentBikeNumber
    }
    
    
    func statusOfStationImage(station:[Station], index:Int) -> String {
        var pinImage = ""
        
        if let numberOfBike = station[index].currentBikeNumber {
            switch numberOfBike {
                
            case 1...5: pinImage = "pinLess"
                
            case 5...40:
                
                if station[index].parkNumber == 0 {
                pinImage = "pinFull"
                    
            }else{
                
                pinImage = "pinMed"
                }
            
                
            case 0: pinImage = "pinEmpty"
                
            default: pinImage  = "pinUnknow"
                
            }
        }
        
        return pinImage
    }
    
    
    enum BikeVision {
        case PBike
        case CityBike
    }
}





