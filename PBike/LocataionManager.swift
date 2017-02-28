//
//  LocataionManager.swift
//  PBike
//
//  Created by 陳 冠禎 on 2016/12/29.
//  Copyright © 2016年 陳 冠禎. All rights reserved.
//


import MapKit
import CoreLocation

extension MapViewController:CLLocationManagerDelegate {
    
    func initializeLocationManager(){
        myLocationManager = CLLocationManager()
        myLocationManager.delegate = self
        myLocationManager.distanceFilter = kCLLocationAccuracyNearestTenMeters
        myLocationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func setCurrentLocation(latDelta:Double, longDelta:Double) {
        
        let currentLocationSpan:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, longDelta)
        
        print("myLocationManager.location , \(myLocationManager.location)")
        
        if let current = myLocationManager.location {
            location.latitude = current.coordinate.latitude
            location.longitude = current.coordinate.longitude
            print("取得使用者GPS位置")
        } else {
            
            #if CityBike
                //cibike Version
                location.latitude = 22.6384542
                location.longitude = 120.3019452
                print("無法取得使用者位置、改取得高雄火車站GPS位置")
            #else
                //Pbike Version
                location.latitude = 22.669248
                location.longitude = 120.4861926
                print("無法取得使用者位置、改取得屏東火車站GPS位置")
            #endif
            
        }
        
        print("北緯：\(location.latitude) 東經：\(location.longitude)")
        let center:CLLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        
        let currentRegion:MKCoordinateRegion = MKCoordinateRegion (center: center.coordinate, span:currentLocationSpan)
        
        self.mapView.setRegion(currentRegion, animated: false)
        

        print("currentRegion \(currentRegion)")
        
        
    }
    
    
    @IBAction func locationArrowPressed(_ sender: AnyObject) {
        
        switch (self.mapView.userTrackingMode) {
        case .none:
            setTrackModeToFollow()
            
        case .follow:
            setTrackModeToFollowWithHeading()
            
            
        case .followWithHeading:
            setTrackModeNone()
        }
    }
    
    @objc(mapView:didChangeUserTrackingMode:animated:) func mapView(_ mapView: MKMapView, didChange mode: MKUserTrackingMode, animated: Bool) {
        
        switch (self.mapView.userTrackingMode) {
        case .none:
            locationArrowImage.setImage(UIImage(named: "locationArrowNone"), for: UIControlState.normal)
            print("tracking mode has changed to none")
            
        case .followWithHeading:
            locationArrowImage.setImage(UIImage(named: "locationArrowFollewWithHeading"), for: UIControlState.normal)
            print("tracking mode has changed to followWithHeading")
            
        case .follow:
            locationArrowImage.setImage(UIImage(named: "locationArrow"), for: UIControlState.normal)
            print("tracking mode has changed to follow")
        }
        
        print("userTracking mode has been charged")
    }
    
    
    func setTrackModeToFollowWithHeading(){
        setCurrentLocation(latDelta: 0.01, longDelta: 0.01)
        self.mapView.setUserTrackingMode(MKUserTrackingMode.followWithHeading, animated: true)
    }
    
    func setTrackModeNone(){
        self.mapView.setUserTrackingMode(MKUserTrackingMode.none, animated: false)
    }
    
    func setTrackModeToFollow(){
        self.mapView.setUserTrackingMode(MKUserTrackingMode.follow, animated: false)
    }
    
    func authrizationStatus(){
        let authrizationStatus = CLLocationManager.authorizationStatus()
        switch authrizationStatus {
        case .notDetermined:
            myLocationManager.requestWhenInUseAuthorization()
            myLocationManager.startUpdatingLocation()
            
        case .denied: //提示可以在設定中打開
            let alertController = UIAlertController(title: "定位權限以關閉", message: "如要變更權限，請至 設定 > 隱私權 > 定位服務 開啟", preferredStyle:.alert)
            let okAction = UIAlertAction(title: "確認", style: .default, handler:nil)
            alertController.addAction(okAction)
            self.present(alertController,animated: true, completion:nil)
            
        case .authorizedWhenInUse:
            myLocationManager.startUpdatingLocation()
            print("開始定位")
            
        default:
            print("Location authrization error")
            break
            
        }
        
        let myLocation:MKUserLocation = mapView.userLocation
        myLocation.title = "😏目前位置"
        setCurrentLocation(latDelta: 0.03, longDelta: 0.03)
        print("location", location)
        delegate?.findLocateBikdAPI2Download(userLocation: location)
    }

    

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        let current = locations.last!
        let longitude = current.coordinate.longitude
        location.longitude = longitude >= 0 ? longitude : longitude + 360
        location.latitude = current.coordinate.latitude
        let checkLongitudeIsCorrect = location.longitude >= 0 ? "pass" : "NG! check out locationManager"
        print("check longitude is Correct? : ", checkLongitudeIsCorrect)
        delegate?.findLocateBikdAPI2Download(userLocation: location)
       
        print("did Update locations the location is ", location)
        
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            myLocationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: \(error)")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        myLocationManager.stopUpdatingLocation()
    }
    
}
