//
//  MapViewController.swift
//  PBike
//
//  Created by 陳 冠禎 on 2016/10/19.
//  Copyright © 2016年 陳 冠禎. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate{

    @IBOutlet weak var mapView: MKMapView!
    var myLocationManager: CLLocationManager!
    var bikeStation = BikeStation()
    var bikeStations = BikeStation().stations
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if CLLocationManager.authorizationStatus() == .notDetermined{
            myLocationManager.requestWhenInUseAuthorization()
        
            myLocationManager.startUpdatingLocation()
        }
        else if CLLocationManager.authorizationStatus() == .denied{
            //提示可以在設定中打開
            let alertController = UIAlertController(title: "定位權限以關閉", message: "如要變更權限，請至 設定 > 隱私權 > 定位服務 開啟", preferredStyle:.alert)
            let okAction = UIAlertAction(title: "確認", style: .default, handler:nil)
            alertController.addAction(okAction)
            self.present(alertController,animated: true, completion:nil)
        }
        else if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            myLocationManager.startUpdatingLocation()
        }

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myLocationManager = CLLocationManager()
        myLocationManager.delegate = self
        myLocationManager.distanceFilter = kCLLocationAccuracyNearestTenMeters
        myLocationManager.desiredAccuracy = kCLLocationAccuracyBest
        

        self.mapView.delegate = self
        self.mapView.mapType = .standard
        self.mapView.showsUserLocation = true
        self.mapView.isZoomEnabled = true
        
        let latDelta = 0.05
        let longDelta = 0.05
        let currentLocationSpan:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, longDelta)
        
        let currentLocationLatitude = Double((myLocationManager.location?.coordinate.latitude)!)
        let currentLocationLongitude = Double((myLocationManager.location?.coordinate.longitude)!)
        
        let center:CLLocation = CLLocation(latitude: currentLocationLatitude, longitude: currentLocationLongitude)
        
        let currentRegion:MKCoordinateRegion = MKCoordinateRegion (center: center.coordinate, span:currentLocationSpan)
        self.mapView.setRegion(currentRegion, animated: true)
       
     
        
        
        //下載資料
        bikeStation.downloadPBikeDetails {
            //call to download xml from offical website
            let stations = self.bikeStation.stations
            self.bikeStations = stations
            let numberOfStation = stations.count
        
            
            
            let nunberOfUsingPBike = self.bikeStation.numberOfBikeIsUsing(station: stations, count: numberOfStation)
            print("目前有\(nunberOfUsingPBike)人正在騎PBIke")
            //set ui to load Downloaded code
        }

        // Do any additional setup after loading the view.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        myLocationManager.stopUpdatingLocation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        let currentLocation: CLLocation = locations[0] as CLLocation
       
       
        print("\(currentLocation.coordinate.latitude)")
        print(", \(currentLocation.coordinate.longitude)")
    }

//    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//        let identifier = "station"
//        if annotation.isKind(of: MKUserLocation.self) {
//            return nil
//    }
//        var annotationView:MKPinAnnotationView? = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView
//        
//        if annotationView == nil {
//            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
//            annotationView?.canShowCallout = true
//        }
//        annotationView?.pinTintColor = UIColor.orange
//        
//        return annotationView
//    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
