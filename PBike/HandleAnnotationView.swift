//
//  HandleAnnotationView.swift
//  PBike
//
//  Created by 陳 冠禎 on 2016/12/29.
//  Refactored by 陳 冠禎 on 2017/06/20.
//  Copyright © 2016年 陳 冠禎. All rights reserved.
//

import MapKit

protocol AnnotationHandleable: Counterable {
    func getObjectArray(from stations: [Station], userLocation: CLLocation, region: Int?) -> [CustomPointAnnotation]
}

extension MapViewController: AnnotationHandleable  {
    
    func handleAnnotationInfo(stations: [Station], estimated: Int) -> (bikeOnSite: Int,  bikeIsUsing: Int) {
        
        var objArray = [CustomPointAnnotation]()
        let determined = getValueOfUsingAndOnSite(from: stations, estimateValue: estimated)
        
        oldAnnotations.append(contentsOf: annotations)
        annotations.removeAll()
        
        let currentLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        
        objArray = getObjectArray(from: stations, userLocation: currentLocation)
        
        annotations = objArray
        
        mapView.addAnnotations(self.annotations)
        mapView.removeAnnotations(self.oldAnnotations)
        oldAnnotations.removeAll()
        
        return determined
    }
    
}




















//present annotationView
extension MapViewController {
    
    @objc func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        
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





