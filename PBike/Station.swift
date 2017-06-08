//
//  Station.swift
//  PBike
//
//  Created by 陳 冠禎 on 2016/12/28.
//  Copyright © 2016年 陳 冠禎. All rights reserved.
//

import SWXMLHash

protocol Stationable {
    var name:               String?         { get set }
    var location:           String          { get set }
    var parkNumber:         Int?            { get set }
    var bikeOnSite:         Int?            { get set }
    var latitude:           Double          { get set }
    var longitude:          Double          { get set }
}

struct Station: XMLIndexerDeserializable, Stationable {
    var name: String?
    var location: String
    var parkNumber: Int?
    var bikeOnSite: Int?
    var latitude: Double
    var longitude: Double
    
    static func deserialize(_ node: XMLIndexer) throws -> Station {
        
        return try Station (
            name:               node["StationName"].value(),
            location:           node["StationAddress"].value(),
            parkNumber:         node["StationNums2"].value(),
            bikeOnSite:         node["StationNums1"].value(),
            latitude:           node["StationLat"].value(),
            longitude:          node["StationLon"].value()
        )
    }
}









