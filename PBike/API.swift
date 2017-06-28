//
//  API.swift
//  GoBike
//
//  Refactor by 陳 冠禎 on 2017/6/8.
//  Added Dictional by 陳 冠禎 on 2017/6/19.
//  Copyright © 2016年 陳 冠禎. All rights reserved.
//

struct BikeStationAPI {
    
    var APIs: Dictionary<City, API> = [
        .taipei:    API(city: .taipei,      dataType: .json),
        .newTaipei: API(city: .newTaipei,   dataType: .json),
        .taoyuan:   API(city: .taoyuan,     dataType: .json),
        .hsinchu:   API(city: .hsinchu,     dataType: .html),
        .taichung:  API(city: .taichung,    dataType: .json),
        .changhua:  API(city: .changhua,    dataType: .html),
        .tainan:    API(city: .tainan,      dataType: .json),
        .kaohsiung: API(city: .kaohsiung,   dataType: .xml),
        .pingtung:  API(city: .pingtung,    dataType: .xml),
        .worlds:    API(city: .worlds,      dataType: .json)
    ]
    
}



struct API {
    var city: City
    var dataType: DataType
    var api: String
    
    
    init(city: City,  dataType: DataType) {
        let api = city.rawValue
        self.init(city: city, dataType: dataType, api: api)
    }
    
    init(city: City,  dataType: DataType, api: String) {
        self.city = city
        self.dataType = dataType
        self.api =  api
        
    }
}


enum DataType {
    case xml, json, html
}


enum City: String {
    
    case taipei = "http://data.taipei/youbike"
    case newTaipei = "http://data.ntpc.gov.tw/api/v1/rest/datastore/382000000A-000352-001"
    case taoyuan = "http://data.tycg.gov.tw/api/v1/rest/datastore/a1b4714b-3b75-4ff8-a8f2-cc377e4eaa0f?format=json"
    case hsinchu = "http://hccg.youbike.com.tw/cht/f12.php"
    case taichung = "http://ybjson01.youbike.com.tw:1002/gwjs.json"
    case changhua = "http://chcg.youbike.com.tw/cht/f12.php"
    case tainan = "http://tbike.tainan.gov.tw:8081/Service/StationStatus/Json"
    case kaohsiung = "http://www.c-bike.com.tw/xml/stationlistopendata.aspx"
    case pingtung = "http://pbike.pthg.gov.tw/xml/stationlist.aspx"
    case worlds = "https://api.citybik.es/v2/networks/bikebrasilia"
    
}


struct World {
    let company: String
    let href: String
    let id: String
    let location: Location
    let name: String
}

struct Location {
    let city: String
    let country: String
    let latitude: Double
    let longitude: Double
}

protocol WorldAPIGetable: Parsable {
    func getWorldsAPIs(url: String, completed: @escaping (([API]) -> Void))
}



