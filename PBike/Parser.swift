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

protocol Parser {
    
    func parseHTML2Object(city: City, html: String)                     -> [Station]?
    func parseJSON2Object(city: City, json: JSON)                       -> [Station]?
    func parseXML2Object(city:  City, xml stations: [StationXMLObject]) -> [Station]?
    
}


extension BikeStationsModel: Parser {
    
    func parseHTML2Object(city: City, html: String) -> [Station]? {
        
        guard let doc = Kanna.HTML(html: html, encoding: String.Encoding.utf8) else {
            print("error: parseHTML2Object")
            return nil
        }
        
        let node = doc.css("script")[21]
        
        let header = "arealist='"
        
        let footer = "';arealist=JSON"
        
        let uriDecoded = node.text?.between(header, footer)?.urlDecode
        let using = String.Encoding.utf8
        
        guard let dataFromString = uriDecoded?.data(using: using, allowLossyConversion: false) else {
            print("dataFromString can't be assigned Changhau & Hsinchu")
            return nil
        }
        
        let json = JSON(data: dataFromString)
        
        guard let stations: [Station] = self.parseJSON2Object(city: city, json: json) else {
            print("station is nil plz check parseJson")
            return nil
        }
        return stations
    }
    
    
    
    
    func parseJSON2Object(city: City, json: JSON) -> [Station]? {
        var jsonStation: [Station] = []
        //        print("city:",city, "\n json:", json)
        guard !(json.isEmpty) else {
            print("error: parseJSON2Object")
            return nil
        }
        
        func deserializableJSON(json: JSON) -> [Station] {
            var deserializableJSON:[Station] = []
//            print("call deserializableJSON")
            
            var name =              "sna"
            var location =          "ar"
            var parkNumber =        "bemp"
            var currentBikeNumber = "sbi"
            var longitude =         "lng"
            var latitude =          "lat"
            
            
            if city == .Tainan {
               
                name =              "StationName"
                location =          "Address"
                parkNumber =        "AvaliableSpaceCount"
                currentBikeNumber = "AvaliableBikeCount"
                longitude =         "Longitude"
                latitude =          "Latitude"
            }
            
            for ( _ , dict) in json {
                
                let obj = Station(
                    name:               dict[name].string,
                    location:           dict[location].stringValue,
                    parkNumber:         dict[parkNumber].intValue,
                    currentBikeNumber:  dict[currentBikeNumber].intValue,
                    longitude:          dict[longitude].doubleValue,
                    latitude:           dict[latitude].doubleValue)
                
                deserializableJSON.append(obj)
            }
            return deserializableJSON
        }
        
        var jsonArray = json[]
        
        switch city {
            
        case .Taipei, .Taichung:
            jsonArray = json["retVal"]
            
        case .NewTaipei, .Taoyuan:
            jsonArray = json["result"]["records"]
            
        case .Changhua, .Hsinchu, .Tainan:
            jsonArray = json
            
        default:
            print("city error:", city)
        }
        
        
        jsonStation = deserializableJSON(json: jsonArray)
        return jsonStation
    }
    
    
    func parseXML2Object(city: City, xml stations: [StationXMLObject]) -> [Station]? {
        var stationsParsed:[Station]  = []
        
        guard !(stations.isEmpty) else {
            print("error: parseXML2Object")
            return nil
        }
        
        stationsParsed = stations.map {
            
            var obj = Station (
                name:               $0.name,
                location:           $0.location,
                parkNumber:         $0.parkNumber,
                currentBikeNumber:  $0.currentBikeNumber,
                longitude:          $0.longitude,
                latitude:           $0.latitude
            )
            
            // avoid data source wrong formation with coordinates
            if obj.latitude > obj.longitude {
                swap(&obj.latitude, &obj.longitude)
            }
            
            return obj
        }
        
        return stationsParsed
    }
}

