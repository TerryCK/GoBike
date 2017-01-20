//
//  API_Protocol.swift
//  PBike
//
//  Created by 陳 冠禎 on 2016/12/26.
//  Copyright © 2016年 陳 冠禎. All rights reserved.
//

protocol BikeAPIDelegate {
    var apis:[BikeAPI] { get set }
}


struct BikeAPI {
    var url:String
    var city:String
    var isHere:Bool
    var bikeVision:BikeVision
    var dataType:DataType
}


extension BikeAPI {
    init (city:String, url:String, isHere:Bool, bikeVision:BikeVision, dataType:DataType) {
        self.city = city
        self.url = url
        self.isHere = isHere
        self.bikeVision = bikeVision
        self.dataType = dataType
    }
}

struct Bike:BikeAPIDelegate {
     
    internal var apis: [BikeAPI] = [
        
        BikeAPI(city: "taipei", url: "http://data.taipei/youbike", isHere: false, bikeVision: .UBike , dataType: .JSON),
        BikeAPI(city: "newTaipei", url: "http://data.ntpc.gov.tw/api/v1/rest/datastore/382000000A-000352-001", isHere: false ,bikeVision: .UBike, dataType: .JSON),
        BikeAPI(city: "taoyuan", url: "http://data.tycg.gov.tw/api/v1/rest/datastore/a1b4714b-3b75-4ff8-a8f2-cc377e4eaa0f?format=json", isHere: false, bikeVision: .UBike, dataType: .JSON),
        BikeAPI(city: "taichung", url: "http://ybjson01.youbike.com.tw:1002/gwjs.json", isHere: false, bikeVision: .UBike, dataType: .JSON),
        BikeAPI(city: "tainan", url: "http://tbike.tainan.gov.tw:8081/Service/StationStatus/Json", isHere: false, bikeVision: .TainanBike, dataType: .JSON),
        BikeAPI(city: "kaohsiung", url: "http://www.c-bike.com.tw/xml/stationlistopendata.aspx", isHere: false, bikeVision: .CityBike, dataType: .XML),
        BikeAPI(city: "pingtung", url: "http://pbike.pthg.gov.tw/xml/stationlist.aspx", isHere: false, bikeVision: .PBike, dataType: .XML)]
}



enum BikeVision {
    case PBike, CityBike, UBike, TainanBike
}

enum DataType {
    case XML, JSON
}

typealias DownloadComplete = () -> ()





