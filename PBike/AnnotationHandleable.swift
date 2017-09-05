//
//  AnnotationViewModel.swift
//  PBike
//
//  Created by 陳 冠禎 on 2017/6/12.
//  Copyright © 2017年 陳 冠禎. All rights reserved.
//

import Foundation
import MapKit

protocol AnnotationHandleable: Counterable {
    func getObjectArray(from stations: [Station], userLocation: CLLocation, region: Int?) -> [CustomPointAnnotation]
}

extension AnnotationHandleable {
    
    func getObjectArray(from stations: [Station], userLocation: CLLocation, region: Int? = nil) -> [CustomPointAnnotation] {
        return stations.flatMap { station in
            guard let subtitle = station.name, let slot = station.slot, let bikeOnSite = station.bikeOnSite else { return nil }
            let title = "🚲:  \(bikeOnSite)   🅿️:  \(slot)"
            
            let latitude: CLLocationDegrees = station.latitude
            let longitude: CLLocationDegrees = station.longitude
            let bikeStationLocation = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let placemark = MKPlacemark(coordinate: bikeStationLocation, addressDictionary: [subtitle: ""])
            let pinImage = StationStatus.getImage(by: station)
            
            return CustomPointAnnotation(title: title, subtitle: subtitle, coordinate: bikeStationLocation, image: pinImage, placemark: placemark)
        }
    }
}
