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



protocol Navigable {
    static var option: Navigator.Option { get }
    static func go(to destination: MKAnnotation)
    static func travelETA(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D, completionHandler: @escaping (Result<MKDirections.Response, Error>)-> Void)
}

struct Navigator: Navigable {
    
    enum Option: Int, CaseIterable, CustomStringConvertible {
        var description: String {
            switch self {
            case .apple:  return  "Apple Map"
            case .google: return "Google Map"
            }
        }
        
        case apple = 0, google
        
    }
    
    static var option: Option {
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: #function)
        }
        get {
            return Option(rawValue: UserDefaults.standard.integer(forKey: #function))!
        }
    }
    
    
    private static func goWithAppleMap(to destination: MKAnnotation) {
        guard let name = destination.title ?? "" else { return }
        let placemark = MKPlacemark(coordinate: destination.coordinate, addressDictionary: [name: ""])
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = "\(name)(洗衣精補充站)"
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
    }
    
    static func go(to destination: MKAnnotation) {
        
        
        switch option {
        case .google:
            guard let address = destination.subtitle ?? "",
                let query = address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
                    fallthrough
            }
            if let url = URL(string: "comgooglemaps://?saddr=&daddr=\(query)&directionsmode=driving") {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url) { isFinish in
                        if !isFinish {
                            goWithAppleMap(to: destination)
                        }
                    }
                } else {
                    UIApplication.shared.openURL(url)
                }
                return
            }
            fallthrough
        case .apple: goWithAppleMap(to: destination)
        }
    }
    
    
    static func travelETA(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D, completionHandler: @escaping (Result<MKDirections.Response, Error>)-> Void) {
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: source, addressDictionary: nil))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination, addressDictionary: nil))
        request.transportType = .automobile
        request.requestsAlternateRoutes = true
        
        MKDirections(request: request).calculate { response, error in
            
            if let response = response {
                completionHandler(.success(response))
            } else {
                completionHandler(.failure(error ?? ServiceError.SPIError))
            }
        }
    }
}

enum ServiceError: Error {
    case SPIError
}
