//
//  API.swift
//  GoBike
//
//  Refactor by 陳 冠禎 on 2017/6/8.
//  Copyright © 2016年 陳 冠禎. All rights reserved.
//

struct BikeAPI  {
    var city: City
    var isHere: Bool = false
    var dataType: DataType
    
    init(city: City,  dataType: DataType) {
        self.city = city
        self.dataType = dataType
    }
}

struct BikeStationAPI {
    
    internal var bikeAPIs = [
    BikeAPI(city: .taipei,      dataType: .JSON),
    BikeAPI(city: .newTaipei,   dataType: .JSON),
    BikeAPI(city: .taoyuan,     dataType: .JSON),
    BikeAPI(city: .hsinchu,     dataType: .html),
    BikeAPI(city: .taichung,    dataType: .JSON),
    BikeAPI(city: .changhua,    dataType: .html),
    BikeAPI(city: .tainan,      dataType: .JSON),
    BikeAPI(city: .kaohsiung,   dataType: .XML),
    BikeAPI(city: .pingtung,    dataType: .XML)
    ]
}


enum DataType {
    case XML, JSON, html
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
}


typealias DownloadComplete = () -> ()





