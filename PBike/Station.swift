//
//  Station.swift
//  PBike
//
//  Created by 陳 冠禎 on 2016/12/28.
//  Copyright © 2016年 陳 冠禎. All rights reserved.
//

import SWXMLHash

protocol StationInfoProtocol {
    var name: String? {get set}
    var location:String {get set}
    var parkNumber:Int? {get set}
    var currentBikeNumber:Int? {get set}
    var longitude:Double {get set}
    var latitude:Double {get set}
}

struct StationXML:XMLIndexerDeserializable, StationInfoProtocol {
    var name: String?
    var location:String
    var parkNumber:Int?
    var currentBikeNumber:Int?
    var longitude:Double
    var latitude:Double
    
    static func deserialize(_ node: XMLIndexer) throws -> StationXML { return try StationXML(
        name: node["StationName"].value(),
        location: node["StationAddress"].value(),
        parkNumber: node["StationNums2"].value(),
        currentBikeNumber: node["StationNums1"].value(),
        longitude: node["StationLon"].value(),
        latitude: node["StationLat"].value()
        )
    }
}

struct Station: StationInfoProtocol {
    var name: String?
    var location:String
    var parkNumber:Int?
    var currentBikeNumber:Int?
    var longitude:Double
    var latitude:Double
}





