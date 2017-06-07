//
//  AddBlurEffect.swift
//  PBike
//
//  Created by 陳 冠禎 on 2016/12/29.
//  Copyright © 2016年 陳 冠禎. All rights reserved.
//

import UIKit

protocol NavigationBarBlurEffectable {
   func setNavigationBarBackgrondBlurEffect(to viewController: UIViewController)
}


extension NavigationBarBlurEffectable {
    
    func setNavigationBarBackgrondBlurEffect(to viewController: UIViewController) {
        // Add blur view
        let bounds = viewController.navigationController?.navigationBar.bounds as CGRect!
        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .light)) as UIVisualEffectView
        visualEffectView.frame = bounds!
        visualEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        viewController.navigationController?.navigationBar.backgroundColor = UIColor.clear
        viewController.navigationController?.navigationBar.addSubview(visualEffectView)
        
        viewController.navigationController?.navigationBar.sendSubview(toBack: visualEffectView)
    }
    
}
