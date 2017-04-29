//
//  Parser.swift
//  PBike
//
//  Created by 陳 冠禎 on 2017/3/5.
//  Copyright © 2017年 陳 冠禎. All rights reserved.
//

import Kanna
import Alamofire
import SWXMLHash
import Foundation
import SwiftyJSON
import CoreLocation


extension BikeStation {
    
    func parseHTML(city:String, html: String) -> Void {
        
        guard let doc = Kanna.HTML(html: html, encoding: String.Encoding.utf8) else {
            print("doc can't be assigned by html")
            return
        }
        
        let node = doc.css("script")[21]
        let uriDecoded = node.text?.between("arealist='", "';arealist=JSON")?.urlDecode
        
        guard let dataFromString = uriDecoded?.data(using: String.Encoding.utf8, allowLossyConversion: false) else {
            print("dataFromString can't be assigned Changhau & Hsinchu")
            return
        }
        let json = JSON(data: dataFromString)
        
        guard let stations:[Station] = self.parseJSON2Object(city, json: json) else {
            print("station is nil plz check parseJson")
            return
        }
        self._stations.append(contentsOf: stations)
    }
    
    func findLocateBikdAPI2Download(userLocation: CLLocationCoordinate2D) {
        let latitude = userLocation.latitude.format //(%.2 double)
        let longitude = userLocation.longitude.format
        for index in 0..<apis.count {
            
            switch (apis[index].city, latitude, longitude){
            case ("taipei", 24.96...25.14, 121.44...121.65):
                apis[index].isHere = true
                
                
            case ("newTaipei", 24.75...25.33, 121.15...121.83):
                apis[index].isHere = true
                
                
            case ("taoyuan", 24.81...25.11, 120.9...121.4):
                apis[index].isHere = true
                
                
            case ("Hsinchu", 24.67...24.96, 120.81...121.16):
                apis[index].isHere = true
                
                
            case ("taichung", 24.03...24.35, 120.40...121.00):
                apis[index].isHere = true
                
                
            case ("Changhua", 23.76...24.23, 120.06...120.77):
                apis[index].isHere = true
                
                
            case ("tainan", 22.72...23.47, 119.94...120.58):
                apis[index].isHere = true
                
                
            case ("kaohsiung", 22.46...22.73, 120.17...120.44):
                apis[index].isHere = true
                
                
            case ("pingtung", 22.62...22.71, 120.430...120.53):
                apis[index].isHere = true
                
                
            default:  //show alart
                apis[index].isHere = true
            }
            print("set",apis[index].city,"to" ,apis[index].isHere)
        }
    }
    
    func parseJSON2Object(_ callIdentifier: String, json: JSON)  ->  [Station]? {
        var jsonStation: [Station] = []
        //        print("callIdentifier:",callIdentifier, "\n json:", json)
        guard !(json.isEmpty) else {
            print("json is empty")
            return nil
        }
        
        func deserializableJSON(json: JSON) -> [Station] {
            var deserializableJSONStation:[Station] = []
            print("call deserializableJSON")
            
            for ( _ , dict) in json {
                
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
        
        func deserializableJSONOfTainan(json: JSON) -> [Station] {
            var deserializableJSONStation:[Station] = []
            for ( _ , dict) in json {
                
                let obj = Station(
                    name: dict["StationName"].string,
                    location: dict["Address"].stringValue,
                    parkNumber: dict["AvaliableSpaceCount"].intValue,
                    currentBikeNumber: dict["AvaliableBikeCount"].intValue,
                    longitude: dict["Longitude"].doubleValue,
                    latitude: dict["Latitude"].doubleValue)
                
                deserializableJSONStation.append(obj)
            }
            return deserializableJSONStation
        }
        
        var jsonArray = json[]
        
        switch callIdentifier {
        case "tainan":
            jsonArray = json
            jsonStation = deserializableJSONOfTainan(json: jsonArray)
            return jsonStation
            
        case "taipei","taichung":
            jsonArray = json["retVal"]
            
        case "newTaipei", "taoyuan":
            jsonArray = json["result"]["records"]
            
        case "Changhua", "Hsinchu":
            jsonArray = json
            
        default:
            print("callIdentifier error")
        }
        
        jsonStation = deserializableJSON(json: jsonArray)
        return jsonStation
    }
    
    func statusOfStationImage(station:[Station], index:Int) -> String {
        var pinImage = ""
        
        if let numberOfBike = station[index].currentBikeNumber {
            
            switch numberOfBike {
            case 1...5:
                pinImage = "pinLess"
                
            case 5...200:
                pinImage = station[index].parkNumber == 0 ? "pinFull" : "pinMed"
                
            case 0:
                pinImage = "pinEmpty"
                
            default:
                pinImage  = "pinUnknow"
                
            }
        }
        return pinImage
    }
    
    func xmlToStation(key:String, stations:[StationXML]) -> [Station] {
        var _station:[Station]  = []
        let count = stations.count
        
        for index in 0..<count  {
            
            var obj = Station(
                name: stations[index].name,
                location: stations[index].location,
                parkNumber: stations[index].parkNumber,
                currentBikeNumber: stations[index].currentBikeNumber,
                longitude: stations[index].longitude,
                latitude: stations[index].latitude
            )
            
            if obj.latitude > obj.longitude {
                swap(&obj.latitude, &obj.longitude)
            }
            
            _station.append(obj)
        }
        
        
        return _station
    }

}
