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
    let bikeOnService = 500
    var stations:[Station] {
        return _stations
    }
    
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
                            if let stations:[Station] = try! xml["BIKEStationData"]["BIKEStation"]["Station"].value(){
                                self._stations = stations
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
        var longitude:String
        var latitude:String
        
        static func deserialize(_ node: XMLIndexer) throws -> Station { return try Station(
            name: node["StationName"].value(),
            location: node["StationAddress"].value(),
            parkNumber: node["StationNums2"].value(),
            currentBikeNumber: node["StationNums1"].value(),
//                        longitude: node["StationLon"].value(),
//                        latitude: node["StationLat"].value()
            longitude: node["StationLat"].value(),
            latitude: node["StationLon"].value()
            
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
        //取得方法：半夜無人使用之bike在站數
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
                
            case 5...24: pinImage = "pinMed"
                
            case 25...40: pinImage = "pinFull"
                
            case 0: pinImage = "pinEmpty"
                
            default: pinImage  = "pinUnknow"
                
            }
        }
        
        return pinImage
    }
    
}





