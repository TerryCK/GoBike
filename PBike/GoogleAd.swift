//
//  googleAd.swift
//  GoBike
//
//  Created by 陳 冠禎 on 2016/12/29.
//  Copyright © 2016年 陳 冠禎. All rights reserved.
//

import GoogleMobileAds
extension ConfigurationProtocol where Self: GADBannerViewDelegate {
    var adUnitID: String        { return "ca-app-pub-3022461967351598/7816514110" }
}

extension MapViewController: GADBannerViewDelegate {
    
    func setGoogleMobileAds(){
        let request: GADRequest = GADRequest()
        bannerView.rootViewController = self
        bannerView.adUnitID = adUnitID
        
//        let test_iPhone = "0e67b18dc7d5d61c450ba3267ffdbfc9"
//        let test_iPad = "abef55fc4559d02aa14c63328e63a5239abba600"
        
        request.testDevices = [kGADSimulatorID]
        
        bannerView.adSize = kGADAdSizeSmartBannerPortrait
        bannerView.load(request)
        
        //        print("Google Mobile Ads SDK version: \(GADRequest.sdkVersion())")
        //        print("TestID is \(request.testDevices!)")
    }
    
    private func adView(bannerView: GADBannerView!,
                        didFailToReceiveAdWithError error: GADRequestError!) {
        //        print("adView:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }
    
}

