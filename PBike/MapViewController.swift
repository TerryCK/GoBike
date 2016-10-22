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

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UIGestureRecognizerDelegate{

    @IBOutlet weak var bikeInStation: UILabel!
    @IBOutlet var mapView: MKMapView!
    var myLocationManager: CLLocationManager!
    var bikeStation = BikeStation()
    var bikeStations = BikeStation().stations
    var location = CLLocationCoordinate2D()
   
  
    @IBOutlet weak var locationArrowImage: UIBarButtonItem!
    

    
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
            print("開始定位")
        }
        print("取得定位資訊：\(myLocationManager.location)!")

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myLocationManager = CLLocationManager()
        myLocationManager.delegate = self
        myLocationManager.distanceFilter = kCLLocationAccuracyNearestTenMeters
        myLocationManager.desiredAccuracy = kCLLocationAccuracyBest
        

        setCurrentLocation()
                

        //下載資料
        bikeStation.downloadPBikeDetails {
            //call to download xml from offical website
            print("PBick Station Data has been downloaded")
            
            let stations = self.bikeStation.stations
            self.bikeStations = stations
            let numberOfStation = stations.count
            var location = CLLocationCoordinate2D()
            location = self.location
            
            let nunberOfUsingPBike = self.bikeStation.numberOfBikeIsUsing(station: stations, count: numberOfStation)
            print("目前有\(nunberOfUsingPBike)人正在騎PBIke")
            let bikesInStation = self.bikeStation.bikesInStation(station: stations, count: numberOfStation)
            print("站內腳踏車有\(bikesInStation)台")
            self.bikeInStation.text = "所有站內腳踏車有  \(bikesInStation)  台"
            
            var placemark = [CustomPointAnnotation]()
            let currentLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
            //set Annotation with xml imformation
            for index in 0...(stations.count - 1){
                // Add pin picture
                let objectAnnotation = CustomPointAnnotation()
                //處理座標
                let _latitude:CLLocationDegrees = Double(stations[index].latitude)!
                let _longitude:CLLocationDegrees = Double(stations[index].longitude)!
                let coordinats = CLLocationCoordinate2D(latitude: _latitude, longitude: _longitude)
                let stationCoordinats = CLLocation(latitude: _latitude, longitude: _longitude)
                let distanceInMeter = stationCoordinats.distance(from: currentLocation) / 1000
                let distanceInKm = String(format:"%.1f", distanceInMeter)
                let pinImage = self.bikeStation.statusOfStationImage(station: stations, index: index)
                
                
                objectAnnotation.coordinate = coordinats
                objectAnnotation.title = "🚲:\(stations[index].currentBikeNumber!)     🅿️:\(stations[index].parkNumber!) "
                objectAnnotation.subtitle = "\(stations[index].name) (\(distanceInKm)km)"
                
                print("name: \(stations[index].name),   \(objectAnnotation.subtitle!)")
                objectAnnotation.imageName = UIImage(named: pinImage)
                
                placemark.append(objectAnnotation)
                self.mapView.addAnnotation(objectAnnotation)
                
                
            }
//            self.mapView.showAnnotations(placemark, animated: true)
            //set ui to load Downloaded code
        }
        
        mapView.delegate = self
        mapView.mapType = .standard
        mapView.showsUserLocation = true
        mapView.isZoomEnabled = true
        mapView.showsCompass = false
        mapView.showsScale = false
        mapView.showsTraffic = true

        // Do any additional setup after loading the view.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        myLocationManager.stopUpdatingLocation()
    }

    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
//        let currentLocation: CLLocation = locations[0] as CLLocation
       
//GPS依移動 更新位置資訊
//        print("\(currentLocation.coordinate.latitude)")
//        print(", \(currentLocation.coordinate.longitude)")
    }

    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation.isKind(of: MKUserLocation.self) {
            return nil
    }

        let identifier = "station"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
    
        
        if annotationView != nil {

            annotationView?.annotation = annotation

            
        }else {
            
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            
            annotationView?.canShowCallout = true
            
            
            //Resize image

            let pinImage = annotation as! CustomPointAnnotation

            annotationView?.image = pinImage.imageName
        }

        return annotationView
    }
    
    func CGRectMake(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) -> CGRect {
        return CGRect(x: x, y: y, width: width, height: height)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    
    func setCurrentLocation() {
    
        let latDelta = 0.05
        let longDelta = 0.05
        let currentLocationSpan:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, longDelta)
        var location = CLLocationCoordinate2D()
        
        if let current = myLocationManager.location {
            location.latitude = Double(current.coordinate.latitude)
            location.longitude = Double(current.coordinate.longitude)
            print("取得使用者GPS位置")
        }else{
            
            location.latitude = 22.669248
            location.longitude = 120.4861926
            print("無法取得使用者位置、改取得屏東火車站GPS位置")
        }
        
        print("北緯：\(location.latitude) 東經：\(location.longitude)")
        let center:CLLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        
        let currentRegion:MKCoordinateRegion = MKCoordinateRegion (center: center.coordinate, span:currentLocationSpan)
        
        mapView.setRegion(currentRegion, animated: true)
        print("currentRegion \(currentRegion)")
        locationArrowImage.tintColor = UIColor.gray
        self.location = location
}
    @IBAction func locationArrowPressed(_ sender: AnyObject) {
        locationArrowImage.tintColor = UIColor.purple
        self.setCurrentLocation()
        
    }
//    
//    func didDragMap(gestureRecognizer: UIGestureRecognizer) {
//        if (gestureRecognizer.state == UIGestureRecognizerState.began) {
//            
//            print("Map drag began")
//        }
//        
//        if (gestureRecognizer.state == UIGestureRecognizerState.ended) {
//            print("Map drag ended")
//            locationArrowImage.tintColor = UIColor.black
//        }
//    }
//    
//    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//        return true
//    }

}

class CustomPointAnnotation: MKPointAnnotation {
    var imageName: UIImage!
    
}


