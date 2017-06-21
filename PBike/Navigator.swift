//
//  Navigator.swift
//  PBike
//
//  Created by 陳 冠禎 on 2017/6/7.
//  Copyright © 2017年 陳 冠禎. All rights reserved.
//

import MapKit

protocol Navigatorable {
    func go(to destination: CustomPointAnnotation!)
}

extension Navigatorable {
     func go(to destination: CustomPointAnnotation!) {
        guard let destination = destination else { return }
        let mapItem = MKMapItem(placemark: destination.placemark)
        mapItem.name = " \(destination.subtitle!) (共享單車站)"
        print("mapItem.name \(String(describing: mapItem.name))")
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking]
        mapItem.openInMaps(launchOptions: launchOptions)
    }
}

