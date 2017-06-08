//
//  AppVisionCheck.swift
//  PBike
//
//  Created by 陳 冠禎 on 2016/12/29.
//  Copyright © 2016年 陳 冠禎. All rights reserved.
//

import UIKit

protocol ConfigurationProtocol {
    var appId: String           { get }
    var adUnitID: String        { get }
    var mailtitle: String       { get }
    var govName: String         { get }
    var dataOwner: String       { get }
    var applink: String         { get }
    var rideBikeWithYou: String { get }
    
}

extension ConfigurationProtocol {
    var appId: String           { return "1192891004" }
    var mailtitle: String       { return "[GoBike]APP建議與回報" }
    var govName: String         { return "屏東縣政府" }
    var dataOwner: String       { return "高雄捷運局" }
    var applink: String         { return "https://itunes.apple.com/tw/app/id1192891004?l=zh&mt=8" }
    var rideBikeWithYou: String { return "人陪你騎腳踏車" }
}

protocol VersionCheckable {
    func setTopTitleImage(to view: UIViewController)
}

extension VersionCheckable {
    func setTopTitleImage(to viewController: UIViewController) {
        let vc = viewController as! MapViewController
        vc.topTitleimageView.setImage(UIImage(named: "GoBike"), for: UIControlState.normal)
        
    }
}
// APP check version and default
extension MapViewController: ConfigurationProtocol, VersionCheckable{
    
    func appVersionInit() -> Int {
        
        var bikeOnService = 0
        setTopTitleImage(to: self)
        
        guard let citys = bikeModel?.citys else {
            print("citys error ")
            return -1
        }
        
        for city in citys {
            switch city {
            case .taipei, .newTaipei:
                bikeOnService += 7500
                
            case .taoyuan:
                bikeOnService += 2800
                
            case .hsinchu:
                bikeOnService += 1350
                
            case .taichung:
                bikeOnService += 7000
                
            case .changhua:
                bikeOnService += 7000
                
            case .tainan:
                bikeOnService += 500
                
            case .kaohsiung:
                bikeOnService += 2600
                
            case .pingtung :
                bikeOnService += 600
                
            }
            
            bikeOnService = bikeOnService >= 40000 ? 40000 : bikeOnService
            
        }
        
        return bikeOnService
    }
    
}
