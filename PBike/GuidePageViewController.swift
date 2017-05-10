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
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let defaults = UserDefaults.standard
        let hasSharedApp = defaults.bool(forKey: "hasSharedApp")
        let hasViewedGuidePage = defaults.bool(forKey: "hasViewedGuidePage")
        
        
        // Display ads from google if user no shared, recommend this app
        if hasSharedApp {
            //            print("hasSharedApp: \(hasSharedApp)")
            defaults.set(true, forKey: "hasSharedApp")
        }
        setGoogleMobileAds()
        //present the guide page to first launch GoBike app.
        if !hasViewedGuidePage {
            if let guidePageViewController = storyboard?.instantiateViewController(withIdentifier: "GuidePageViewController") as? GuidePageViewController {
                present(guidePageViewController, animated: true, completion: nil )
            }
        }
        
    }
}
