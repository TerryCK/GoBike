//
//  googleAd.swift
//  PBike
//
//  Created by 陳 冠禎 on 2016/12/29.
//  Copyright © 2016年 陳 冠禎. All rights reserved.
//

import GoogleMobileAds

extension MapViewController: GADBannerViewDelegate{

    
    func setGoogleMobileAds(){
        let request: GADRequest = GADRequest()
        bannerView.rootViewController = self
        bannerView.adUnitID = adUnitID
        let test_iPhone:NSString = "09f8ecd06be28585d166f429d404b8044ccecdbe"
        let test_iPhones:String = "09f8ecd06be28585d166f429d404b8044ccecdbe"
        //        let test_iPad = ""
        request.testDevices = [test_iPhone, test_iPhones, kGADSimulatorID]
        bannerView.adSize = kGADAdSizeSmartBannerPortrait
        bannerView.load(request)
        print("Google Mobile Ads SDK version: \(GADRequest.sdkVersion())")
        print("TestID is \(request.testDevices!)")
    }
    
    private func adView(bannerView: GADBannerView!,
                        didFailToReceiveAdWithError error: GADRequestError!) {
        print("adView:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }
    
}

