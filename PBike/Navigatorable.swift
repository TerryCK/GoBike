//
//  Navigator.swift
//  PBike
//
//  Created by 陳 冠禎 on 2017/6/7.
//  Copyright © 2017年 陳 冠禎. All rights reserved.
//

import MapKit

typealias Distance = Double
typealias TravelTime = String
typealias MapRequestCompleted = (Distance?, TravelTime) -> Void

protocol Navigatorable {
    func go(to destination: CustomPointAnnotation)
    func getETAData(to destination: CustomPointAnnotation, completeHandler: @escaping MapRequestCompleted)
}


extension Navigatorable where Self: MapViewController {
    
    func go(to destination: CustomPointAnnotation) {
        let mapItem = MKMapItem(placemark: destination.placemark)
        mapItem.name = " \(destination.subtitle!) (共享單車站)"
        
        print("mapItem.name \(String(describing: mapItem.name))")
        
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking]
        
        mapItem.openInMaps(launchOptions: launchOptions)
    }
    
    func getETAData(to destination: CustomPointAnnotation, completeHandler: @escaping MapRequestCompleted) {
        // Get current position
        let sourcePlacemark = MKPlacemark(coordinate: self.location, addressDictionary: nil)
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        
        // Get destination position
        let coordinate = destination.coordinate
        let destinationCoordinates = CLLocationCoordinate2DMake(coordinate.latitude, coordinate.longitude)
        let destinationPlacemark = MKPlacemark(coordinate: destinationCoordinates, addressDictionary: nil)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
        
        // Create request
        let request = MKDirections.Request()
        request.source = sourceMapItem
        request.destination = destinationMapItem
        request.transportType = MKDirectionsTransportType.automobile
        request.requestsAlternateRoutes = true
        let directions = MKDirections(request: request)
        
        directions.calculate { response, error in
            if let route = response?.routes.first {
                completeHandler(route.distance, route.expectedTravelTime.convertToHMS)
            } else  {
                completeHandler(nil, "無法取得資料")
                print("Error: \(error!)")
            }
            
        }
        
    }
}
