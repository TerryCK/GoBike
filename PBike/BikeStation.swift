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
import SwiftyJSON
import CoreLocation

protocol BikeStationDelegate {
    var  stations: [Station] { get }
    var  numberOfAPIs:Int { get }
    var  citys: [String] { get }
    func downloadInfoOfBikeFromAPI(completed:@escaping DownloadComplete)
    func current(station:[Station], index:Int) -> Int
    func numberOfBikeIsUsing(station: [Station], count:Int) -> Int
    func bikesInStation(station: [Station], count:Int) -> Int
    func statusOfStationImage(station:[Station], index:Int) -> String
    func findLocateBikdAPI2Download(userLocation: CLLocationCoordinate2D)

}


class BikeStation:BikeStationDelegate {
    
    internal var stations: [Station] { return _stations }
    var numberOfAPIs = 0
    
    var _date: String!
    var bikeOnService: Int = 500
    var Bike_URL = "http://pbike.pthg.gov.tw/xml/stationlist.aspx"
    var citys: [String] = []
    var longitude = ""
    var lativtude = ""
    var _stations: [Station] = []
    var apis = Bike().apis
    
    //    var date:String! {
    //
    //        if _date == nil { _date = "" }
    //        let dateFormatter = DateFormatter()
    //        dateFormatter.dateStyle = .long
    //        dateFormatter.timeStyle = .none
    //        let currentDate = dateFormatter.string(from: Date())
    //        self._date = "Today, \(currentDate)"
    //
    //        return _date
    //    }
    
//    
    
    
    internal func downloadInfoOfBikeFromAPI(completed:@escaping DownloadComplete) {
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
        numberOfAPIs = 0
       
        citys.removeAll() //inital
        
        for api in apis {
            guard api.isHere else { continue }
            self.numberOfAPIs += 1
            citys.append(api.city)
            print("User in here: \(api.city)", self.numberOfAPIs)
            guard let currentBikeURL = URL(string: api.url) else {print("URL error"); return}
            
            switch api.city {
            case "kaohsiung", "pingtung", "tainan":
                
                Alamofire.request(currentBikeURL).responseString { response in
                    print("資料來源: \(response.request!)\n 伺服器傳輸量: \(response.data!)\n")
                    
                    guard response.result.isSuccess else { print("response is failed") ; return }
                        
                        guard let xmlToParse = response.result.value else { print("error, can't unwrap response data"); return }
                        let xml = SWXMLHash.parse(xmlToParse)
                        do {
                            switch api.city {
                            
                                //will review for tainan bike
//                            case "tainan" :
//                                guard let stationsXML:[StationXMLTainan] = try xml["ArrayOfStationStatusData"]["StationStatusData"].value()
//                                    else { print("cannot guard"); return }
//                                print("station " , stationsXML)
//                                let stations:[Station] = self.xmlTainanToStation(key:api.city ,stations: stationsXML)
//                                self._stations.append(contentsOf: stations)
                                
                            default:
                                guard let stationsXML:[StationXML] = try xml["BIKEStationData"]["BIKEStation"]["Station"].value() else { return }
                                let stations:[Station] = self.xmlToStation(key:api.city ,stations: stationsXML)
                                self._stations.append(contentsOf: stations)
                            }
                        } catch { print("error:", error) }
                    completed() // main
                }
                
            default:
                Alamofire.request(currentBikeURL).validate().responseJSON { response in
                    print("資料來源: \(response.request!)\n 伺服器傳輸量: \(response.data!)\n")
                    
                    switch response.result {
                    case .success(let value):
                        
                        print("success", api.city)
                        let json = JSON(value)
                        guard let stations:[Station] = self.parseJSON2Object(api.city, json: json) else {print("station is nil plz check parseJson"); return}
                        
                        self._stations.append(contentsOf: stations)
                        
                            completed()
                       
                        
                    case .failure(let error):
                        print("error", error)
                    }
                }
            }
        }
    }
    
    func findLocateBikdAPI2Download(userLocation: CLLocationCoordinate2D) {
        let latitude = userLocation.latitude.format
        let longitude = userLocation.longitude.format
//        print("longitude",longitude)
//        print("call findLocateBikdAPI2Download")
        for index in 0..<apis.count {
            switch (apis[index].city, latitude, longitude){
            
            case ("taipei", 24.96...25.14 , 121.44...121.65):
                apis[index].isHere = true
                self.bikeOnService = 15000
         
                
            case ("newTaipei", 25.09...25.10 , 121.51...121.60):
                apis[index].isHere = true
                self.bikeOnService = 15000
                
                
            case ("taoyuan", 24.81...25.11 , 120.9...121.4):
                apis[index].isHere = true
                self.bikeOnService = 15000
               
                
            case ("taichung", 24.03...24.35 , 120.40...121.00):
                apis[index].isHere = true
                self.bikeOnService = 15000
             
                
//            case (25.09...25.10 , 121.51...121.60, "tainan"): break
            
                
            case ("kaohsiung", 22.46...22.73 , 120.17...120.44):
                apis[index].isHere = true
                self.bikeOnService = 2500
                
                
            case ("pingtung", 22.62...22.71 , 120.430...120.53):
                apis[index].isHere = true
                self.bikeOnService = 500
                
                
            default:  //show alart
                apis[index].isHere = false
               
            }
             print("set",apis[index].city,"to" ,apis[index].isHere)
        }
    }
    
