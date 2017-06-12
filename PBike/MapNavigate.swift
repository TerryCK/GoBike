//
//  MapNavigate.swift
//  PBike
//
//  Created by 陳 冠禎 on 2016/12/29.
//  Copyright © 2016年 陳 冠禎. All rights reserved.
//

import MapKit


extension MapViewController: Navigatorable {
    
     func navigating() {
        guard let destination = self.selectedPin else {
            return
        }
        go(to: destination)
    }
    
    //map information
    func mapViewInfoCustomize() {
        mapView.delegate = self
        mapView.mapType = .standard
        mapView.showsUserLocation = true
        mapView.isZoomEnabled = true
        mapView.showsCompass = false
        mapView.showsScale = false
        mapView.showsTraffic = false
    }
    
}
