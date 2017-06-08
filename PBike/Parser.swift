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

typealias HTML = String

protocol Parsable {
    
     func parse(city: City, html: HTML)      -> [Station]?
     func parse(city: City, json: JSON)      -> [Station]?
     func parse(city: City, xml: [Station])  -> [Station]?
    
    
}

extension Parsable {
    
    internal func parse(city: City, html: HTML) -> [Station]? {
        
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
        
        guard let stations: [Station] = parse(city: city, json: json) else {
            print("station is nil plz check parseJson")
            return nil
        }
        return stations
    }
    
    
   internal func parse(city: City, json: JSON) -> [Station]? {
        var jsonStation: [Station] = []
        guard !(json.isEmpty) else {
            print("error: JSON parser ")
            return nil
        }
        
        func deserializableJSON(json: JSON) -> [Station] {
            var deserializableJSON:[Station] = []
            
            let isTainan: Bool = city == .tainan ? true : false
            
            let name =        isTainan ? "StationName"          : "sna"
            let location =    isTainan ? "Address"              : "ar"
            let parkNumber =  isTainan ? "AvaliableSpaceCount"  : "bemp"
            let bikeOnSite =  isTainan ? "AvaliableBikeCount"   : "sbi"
            let latitude =    isTainan ? "Latitude"             : "lat"
            let longitude =   isTainan ? "Longitude"            : "lng"
            
            
            for ( _ , dict) in json {
                let obj = Station(
                    name:               dict[name].string,
                    location:           dict[location].stringValue,
                    parkNumber:         dict[parkNumber].intValue,
                    bikeOnSite:         dict[bikeOnSite].intValue,
                    latitude:           dict[latitude].doubleValue,
                    longitude:          dict[longitude].doubleValue
                )
                
                deserializableJSON.append(obj)
            }
            return deserializableJSON
        }
        
        var jsonArray = json[]
        
        switch city {
            
        case .taipei, .taichung:
            jsonArray = json["retVal"]
            
        case .newTaipei, .taoyuan:
            jsonArray = json["result"]["records"]
            
        case .changhua, .hsinchu, .tainan:
            jsonArray = json
            
        default:
            print("JSON city error:", city)
        }
        
        jsonStation = deserializableJSON(json: jsonArray)
        return jsonStation
    }
    
    
   internal func parse(city: City, xml: [Station]) -> [Station]? {
        var stationsParsed:[Station]  = []
        
        guard !(xml.isEmpty) else {
            print("error: xml parser")
            return nil
        }
        
        stationsParsed = xml.map {
            
            var obj = Station (
                name:               $0.name,
                location:           $0.location,
                parkNumber:         $0.parkNumber,
                bikeOnSite:         $0.bikeOnSite,
                latitude:           $0.latitude,
                longitude:          $0.longitude
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


