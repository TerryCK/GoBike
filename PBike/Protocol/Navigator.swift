//
//  Navigator.swift
//  PBike
//
//  Created by 陳 冠禎 on 2017/6/7.
//  Copyright © 2017年 陳 冠禎. All rights reserved.
//

import MapKit

protocol Navigatorable {
    func goto(destination selectedPin: CustomPointAnnotation!)
}

extension Navigatorable {
    internal func goto(destination selectedPin: CustomPointAnnotation!)   {
        guard let selectedPin = selectedPin else {
            return
        }
        let mapItem = MKMapItem(placemark: selectedPin.placemark)
        mapItem.name = " \(selectedPin.subtitle!) (公共自行車站)"
        print("mapItem.name \(String(describing: mapItem.name))")
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking]
        mapItem.openInMaps(launchOptions: launchOptions)
    }
}

