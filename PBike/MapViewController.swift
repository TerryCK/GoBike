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


protocol HandleMapSearch:class {
    func dropPinZoomIn(_ placemark:MKPlacemark)
}


class MapViewController: UIViewController, MKMapViewDelegate{

    @IBOutlet weak var bikeInStation: UILabel!
    @IBOutlet var mapView: MKMapView!
    var myLocationManager: CLLocationManager!
    var bikeStation = BikeStation()
    var bikeStations = BikeStation().stations
    var location = CLLocationCoordinate2D()
    var selectedPin: MKPlacemark?
    
    var resultSearchController: UISearchController!
    
//    func locationSearchFunc(){
//        let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "LocationSearchTable") as! LocationSearchTable
//        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
//        resultSearchController.searchResultsUpdater = locationSearchTable
//        let searchBar = resultSearchController!.searchBar
//        searchBar.sizeToFit()
//        searchBar.placeholder = "輸入車站名稱"
//        navigationItem.titleView = resultSearchController?.searchBar
//        resultSearchController.hidesNavigationBarDuringPresentation = false
//        resultSearchController.dimsBackgroundDuringPresentation = true
//        definesPresentationContext = true
//        locationSearchTable.mapView = mapView
//        locationSearchTable.handleMapSearchDelegate = self
//    }
    
    func getDirections(){
        guard let selectedPin = self.selectedPin else {return}
        let mapItem = MKMapItem(placemark: selectedPin)
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        mapItem.openInMaps(launchOptions: launchOptions)
      
    }
   
  
    @IBOutlet weak var locationArrowImage: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let downloadPBikeData = bikeStation.downloadPBikeDetails
        myLocationManager = CLLocationManager()
        myLocationManager.delegate = self
        myLocationManager.distanceFilter = kCLLocationAccuracyNearestTenMeters
        myLocationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        
        setCurrentLocation()
        //下載資料
        downloadPBikeData() {
        self.handleAnnotationInfo()
        }
        
        
        mapView.delegate = self
        mapView.mapType = .standard
        mapView.showsUserLocation = true
        mapView.isZoomEnabled = true
        mapView.showsCompass = false
        mapView.showsScale = false
        mapView.showsTraffic = true
    //set ui to load Downloaded code
    }

        
        
        // Do any additional setup after loading the view.
    
    

    func handleAnnotationInfo() {
        
        let stations = self.bikeStation.stations
        self.bikeStations = stations
        let numberOfStation = stations.count
        var location = CLLocationCoordinate2D()
        location = self.location
        
        let nunberOfUsingPBike = self.bikeStation.numberOfBikeIsUsing(station: stations, count: numberOfStation)
        print("目前有\(nunberOfUsingPBike)人正在騎PBIke")
        let bikesInStation = self.bikeStation.bikesInStation(station: stations, count: numberOfStation)
        print("站內腳踏車有\(bikesInStation)台")
        self.bikeInStation?.text = "目前有 \(nunberOfUsingPBike) 人正在騎PBIke"
        
        
        let currentLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        

        //set Annotation with xml imformation
        for index in 0...(stations.count - 1){
            // Add pin picture
            let objectAnnotation = CustomPointAnnotation()
            
            //處理座標
            let _latitude:CLLocationDegrees = Double(stations[index].latitude)!
            let _longitude:CLLocationDegrees = Double(stations[index].longitude)!
            let coordinats = CLLocationCoordinate2D(latitude: _latitude, longitude: _longitude)
            let destinationOfCoordinats = CLLocation(latitude: _latitude, longitude: _longitude)
            
            let distanceInMeter = destinationOfCoordinats.distance(from: currentLocation) / 1000
            let distanceInKm = String(format:"%.1f", distanceInMeter)
            let pinImage = self.bikeStation.statusOfStationImage(station: stations, index: index)
            let placemark = MKPlacemark(coordinate: coordinats, addressDictionary: [stations[index].name : ""])
            
            objectAnnotation.placemark = placemark
            objectAnnotation.coordinate = coordinats
            objectAnnotation.distance = distanceInKm

            objectAnnotation.title = "🚲:  \(stations[index].currentBikeNumber!)     🅿️:  \(stations[index].parkNumber!)"
            objectAnnotation.subtitle = "\(stations[index].name)"
            
            
    
            print("name: \(stations[index].name),   \(objectAnnotation.subtitle!)")
            objectAnnotation.imageName = UIImage(named: pinImage)
            
            self.mapView?.addAnnotation(objectAnnotation)
            
            
    }
}
    


    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation.isKind(of: MKUserLocation.self) {
            return nil}
        
        let identifier = "station"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if annotationView != nil {
            annotationView?.annotation = annotation
            
        }else {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
            let customAnnotation = annotation as! CustomPointAnnotation
            
            let textSquare = CGSize(width:20 , height: 40)
            let subTitleView:UILabel! = UILabel(frame: CGRect(origin: CGPoint.zero, size: textSquare))
            subTitleView.font = subTitleView.font.withSize(12)
            subTitleView.textAlignment = NSTextAlignment.right
            subTitleView.numberOfLines = 0
            subTitleView.textColor = UIColor.gray
            subTitleView.text = "\(customAnnotation.distance!) km"
            
            
            annotationView?.image =  customAnnotation.imageName
            
            let smallSquare = CGSize(width: 43, height: 43)
            let button = UIButton(frame: CGRect(origin: CGPoint.zero, size: smallSquare))
            button.setBackgroundImage(UIImage(named: "go"), for: UIControlState())
            button.addTarget(self, action: #selector(MapViewController.getDirections), for: .touchUpInside)
            annotationView?.rightCalloutAccessoryView = button
            annotationView?.leftCalloutAccessoryView = subTitleView
            
           
        }
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print("Annotation selected")
        
        if let annotation = view.annotation as? CustomPointAnnotation {
            self.selectedPin = annotation.placemark
            print("Your annotationView title: \(annotation.title)")
        }
    }
    
    
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
       
        self.mapView.setRegion(currentRegion, animated: true)
    
        print("currentRegion \(currentRegion)")
        locationArrowImage?.tintColor = UIColor.gray
    
        self.location = location
    }
        
        
    @IBAction func locationArrowPressed(_ sender: AnyObject) {
        locationArrowImage.tintColor = UIColor.purple
        self.setCurrentLocation()
        
    }

    @IBAction func searchBtnPressed(_ sender: AnyObject) {
//        locationSearchFunc()
    }
    


}




