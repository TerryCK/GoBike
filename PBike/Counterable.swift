//
//  Counterable.swift
//  PBike
//
//  Created by 陳 冠禎 on 2017/7/25.
//  Copyright © 2017年 陳 冠禎. All rights reserved.
//

import Foundation

protocol Counterable {
    func getValueOfUsingAndOnSite(from array: [Station], estimateValue: Int) -> (bikeOnSite: Int, bikeIsUsing: Int)
    func getEstimated(from apis: [API]) -> Int
    
}

extension Counterable {
   
    func getValueOfUsingAndOnSite(from array: [Station], estimateValue: Int) -> (bikeOnSite: Int, bikeIsUsing: Int) {
        let bikeOnSite = array.reduce(0) { $0 + $1.bikeOnSite! }.minLimit
        let bikeIsUsing = (estimateValue - bikeOnSite).minLimit
        return (bikeOnSite, bikeIsUsing)
    }
    
    func getEstimated(from apis: [API]) -> Int {
        var estimated = 0
        let maximum = 40_000
        
        for api in apis {
            switch api.city {
            case .taipei, .newTaipei:
                estimated += 10000
            case .taoyuan, .taichung, .changhua, .kaohsiung:
                estimated += 3000
            case .hsinchu:
                estimated += 1350
            case .tainan, .pingtung:
                estimated += 700
                
            default:
                estimated += 0
            }
        }
        return estimated >= maximum ? maximum : estimated
    }
}
