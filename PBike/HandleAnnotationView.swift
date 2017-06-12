//
//  HandleAnnotationView.swift
//  PBike
//
//  Created by 陳 冠禎 on 2016/12/29.
//  Copyright © 2016年 陳 冠禎. All rights reserved.
//

import MapKit

protocol AnnotationHandleable {
    func getObjectArray(from stations: [Station], userLocation: CLLocation) -> [CustomPointAnnotation]
}

extension MapViewController: AnnotationHandleable, Counterable {
    
    func handleAnnotationInfo() {
        
        var objArray = [CustomPointAnnotation]()
        guard let stations = bikeModel?.stations else { return }
        
        //        let numberOfAPIs = delegate?.countOfAPIs
        //        let showPinInReginoDistance = 15.0
        //        print("numberOfAPIs:", numberOfAPIs!, "timesOfLoadingAnnotationView:",timesOfLoadingAnnotationView)
        //        guard timesOfLoadingAnnotationView == numberOfAPIs! else {
        //            timesOfLoadingAnnotationView += 1
        //            return
        //        }
        
        
        let estimate = self.estimatedBikeOnService
        let determined = getValueOfUsingAndOnSite(from: stations, estimateValue: estimate)
        self.bikesInStation = determined.bikeOnSite
        let bikeInUsing = determined.bikeIsUsing.currencyStyle
        
        self.currentPeopleOfRidePBike = bikeInUsing
        
        oldAnnotations.append(contentsOf: annotations)
        annotations.removeAll()
        
        let currentLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        objArray = getObjectArray(from: stations, userLocation: currentLocation)
        
        annotations = objArray
        //        print(showPinInReginoDistance,"km 內的annotation數量：", annotations.count)
        
        
            mapView.addAnnotations(self.annotations)
            mapView.removeAnnotations(self.oldAnnotations)
            oldAnnotations.removeAll()
    }
    
}




















//present annotationView
extension MapViewController {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        
        if annotation.isKind(of: MKUserLocation.self) { return nil }
        
        let identifier = "station"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
            
        } else {
            annotationView?.annotation = annotation
        }
        
        let customAnnotation = annotation as! CustomPointAnnotation
        let distance = Double(customAnnotation.distance!)!
        
        let width = distance > 100 ? 40 : 28
        let textSquare = CGSize(width:width, height: 40)
        let subTitleView:UILabel! = UILabel(frame: CGRect(origin: CGPoint.zero, size: textSquare))
        
        subTitleView.font = subTitleView.font.withSize(12)
        subTitleView.textAlignment = NSTextAlignment.right
        subTitleView.numberOfLines = 0
        subTitleView.textColor = UIColor.gray
        subTitleView.text = "\(distance) km"
        annotationView?.image =  customAnnotation.imageName
        
        let smallSquare = CGSize(width: 43, height: 43)
        let button = UIButton(frame: CGRect(origin: CGPoint.zero, size: smallSquare))
        
        button.setBackgroundImage(UIImage(named: "go"), for: UIControlState())
        button.addTarget(self, action: #selector(MapViewController.navigating), for: .touchUpInside)
        annotationView?.rightCalloutAccessoryView = button
        annotationView?.leftCalloutAccessoryView = subTitleView
        
        
        return annotationView
        
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let annotation = view.annotation as? CustomPointAnnotation else { return }
        self.selectedPin = annotation
        if let name = annotation.subtitle {
            print("You selected annotationView title: \(name)")
        }
    }
    
    func mapView(_ mapView: MKMapView , regionWillChangeAnimated: Bool){
        //method of detect span region to change size of annotation View
        //        print("region will change")
    }
    
}