extension MapViewController: CLLocationManagerDelegate {
    //get the authorization for location
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let authrizationStatus = CLLocationManager.authorizationStatus()
        switch authrizationStatus {
            
        case .notDetermined:
            myLocationManager.requestWhenInUseAuthorization()
            myLocationManager.startUpdatingLocation()
            
        case .denied: //提示可以在設定中打開
            let alertController = UIAlertController(title: "定位權限以關閉", message: "如要變更權限，請至 設定 > 隱私權 > 定位服務 開啟", preferredStyle:.alert)
            let okAction = UIAlertAction(title: "確認", style: .default, handler:nil)
            alertController.addAction(okAction)
            self.present(alertController,animated: true, completion:nil)
            
        case .authorizedWhenInUse:
                myLocationManager.startUpdatingLocation()
                print("開始定位")

        default:
            print("Location authrization error")
                break
            }
        let myLocation:MKUserLocation = mapView.userLocation
        myLocation.title = "😏目前位置"
        print("取得定位資訊：\(myLocationManager.location)!")
    }


    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        myLocationManager.stopUpdatingLocation()
    
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
//        guard let location = locations.first else { return }
//        let span = MKCoordinateSpanMake(0.05, 0.05)
//        let region = MKCoordinateRegion(center: location.coordinate, span: span)
//        mapView.setRegion(region, animated: true)
        
        //        let currentLocation: CLLocation = locations[0] as CLLocation
        //        print("\(currentLocation.coordinate.latitude)")
        //        print(", \(currentLocation.coordinate.longitude)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            myLocationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: \(error)")
    }
    
}

//extension MapViewController: HandleMapSearch {
//    func dropPinZoomIn(_ placemark: MKPlacemark) {
//        //catch the pin
//        selectedPin = placemark
//        // clean existion pins
//        mapView.removeAnnotations(mapView.annotations)
//        let annotation = MKPointAnnotation()
//        annotation.coordinate = placemark.coordinate
//        annotation.title = placemark.name
//        
//        if let city = placemark.locality,
//            let state = placemark.administrativeArea {
//            annotation.subtitle = "\(city) \(state)"
//        }
//        
//        
//        mapView.addAnnotation(annotation)
//        let span = MKCoordinateSpanMake(0.05, 0.05)
//        let region = MKCoordinateRegionMake(placemark.coordinate, span)
//        mapView.setRegion(region, animated: true)
//        }
//}


class CustomPointAnnotation: MKPointAnnotation {
    var imageName: UIImage!
    var placemark: MKPlacemark!
    var distance: String!
    
}


