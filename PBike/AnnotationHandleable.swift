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
            let bikeStationLocation = CLLocationCoordinate2D(latitude: station.latitude, longitude: station.longitude)
            
            return CustomPointAnnotation(title: "🚲:  \(bikeOnSite)   🅿️:  \(slot)",
                                         subtitle: station.name ?? "",
                                         coordinate: bikeStationLocation,
                                         image: StationStatus.getImage(by: station),
                                         placemark: MKPlacemark(coordinate: bikeStationLocation, addressDictionary: [subtitle: ""]))
        }
    }
}
