//
//  GuidePageViewController.swift
//  PBike
//
//  Created by 陳 冠禎 on 2017/2/4.
//  Copyright © 2017年 陳 冠禎. All rights reserved.
//

import UIKit

final class GuidePageViewController: UIViewController {

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

    func performanceGuidePage() {
        guard !UserDefaults.standard.bool(forKey: "hasViewedGuidePage"),
         let guidePageViewController = storyboard?.instantiateViewController(withIdentifier: "GuidePageViewController") as? GuidePageViewController else {
            return
        }
        present(guidePageViewController, animated: true, completion: nil)
    }
}
