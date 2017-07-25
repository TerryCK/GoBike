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

        var objArray = [CustomPointAnnotation]()

        for (index, _) in stations.enumerated() {
            guard let object = getObjectAnnotation(from: stations, at: index, userLocation: userLocation) else { continue }
            objArray.append(object)
        }
        
        objArray.sort { Double($0.distance)! < Double($1.distance)! }
        if let region = region {
            objArray = objArray.filter { Int($0.distance)! < region  }
        }
        return objArray
    }

    private func getObjectAnnotation(from stations: [Station], at index: Int, userLocation: CLLocation) -> CustomPointAnnotation? {

        guard let subtitle = stations[index].name,
            let slot = stations[index].slot,
            let bikeOnSite = stations[index].bikeOnSite else { return nil }

        let title = "🚲:  \(bikeOnSite)   🅿️:  \(slot)"

        let latitude: CLLocationDegrees = stations[index].latitude
        let longitude: CLLocationDegrees = stations[index].longitude
        let bikeStationLocation = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let placemark = MKPlacemark(coordinate: bikeStationLocation, addressDictionary: [subtitle: ""])
        let destinationCoordinate = CLLocation(latitude: latitude, longitude: longitude)
        let distance = destinationCoordinate.distance(from: userLocation).km
        let pinImage = StationStatus.getImage(by: stations, at: index)

        let objectAnnotation = CustomPointAnnotation()

        objectAnnotation.title = title
        objectAnnotation.subtitle = "\(subtitle)"
        objectAnnotation.coordinate = bikeStationLocation

        objectAnnotation.placemark = placemark
        objectAnnotation.distance = "\(distance)"
        objectAnnotation.imageName = UIImage(named: pinImage)

        return objectAnnotation
    }
}