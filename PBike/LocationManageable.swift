//
//  LocationManageable.swift
//  SupplyMap
//
//  Created by CHEN GUAN-JHEN on 2019/7/14.
//  Copyright © 2019 Yi Shiung Liu. All rights reserved.
//

import MapKit
import CoreLocation

protocol LocationManageable: UIViewController {
    var mapView: MKMapView! { get }
    var locationManager: CLLocationManager { get }
    func authorizationStatus()
    func setCurrentLocation(latDelta: Double, longDelta: Double)
    func setTracking(mode: MKUserTrackingMode)
}


extension LocationManageable {
    func authorizationStatus() {
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
            
        case .denied:
            let alertTitle = "定位權限已關閉"
            let alertMessage = "如要變更權限，請至設定 > 隱私權 > 定位服務 > 開啟"
            let alertController = UIAlertController(title: alertTitle,
                                                    message: alertMessage,
                                                    preferredStyle: .alert)
            let confirmAction = UIAlertAction(title: "確認", style: .default)
            
            alertController.addAction(confirmAction)
            present(alertController, animated: true, completion: nil)
            
        case .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
            
        default: break
        }
        
        setCurrentLocation(latDelta: 0.1, longDelta: 0.1)
        mapView.userLocation.title = "😏here"
    }
    
    func setCurrentLocation(latDelta: Double, longDelta: Double) {
        let currentUserLocation = locationManager.location ?? CLLocation(latitude: 25.04798, longitude: 121.517315)
        let coordinateSpan = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: longDelta)
        let coordinateRegion = MKCoordinateRegion(center: currentUserLocation.coordinate, span: coordinateSpan)
        mapView.setRegion(coordinateRegion, animated: false)
    }
    
    func setTracking(mode: MKUserTrackingMode) {
        if case .followWithHeading = mode { setCurrentLocation(latDelta: 0.01, longDelta: 0.01)}
        mapView.setUserTrackingMode(mode, animated: mode == .followWithHeading)
    }
}
