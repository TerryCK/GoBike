//
//  API_Protocol.swift
//  PBike
//
//  Created by 陳 冠禎 on 2016/12/26.
//  Copyright © 2016年 陳 冠禎. All rights reserved.
//

protocol BikeAPIDelegate {
    var apis: [BikeAPI] { get set }
}


struct BikeAPI {
    var city: City
    var url: String
    var isHere: Bool
    var bikeVision:BikeVision
    var dataType:DataType
    
    init (city: City, url: String, isHere: Bool, bikeVision: BikeVision, dataType: DataType) {
        
        self.city = city
        self.url = url
        self.isHere = isHere
        self.bikeVision = bikeVision
        self.dataType = dataType
    }
}



struct Bike: BikeAPIDelegate {
    
    
    static let taipeiAPI = "http://data.taipei/youbike"
    static let newTaipeiAPI = "http://data.ntpc.gov.tw/api/v1/rest/datastore/382000000A-000352-001"
    static let taoyuanAPI = "http://data.tycg.gov.tw/api/v1/rest/datastore/a1b4714b-3b75-4ff8-a8f2-cc377e4eaa0f?format=json"
    static let hsinchuAPI = "http://hccg.youbike.com.tw/cht/f12.php"
    static let taichungAPI = "http://ybjson01.youbike.com.tw:1002/gwjs.json"
    static let changhuaAPI = "http://chcg.youbike.com.tw/cht/f12.php"
    static let taiwanAPI = "http://tbike.tainan.gov.tw:8081/Service/StationStatus/Json"
    static let kaohsiungAPI = "http://www.c-bike.com.tw/xml/stationlistopendata.aspx"
    static let pingtungAPI =  "http://pbike.pthg.gov.tw/xml/stationlist.aspx"
    
    
    internal var apis: [BikeAPI] = [
        
        BikeAPI(city: .Taipei, url: taipeiAPI, isHere: false, bikeVision: .UBike, dataType: .JSON),
        
        BikeAPI(city: .NewTaipei, url: newTaipeiAPI, isHere: false ,bikeVision: .UBike, dataType: .JSON),
        
        BikeAPI(city: .Taoyuan, url: taoyuanAPI, isHere: false, bikeVision: .UBike, dataType: .JSON),
        
        BikeAPI(city: .Hsinchu, url: hsinchuAPI, isHere: false, bikeVision: .UBike,dataType: .html),
        
        BikeAPI(city: .Taichung, url: taichungAPI, isHere: false, bikeVision: .UBike, dataType: .JSON),
        
        BikeAPI(city: .Changhua, url: changhuaAPI, isHere: false, bikeVision: .UBike,dataType: .html),
        
        BikeAPI(city: .Tainan, url: taiwanAPI, isHere: false, bikeVision: .TainanBike, dataType: .JSON),
        
        BikeAPI(city: .Kaohsiung, url: kaohsiungAPI, isHere: false, bikeVision: .CityBike, dataType: .XML),
        
        BikeAPI(city: .Pingtung, url: pingtungAPI, isHere: false, bikeVision: .PBike, dataType: .XML)]
    
}



enum BikeVision {
    case PBike, CityBike, UBike, TainanBike
}

enum DataType {
    case XML, JSON, html
}
enum City {
    case Taipei, NewTaipei, Taoyuan, Hsinchu, Taichung, Changhua, Tainan, Kaohsiung, Pingtung
}


typealias DownloadComplete = () -> ()





