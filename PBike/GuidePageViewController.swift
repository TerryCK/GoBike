//
//  GuidePageViewController.swift
//  PBike
//
//  Created by 陳 冠禎 on 2017/2/4.
//  Copyright © 2017年 陳 冠禎. All rights reserved.
//

import UIKit

class GuidePageViewController: UIViewController{
    
    @IBOutlet weak var guideImageView: UIImageView!
    
    @IBAction func guidePageCompleteBtn(_ sender: Any) {
        let defaults = UserDefaults.standard
        defaults.set(true, forKey: "hasViewedGuidePage")
        let hasViewedGuidePage = defaults.bool(forKey: "hasViewedGuidePage")
        print("hasViewedGuidePage:", hasViewedGuidePage)
        dismiss(animated: true, completion: nil)
    }
}


extension MapViewController {
    
    //get the authorization for location
    
    func performanceGuidePage() {
        
        let defaults = UserDefaults.standard
        let hasViewedGuidePage = defaults.bool(forKey: "hasViewedGuidePage")
        if !hasViewedGuidePage {
            if let guidePageViewController = storyboard?.instantiateViewController(withIdentifier: "GuidePageViewController") as? GuidePageViewController {
                present(guidePageViewController, animated: true, completion: nil )
            }
        }
       
    }
}
