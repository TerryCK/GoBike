//
//  HandleAnnotationView.swift
//  PBike
//
//  Created by 陳 冠禎 on 2016/12/29.
//  Refactored by 陳 冠禎 on 2017/06/20.
//  Copyright © 2016年 陳 冠禎. All rights reserved.
//

import MapKit

extension MapViewController: AnnotationHandleable {
    
    func handleAnnotationInfo(stations: [Station], estimated: Int) -> (bikeOnSite: Int, bikeIsUsing: Int) {
        let currentLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        annotations = getObjectArray(from: stations, userLocation: currentLocation)
        return getValueOfUsingAndOnSite(from: stations, estimateValue: estimated)
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
        
        guard let customAnnotation = annotation as? CustomPointAnnotation else { return nil }
        
        
        let button = UIButton(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 43, height: 43)))
        
        button.setBackgroundImage(UIImage(named: "go"), for: .normal)
        button.addTarget(self, action: #selector(MapViewController.navigating), for: .touchUpInside)
        annotationView?.rightCalloutAccessoryView = button
        annotationView?.image = customAnnotation.image
        
        return annotationView
        
    }
    
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let annotation = view.annotation as? CustomPointAnnotation else { return }
        self.selectedPin = annotation
        NetworkActivityIndicatorManager.shared.networkOperationStarted()
        getETAData(to: annotation) { (distance, travelTime) in
            guard let distance = distance else { return }
            let width = distance > 100 ? 40 : 28
            let subTitleView = UILabel(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: width, height: 40)))
            subTitleView.font = subTitleView.font.withSize(12)
            subTitleView.textAlignment = NSTextAlignment.right
            subTitleView.numberOfLines = 0
            subTitleView.textColor = UIColor.gray
            subTitleView.text = "\(distance.km) km \n\(travelTime)"
            
            view.leftCalloutAccessoryView = subTitleView
            
            NetworkActivityIndicatorManager.shared.networkOperationFinished()
        }
        
        print("You selected annotationView title: \(annotation.subtitle ?? "title not find")")
        
    }
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated: Bool) {
        //method of detect span region to change size of annotation View
        //        print("region will change")
    }
    
}
