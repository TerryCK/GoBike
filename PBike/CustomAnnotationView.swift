//
//  CustomAnnotationView.swift
//  PBike
//
//  Created by 陳 冠禎 on 2016/12/29.
//  Copyright © 2016年 陳 冠禎. All rights reserved.
//

import MapKit

final class CustomPointAnnotation: MKPointAnnotation {
    var image: UIImage!
    var placemark: MKPlacemark!
    
     init(title: String, subtitle: String, coordinate: CLLocationCoordinate2D, image: UIImage, placemark: MKPlacemark) {
        super.init()
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
        self.image = image
        self.placemark = placemark
        
    }
}
