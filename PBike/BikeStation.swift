//
//  BikeStationInfo.swift
//  PBike
//
//  Created by 陳 冠禎 on 2016/10/16.
//  Copyright © 2016年 陳 冠禎. All rights reserved.
//

import Foundation
import Alamofire
import SWXMLHash

class BikeStation {

    var _date: String!
 
    var stations:[Station] {
        return _stations
    }
    
    var _stations:[Station] = []
    
    var date:String! {
        if _date == nil {
            _date = ""
        }
        
        let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .long
            dateFormatter.timeStyle = .none
        let currentDate = dateFormatter.string(from: Date())
        self._date = "Today, \(currentDate)"
        
        return _date
    }

    func downloadPBikeDetails(completed:@escaping DownloadComplete){
        //Alamofire download
        
        let currentPBikeURL = URL(string: PBike_URL)
        Alamofire.request(currentPBikeURL!).responseString {response in
           
            
            if let xmlString = response.result.value {
                let xml = SWXMLHash.parse(xmlString)
                if let stations:[Station] = try! xml["BIKEStationData"]["BIKEStation"]["Station"].value(){
                
                    self._stations = stations
                   
                        }
                    }
                completed()
                }
        
            }
    

    
    
    
    struct Station:XMLIndexerDeserializable {
        var name: String
        var location:String
        var parkNumber:Int?
        var currentBikeNumber:Int?
        var longitude:String
        var latitude:String
        
        static func deserialize(_ node: XMLIndexer) throws -> Station { return try Station(
            name: node["StationName"].value(),
            location: node["StationAddress"].value(),
            parkNumber: node["StationNums1"].value(),
            currentBikeNumber: node["StationNums2"].value(),
            longitude: node["StationLon"].value(),
            latitude: node["StationLat"].value()
            )
        }
    }
        
    func enumerate(indexer: XMLIndexer, level: Int) {
        for child in indexer.children {
            let name = child.element!.name
            print("\(level) \(name)")
            
            enumerate(indexer: child, level: level + 1)
        }
    }
    
    func numberOfBikeIsUsing(station: [Station], count:Int) -> Int {
        var parkNumber = 0
        for index in 0...(count - 1) {
            parkNumber += station[index].currentBikeNumber!
        }
       
        return parkNumber
    }
}