    func exchangeStationLcoations(stations:[Station]){
        let count = stations.count
        var _temp = 0.0
        print("座標交換以符合座標格式")
        //do exchange for PBike Lat & Lon
        var arrs: [Station] = stations
        for index in 0..<count{
            _temp = arrs[index].latitude
            arrs[index].latitude = arrs[index].longitude
            arrs[index].longitude = _temp
        }
        self._stations = arrs
    }
    
    
    
    
    
    
    func parseJSON2Object(_ callIdentifier: String, json: JSON)  ->  [Station]? {
        var jsonStation: [Station] = []
        guard !(json.isEmpty) else { print("json is empty"); return nil }
        
        func deserializableJSON(json: JSON) -> [Station] {
            var deserializableJSONStation:[Station] = []
            for (_, dict) in json {
                
                let obj = Station(
                    name: dict["sna"].string,
                    location: dict["ar"].stringValue,
                    parkNumber: dict["bemp"].intValue,
                    currentBikeNumber: dict["sbi"].intValue,
                    longitude: dict["lng"].doubleValue,
                    latitude: dict["lat"].doubleValue)
                
                deserializableJSONStation.append(obj)
            }
            return deserializableJSONStation
        }
        var jsonArray = json[]
        switch callIdentifier {
        case "taipei","taichung":
            
            jsonArray = json["retVal"]
            jsonStation = deserializableJSON(json: jsonArray)
            
        case "newTaipei", "taoyuan":
            
            jsonArray = json["result"]["records"]
            jsonStation = deserializableJSON(json: jsonArray)
            
        default:
            print("error")
        }
        return jsonStation
    }
    
    func enumerate(indexer: XMLIndexer, level: Int) {
        for child in indexer.children {
            let name = child.element!.name
            print("\(level) \(name)")
            enumerate(indexer: child, level: level + 1)
        }
    }
    
    internal func current(station:[Station], index:Int) -> Int {
        return { station[index].currentBikeNumber! + station[index].parkNumber! }()
    }
    
    //計算邏輯：半夜Pbike在站數 - 目前Bike在站數
    internal func numberOfBikeIsUsing(station: [Station], count:Int) -> Int {
        var bikesInStation = 0
        var bikesInUsing = 0
        for index in 0..<count {
            bikesInStation += station[index].currentBikeNumber!
        }
        bikesInUsing = bikeOnService - bikesInStation
        //取得方法：半夜無人使用之bike在站數(取得營運總車數)
        if bikesInStation <= 0 { bikesInStation = 0 }
        return bikesInUsing
    }
    
    internal func bikesInStation(station: [Station], count:Int) -> Int {
        var currentBikeNumber = 0
        for index in 0..<count {
            currentBikeNumber += station[index].currentBikeNumber!
        }
        return currentBikeNumber
    }
    
    
    
    
    internal func statusOfStationImage(station:[Station], index:Int) -> String {
        var pinImage = ""
        
        if let numberOfBike = station[index].currentBikeNumber {
            switch numberOfBike {
            case 1...5:
                pinImage = "pinLess"
                
            case 5...200:
                if station[index].parkNumber == 0 {
                    pinImage = "pinFull"
                    } else { pinImage = "pinMed"
                }
                
            case 0: pinImage = "pinEmpty"
                
            default: pinImage  = "pinUnknow"
                
            }
        }
        return pinImage
    }
    
    func xmlTainanToStation(key:String, stations:[StationXMLTainan]) -> [Station] {
        var _station:[Station]  = []
        let count = stations.count
        for index in 0..<count  {
            
            let obj = Station(
                name: stations[index].name,
                location: stations[index].location,
                parkNumber: stations[index].parkNumber,
                currentBikeNumber: stations[index].currentBikeNumber,
                longitude: stations[index].latitude,
                latitude: stations[index].longitude)
            
             print("tainan obj",obj)
            _station.append(obj)
        }
        return _station
    }
    
    
    func xmlToStation(key:String, stations:[StationXML]) -> [Station] {
        var _station:[Station]  = []
        let count = stations.count
        switch key {
            
        case "pingtung":
            
            for index in 0..<count  {
                
                let obj = Station(
                    name: stations[index].name,
                    location: stations[index].location,
                    parkNumber: stations[index].parkNumber,
                    currentBikeNumber: stations[index].currentBikeNumber,
                    longitude: stations[index].latitude,
                    latitude: stations[index].longitude)
                
                _station.append(obj)
            }
            
        default:
            
            for index in 0..<count  {
                
                let obj = Station(
                    name: stations[index].name,
                    location: stations[index].location,
                    parkNumber: stations[index].parkNumber,
                    currentBikeNumber: stations[index].currentBikeNumber,
                    longitude: stations[index].longitude,
                    latitude: stations[index].latitude)
                
                //                print(obj)
                _station.append(obj)
            }
        }
        return _station
    }
}

extension Double {
    var format:Double {
        return Double(String(format:"%.2f", self))!
    }
}
