//
//  AppVisionCheck.swift
//  PBike
//
//  Created by 陳 冠禎 on 2016/12/29.
//  Copyright © 2016年 陳 冠禎. All rights reserved.
//

import UIKit

// APP check version and default
extension MapViewController {
    
    func appVersionInit() -> Int {
        
        var bikeOnService = 0
        
        self.topTitleimageView.setImage(UIImage(named: "GoBike"), for: UIControlState.normal)
        self.applink = "https://itunes.apple.com/tw/app/id1192891004?l=zh&mt=8"
        self.adUnitID = "ca-app-pub-3022461967351598/7816514110"
        self.mailtitle = "[GoBike]APP建議與回報"
        self.appId = "1192891004"
        
        guard let citys = delegate?.citys else {
            print("citys error ")
            return -1
        }
        
        for city in citys {
            switch city {
            case .Taipei, .NewTaipei:
                self.govName = "臺北市&新北市政府"
                self.dataOwner = "巨大機械工業股份有限公司"
                bikeOnService += 7500
                
            case .Taoyuan :
                self.govName = "桃園市政府"
                self.dataOwner = "巨大機械工業股份有限公司"
                bikeOnService += 2800
                
            case .Hsinchu :
                self.govName = "新竹市政府"
                self.dataOwner = "巨大機械工業股份有限公司"
                bikeOnService += 1350
                
            case .Taichung:
                self.govName = "台中市政府"
                self.dataOwner = "巨大機械工業股份有限公司"
                bikeOnService += 7000
                
            case .Changhua:
                self.govName = "彰化縣政府"
                self.dataOwner = "巨大機械工業股份有限公司"
                bikeOnService += 7000
                
            case .Tainan :
                self.govName = "台南市政府"
                self.dataOwner = "T-Bike營運團隊"
                bikeOnService += 500
                
            case .Kaohsiung :
                self.govName = "高雄市政府"
                self.dataOwner = "高雄捷運局"
                bikeOnService += 2600
                
            case .Pingtung :
                self.govName = "屏東縣政府"
                self.dataOwner = "高雄捷運局"
                bikeOnService += 600
                
            }
            
            bikeOnService = bikeOnService >= 45000 ? 40000 : bikeOnService
            
        }
        
        return bikeOnService
    }
    
}
