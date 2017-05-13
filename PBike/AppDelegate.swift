//
//  AppDelegate.swift
//  PBike
//
//  Created by 陳 冠禎 on 2016/10/16.
//  Copyright © 2016年 陳 冠禎. All rights reserved.
//

import UIKit
import Firebase
import GoogleMobileAds
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    weak var timerHandlerDelegate: TimerHandlerDelegate?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        Fabric.sharedSDK().debug = true
        Fabric.with([Crashlytics.self])
        
        
        FIRApp.configure()
        
        
        
        //        #if CityBike  //city bike
        //
        //            GADMobileAds.configure(withApplicationID: "ca-app-pub-3022461967351598~8088837314")
        //
        //
        //        #elseif PBike //PBike
        //
        //            GADMobileAds.configure(withApplicationID: "ca-app-pub-3022461967351598~3503324111")
        //
        //        #else //GoBike
        
        GADMobileAds.configure(withApplicationID: "ca-app-pub-3022461967351598~6339780911")
        
        //        #endif
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        print("app did enter backgruond")
        
        guard let flag = timerHandlerDelegate?.timerCurrentStatusFlag else {
            print("flag != timerHandlerDelegate?.timerCurrentStatusFlag")
            return
        }
        print("get flag")
        guard flag == .Play else {
            return
        }
        
        timerHandlerDelegate = MapViewController()
        let now = Data()
        let defaults = UserDefaults.standard
        
        defaults.set(now, forKey: "now")
        print(defaults.data(forKey: "now"))
        
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        
        //save timer current time
        
        //        if timer
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
//        print("app did enter backgruond")
//        timerHandlerDelegate = MapViewController()
//        guard let flag = timerHandlerDelegate?.timerCurrentStatusFlag else {
//            return
//        }
//        print("get flag")
//        guard flag == .Play else {
//            return
//        }
//        
//        
//        let now = Data()
//        let defaults = UserDefaults.standard
//        
//        defaults.set(now, forKey: "now")
//        print(defaults.data(forKey: "now"))
    }
    
    
}

