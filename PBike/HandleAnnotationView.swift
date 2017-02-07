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
        let numberOfAPIs = delegate?.numberOfAPIs
        let showPinInReginoDistance = 15.0
        print("restrict distance", showPinInReginoDistance)
        
        guard timesOfLoadingAnnotationView == numberOfAPIs else {
            print("pass", timesOfLoadingAnnotationView)
            timesOfLoadingAnnotationView += 1
            return
        }
        
        guard let stations = delegate?.stations else { print("station nil"); return }
        
        self.bikeStations = stations
        var objArray = [CustomPointAnnotation]()
        
        let numberOfStation = stations.count
        
        var location = CLLocationCoordinate2D()
        location = self.location
        
        let numberBikeInUsing:Int? = stations.reduce(self.bikeOnService){$0 - $1.currentBikeNumber!}
        
        let bikesInStation = stations.reduce(0){$0 + $1.currentBikeNumber!}
        
        guard let nunberOfUsingBike = numberBikeInUsing else { print("nunberOfUsingPBike is nil"); return }
        print("nunberOfUsingBike: ",nunberOfUsingBike)
        let bikeInUsing = (nunberOfUsingBike <= 0) ? "0" : "\(nunberOfUsingBike)"
        self.currentPeopleOfRidePBike = bikeInUsing
        
        print("站內腳踏車有 \(bikesInStation) 台")
        print("目前有 \(nunberOfUsingBike) 人正在騎 \(self.bike)")
        print("目前站點有： \(numberOfStation) 座")
        
        let currentLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
//        guard let annotation = self.mapView?.annotations  else { return }
//        print("annotation count \(annotation.count)")
        oldAnnotations.append(contentsOf: annotations)
        annotations.removeAll()

        //prepare data, annotation view to display on the map
        for index in 0..<numberOfStation {
            let objectAnnotation = CustomPointAnnotation()
            
            //handle coordinate
            let _latitude:CLLocationDegrees = stations[index].latitude
            let _longitude:CLLocationDegrees = stations[index].longitude
            let coordinats = CLLocationCoordinate2D(latitude: _latitude, longitude: _longitude)
            let destinationOfCoordinats = CLLocation(latitude: _latitude, longitude: _longitude)
            
            objectAnnotation.coordinate = coordinats
            
            //handle distance
            let distanceInKM = destinationOfCoordinats.distance(from: currentLocation).km
            let distanceInKMStr = distanceInKM.string
            objectAnnotation.distance = distanceInKMStr
            
            
//            guard distanceInKM <= showPinInReginoDistance else {  continue  } //距離控制顯示數量annotation
            
            
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
                let parkNumber = stations[index].parkNumber else { return }

            objectAnnotation.subtitle = "\(name)"
            objectAnnotation.title = "🚲:  \(currentBikeNumber)   🅿️:  \(parkNumber)"
//            objectAnnotation.detail
            objArray.append(objectAnnotation)
            
        }
        
        objArray.sort{ Double($0.distance)! < Double($1.distance)! }
        annotations = objArray
        
//        print(showPinInReginoDistance,"km 內的annotation數量：", annotations.count)
        guard let mapView = self.mapView else { print("mapView not to self.mapView"); return }
        mapView.addAnnotations(annotations)
        mapView.removeAnnotations(oldAnnotations)
       
        if oldAnnotations.count != 0 {
        (mapView.annotations.count - 1) == oldAnnotations.count ? print("annotationViews clean success") : print("移除之前的 \(oldAnnotations.count) 個後，annotations： \(mapView.annotations.count) 個\n")
        }
        oldAnnotations.removeAll()
    }//loop
    
}


