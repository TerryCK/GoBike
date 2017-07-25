//
//  TitleImageSetable.swift
//  PBike
//
//  Created by 陳 冠禎 on 2017/7/25.
//  Copyright © 2017年 陳 冠禎. All rights reserved.
//

import MapKit
import UIKit

protocol TitleImageSetable {
    func setTopTitleImage(to view: UIViewController)
}

extension TitleImageSetable {
    
    func setTopTitleImage(to viewController: UIViewController) {
        if let vc = viewController as? MapViewController {
            vc.topTitleimageView.setImage(UIImage(named: "GoBike"), for: UIControlState.normal)
        }
    }
    
}
