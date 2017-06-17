//
//  API.swift
//  GoBike
//
//  Refactor by 陳 冠禎 on 2017/6/8.
//  Copyright © 2016年 陳 冠禎. All rights reserved.
//
struct BikeStationAPI {
    var APIs = [
        API(city: .taipei,      dataType: .json),
        API(city: .newTaipei,   dataType: .json),
        API(city: .taoyuan,     dataType: .json),
        API(city: .hsinchu,     dataType: .html),
        API(city: .taichung,    dataType: .json),
        API(city: .changhua,    dataType: .html),
        API(city: .tainan,      dataType: .json),
        API(city: .kaohsiung,   dataType: .xml),
        API(city: .pingtung,    dataType: .xml)
    ]
}

struct API {
    var city: City
    var isHere: Bool = false
    var dataType: DataType
    
    init(city: City,  dataType: DataType) {
        self.city = city
        self.dataType = dataType
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
}





//struct CityRigion {
//    static let taipei =    (24.96...25.14, 121.44...121.65)
//    let newTaipei = (24.75...25.33, 121.15...121.83)
//    let taoyuan =   (24.81...25.11, 120.90...121.40)
//    let hsinchu =   (24.67...24.96, 120.81...121.16)
//    let taichung =  (24.03...24.35, 120.40...121.00)
//    let changhua =  (23.76...24.23, 120.06...120.77)
//    let tainan =    (22.72...23.47, 119.94...120.58)
//    let kaohsiung = (22.46...22.73, 120.17...120.44)
//    let pingtung =  (22.62...22.71, 120.43...120.53)
//}


