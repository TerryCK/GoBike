//
//  HandleAnnotationView.swift
//  PBike
//
//  Created by 陳 冠禎 on 2016/12/29.
//  Copyright © 2016年 陳 冠禎. All rights reserved.
//

import MapKit

extension MapViewController {
    
    func handleAnnotationInfo() {
        timesOfLoadingAnnotationView += 1
        guard let stations = delegate?.stations else { print("station nil"); return }
        self.bikeStations = stations
        var objArray = [CustomPointAnnotation]()
        
        let numberOfStation = stations.count
        
        var location = CLLocationCoordinate2D()
        location = self.location
    
        let _nunberOfUsingPBike = delegate?.numberOfBikeIsUsing(station: stations, count: numberOfStation)
        
        let bikesInStation = delegate?.bikesInStation(station: stations, count: numberOfStation)
        
        var bikeInUsing = ""
        
        guard let nunberOfUsingPBike = _nunberOfUsingPBike else { print("nunberOfUsingPBike is nil"); return }
        self.bikeinusing += nunberOfUsingPBike
        if timesOfLoadingAnnotationView == delegate?.numberOfAPIs {
            
            switch nunberOfUsingPBike {
                
            case 0...15000:
                bikeInUsing = " \(nunberOfUsingPBike) "
                
            default:
                bikeInUsing = "0"
            }
            
            self.currentPeopleOfRidePBike = "\(bikeInUsing)"
        }
        
            
        print("站內腳踏車有\(bikesInStation)台")
        print("目前有\(nunberOfUsingPBike)人正在騎\(self.bike)")
        print("目前站點有：\(numberOfStation)座")
        
        
        
        let currentLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        guard let annotation = self.mapView?.annotations  else { return }
        
        print("annotation count \(annotation.count)")
        
        
        oldAnnotations.append(contentsOf: annotations)
        if timesOfLoadingAnnotationView == 2 {
            annotations.removeAll() }
      
        for index in 0..<numberOfStation {
            
            let objectAnnotation = CustomPointAnnotation()
            
            //handle coordinate
            let _latitude:CLLocationDegrees = stations[index].latitude
            let _longitude:CLLocationDegrees = stations[index].longitude
            
            let coordinats = CLLocationCoordinate2D(latitude: _latitude, longitude: _longitude)
            let destinationOfCoordinats = CLLocation(latitude: _latitude, longitude: _longitude)
            
            objectAnnotation.coordinate = coordinats
            
            //handle distance
            let distanceInKM = destinationOfCoordinats.distance(from: currentLocation).divided(by: 1000)
            let distanceInKMStr = String(format:"%.1f", distanceInKM)
            objectAnnotation.distance = distanceInKMStr
            
            guard distanceInKM <= 5.0 else {  continue  } //距離控制顯示數量annotation
            
            
            //handle name for navigation
            if let name = stations[index].name {
                
                let placemark = MKPlacemark(coordinate: coordinats, addressDictionary:[name: ""])
                objectAnnotation.placemark = placemark
            }
            //handle picture of pin
            if let pinImage = delegate?.statusOfStationImage(station: stations, index: index){
                objectAnnotation.imageName = UIImage(named: pinImage) }
            
            
            
            //handle bike station's name
            guard let currentBikeNumber = stations[index].currentBikeNumber,
                let name = stations[index].name,
                let parkNumber = stations[index].parkNumber  else { return }
            
            objectAnnotation.subtitle = "\(name)"
            objectAnnotation.title = "🚲:  \(currentBikeNumber)   🅿️:  \(parkNumber)"
            objArray.append(objectAnnotation)
            
        }
        
       objArray.sort{ Double($0.distance)! < Double($1.distance)! }
       annotations = objArray
       
     //check sort loop
//        for index in 0..<3 {
//            
//            if let foo = annotations as? [CustomPointAnnotation] {
//                
//                print("name:",foo[index].subtitle! ,"distance:",foo[index].distance)
//            }
//        }
//        
        print("5km 內的annotation數量：", annotations.count)
        guard let mapView = self.mapView else { print("mapView not to self.mapView"); return }

        mapView.addAnnotations(annotations)
        
//        for test in mapView.annotations {
//            print(test.subtitle)
//        }
        if timesOfLoadingAnnotationView == delegate?.numberOfAPIs {
            
            mapView.removeAnnotations(oldAnnotations)
            
            print("oldAnnotations數量", oldAnnotations.count)
            oldAnnotations.removeAll()
            
            print("移除舊後，annotations的數量： \(mapView.annotations.count)\n")
        }
        
    }
    
}
