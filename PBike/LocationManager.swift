//
//  LocataionManager.swift
//  PBike
//
//  Created by 陳 冠禎 on 2016/12/29.
//  Copyright © 2016年 陳 冠禎. All rights reserved.
//


import MapKit
import CoreLocation

extension MapViewController: CLLocationManagerDelegate {
    
    func initializeLocationManager(){
        myLocationManager = CLLocationManager()
        myLocationManager.delegate = self
        myLocationManager.distanceFilter = kCLLocationAccuracyNearestTenMeters
        myLocationManager.desiredAccuracy = kCLLocationAccuracyBest
        
    }
    
    func setCurrentLocation(latDelta: Double, longDelta: Double) {
        let currentLocationSpan = MKCoordinateSpanMake(latDelta, longDelta)
        
        if let current = myLocationManager.location {
            location = current.coordinate
            print("取得使用者GPS位置")
        } else {
            let kaohsiungStationLocation = CLLocationCoordinate2D(latitude: 22.6384542, longitude: 120.3019452)
            location = kaohsiungStationLocation
            print("無法取得使用者位置、改取得高雄火車站GPS位置")
        }
        print("北緯：\(location.latitude) 東經：\(location.longitude)")
        let center = CLLocation(latitude: location.latitude, longitude: location.longitude)
        let currentRegion = MKCoordinateRegion(center: center.coordinate, span: currentLocationSpan)
        mapView.setRegion(currentRegion, animated: false)
    }
    
    
    @IBAction func locationArrowPressed(_ sender: AnyObject) {
        
        switch mapView.userTrackingMode {
            
        case .none:
            setTrackModeToFollow()
            
        case .follow:
            setTrackModeToFollowWithHeading()
            
        case .followWithHeading:
            setTrackModeNone()
        }
        
    }
    
    @objc(mapView:didChangeUserTrackingMode:animated:) func mapView(_ mapView: MKMapView, didChange mode: MKUserTrackingMode, animated: Bool) {
        
        switch (mapView.userTrackingMode) {
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
        mapView.setUserTrackingMode(MKUserTrackingMode.followWithHeading, animated: true)
    }
    
    func setTrackModeNone() {
        mapView.setUserTrackingMode(MKUserTrackingMode.none, animated: false)
    }
    
    func setTrackModeToFollow() {
        mapView.setUserTrackingMode(MKUserTrackingMode.follow, animated: false)
    }
    
    func authrizationStatus(completed: @escaping () -> Void ) {
        let authrizationStatus = CLLocationManager.authorizationStatus()
        switch authrizationStatus {
        case .notDetermined:
            myLocationManager.requestWhenInUseAuthorization()
            myLocationManager.startUpdatingLocation()
            
        case .denied: //提示可以在設定中打開
            
            let alartTitle = "定位權限已關閉"
            let alartMessage = "如要變更權限，請至 設定 > 隱私權 > 定位服務 開啟"
            
            let alertController = UIAlertController(title: alartTitle, message: alartMessage, preferredStyle:.alert)
            
            let okAction = UIAlertAction(title: "確認", style: .default, handler: nil)
            alertController.addAction(okAction)
            present(alertController,animated: true, completion: nil)
            
        case .authorizedWhenInUse:
            myLocationManager.startUpdatingLocation()
            
        default:
            print("Location authrization error")
            break
            
        }
        
        let myLocation = mapView.userLocation
        myLocation.title = "😏目前位置"
        completed()
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        let current = locations.last!
        let longitude = current.coordinate.longitude
        location.longitude = longitude >= 0 ? longitude : longitude + 360
        location.latitude = current.coordinate.latitude
        
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
