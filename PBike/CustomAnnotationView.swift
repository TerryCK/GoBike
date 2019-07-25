//
//  CustomAnnotationView.swift
//  PBike
//
//  Created by 陳 冠禎 on 2016/12/29.
//  Copyright © 2016年 陳 冠禎. All rights reserved.
//

import MapKit

final class CustomPointAnnotation: MKPointAnnotation {
    let status: StationStatus
    
    init(title: String, subtitle: String, coordinate: CLLocationCoordinate2D, status: StationStatus) {
        self.status = status
        super.init()
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
    }
}
