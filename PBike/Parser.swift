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
     func parse(city: City, dataFormat html: HTML)      -> [Station]?
     func parse(city: City, dataFormat json: JSON)      -> [Station]?
     func parse(city: City, dataFormat xml: [Station])  -> [Station]?
}

extension Parsable {
    
     func parse(city: City, dataFormat html: HTML) -> [Station]? {
        
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
        
        guard let stations: [Station] = parse(city: city, dataFormat: json) else {
            print("station is nil plz check parseJson")
            return nil
        }
        return stations
    }
    
    
    func parse(city: City, dataFormat json: JSON) -> [Station]? {
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
                    slot:               dict[parkNumber].intValue,
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
    
    
    func parse(city: City, dataFormat xml: [Station]) -> [Station]? {
        guard !(xml.isEmpty) else {
            print("xml is empty")
            return nil
        }
        
        let stationsParsed: [Station] = xml.map {
            let obj = Station (
                name:               $0.name,
                location:           $0.location,
                slot:               $0.slot,
                bikeOnSite:         $0.bikeOnSite,
                latitude:           $0.latitude > $0.longitude ? $0.longitude : $0.latitude,
                longitude:          $0.latitude > $0.longitude ? $0.latitude  : $0.longitude
            )
            return obj
        }
        return stationsParsed
    }
}


