//
//  AppVisionCheck.swift
//  Renamed ConfigurationProtocol.swift 2017/6/20
//
//  Created by 陳 冠禎 on 2016/12/29.
//  Refactored by 陳 冠禎 on 2017/06/20.
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
    var rideBikeWithYou: String { return "人正在騎共享單車" }
    
    
   
    
    
    
}
