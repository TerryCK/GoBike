//
//  BikeStationInfo.swift
//  PBike
//
//  Created by 陳 冠禎 on 2016/10/16.
//  Copyright © 2016年 陳 冠禎. All rights reserved.
//

import Foundation

class BikeStation {

    var name:String
    var address:String
    var bikeCurrentNumber:Int?
    var bikeHasRentalNumber:Int?
    
    
    init(name:String, address:String, bikeCurrentNumber:Int?, bikeHasRentalNumber:Int?){
    
        self.name = name
        self.address = address
        self.bikeCurrentNumber = bikeCurrentNumber
        self.bikeHasRentalNumber = bikeHasRentalNumber
        
    }
    
    


}
