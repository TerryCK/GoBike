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
    func parse(city: City, dataFormat html: HTML) -> [Station]?
    func parse(city: City, dataFormat json: JSON) -> [Station]?
    func parse(city: City, dataFormat xml: [Station]) -> [Station]?
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

    func parse(city: City, dataFormat xml: [Station]) -> [Station]? {
        guard !(xml.isEmpty) else { print("xml is empty") ; return nil }

        let stationsParsed: [Station] = xml.map { (station) in

            let obj = Station (
                name:               station.name,
                location:           station.location,
                slot:               station.slot,
                bikeOnSite:         station.bikeOnSite,
                latitude:           station.latitude > station.longitude ? station.longitude : station.latitude,
                longitude:          station.latitude > station.longitude ? station.latitude  : station.longitude
            )
            return obj
        }

        return stationsParsed
    }

    func parse(city: City, dataFormat json: JSON) -> [Station]? {
        var jsonStation: [Station] = []
        guard !(json.isEmpty) else {
            print("error: JSON parser ")
            return nil
        }

        func deserializableJSON(json: JSON) -> [Station] {
            var deserializableJSON = [Station]()

            let isTainan: Bool = city == .tainan ? true : false

            var name =        isTainan ? "StationName"          : "sna"
            var location =    isTainan ? "Address"              : "ar"
            var parkNumber =  isTainan ? "AvaliableSpaceCount"  : "bemp"
            var bikeOnSite =  isTainan ? "AvaliableBikeCount"   : "sbi"
            var latitude =    isTainan ? "Latitude"             : "lat"
            var longitude =   isTainan ? "Longitude"            : "lng"

            if city == .worlds {
                name = "name"
                location = "name"
                parkNumber = "empty_slots"
                bikeOnSite = "free_bikes"
                latitude = "latitude"
                longitude = "longitude"
            }

            for ( _, dict) in json {
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

        case .worlds :
            jsonArray = json["network"]["stations"]

        default:
            print("JSON city error:", city)
        }

        jsonStation = deserializableJSON(json: jsonArray)
        return jsonStation
    }

}

extension Parsable where Self: WorldAPIGetable {

    func parse(url: String, dataFormat json: JSON) -> [World] {

        var jsonWorld = [World]()

        guard !(json.isEmpty) else {
            print("error: JSON parser ")
            return jsonWorld
        }

        func deserializableJSON(json: JSON) -> [World] {

            var deserializableJSON = [World]()
            for (_, dict) in json {

                let location = Location(city: dict["location"]["city"].stringValue,
                                        country: dict["location"]["country"].stringValue,
                                        latitude: dict["location"]["latitude"].doubleValue,
                                        longitude: dict["location"]["longitude"].doubleValue
                )

                let world = World(company: dict["company"].stringValue,
                                 href: dict["href"].stringValue,
                                 id: dict["id"].stringValue,
                                 location: location,
                                 name: dict["name"].stringValue
                )

                deserializableJSON.append(world)
            }

            return deserializableJSON
        }

        let jsonArray = json["networks"]
        let worlds = deserializableJSON(json: jsonArray)
        return worlds
    }
}
