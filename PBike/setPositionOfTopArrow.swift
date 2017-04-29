//
//  setPositionOfTopArrow.swift
//  PBike
//
//  Created by 陳 冠禎 on 2016/12/29.
//  Copyright © 2016年 陳 冠禎. All rights reserved.
//

import UIKit

extension MapViewController {
    
    func setupRotatArrowBtnPosition() {
        let width = self.view.frame.size.width
        var left = -40
        
        print("width:\(width)")
        
        switch width {
            
        case 320: left = -30    //iPhone SE
        case 375: left = -60    //iPhone 7
        case 414: left = -70    //iPhone 7+
        case 768: left = -250
        case 1024: left = -380  //iPad直
        case 1366: left = -540  //iPad橫
        case 1536: left = -600
        case 2048: left = -700
        default: left = -320
            
        }
        
        self.rotationArrow.imageEdgeInsets = UIEdgeInsetsMake(0.0, CGFloat(left), 0.0, 0.0)
        print("left insert value:\(left)")
    }
    
}
