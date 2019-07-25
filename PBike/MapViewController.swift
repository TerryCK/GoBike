//
//  MapViewController.swift
//  GoBike
//
//  Created by 陳 冠禎 on 2016/10/19.
//  Refactored by 陳 冠禎 on 2017/06/20.
//  Copyright © 2016年 陳 冠禎. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import GoogleMobileAds

final class MapViewController: UIViewController, MKMapViewDelegate, NavigationBarBlurEffectable, MotionEffectable, BikeStationModelProtocol, ConfigurationProtocol {
    
    var resultSearchController: UISearchController!
    
    @IBOutlet var mapView: MKMapView! {
        didSet {
            mapView.delegate = self
            mapView.mapType = .standard
            mapView.showsUserLocation = true
            mapView.isZoomEnabled = true
            mapView.showsCompass = true
            mapView.showsScale = true
            mapView.showsTraffic = false
        }
    }
    
    @IBOutlet weak var updateTimeLabel: UILabel! {
        didSet {
            updateTimeLabel.layer.borderWidth = 0
            updateTimeLabel.layer.cornerRadius = 8
            updateTimeLabel.clipsToBounds = true
        }
    }
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bannerView: GADBannerView!
    @IBOutlet weak var timerLabel: UIButton!
    @IBOutlet weak var rotationArrow: UIButton!
    @IBOutlet weak var topTitleimageView: UIButton!
    @IBOutlet weak var locationArrowImage: UIButton!
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    var effect: UIVisualEffect!
    var myLocationManager: CLLocationManager!
    
    
    var location = CLLocationCoordinate2D()
    var selectedPin: CustomPointAnnotation?
    var bikeInUsing = ""
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    var annotations: [CustomPointAnnotation] = [] {
        didSet {
            DispatchQueue.main.async {
                self.mapView.addAnnotations(self.annotations)
                self.mapView.removeAnnotations(oldValue)
                print(self.mapView.annotations.count)
            }
            
        }
    }
    
    
    let yDelta: CGFloat = 500
    
    var tableViewCanDoNext = true
    var tableViewIsShowing = false
    
    @IBAction func segbtnPress(_ sender: UISegmentedControl) {
        
        let nearbyTitle = sender.titleForSegment(at: sender.selectedSegmentIndex)
        isNearbyMode = nearbyTitle == "附近" ? true : false
        print(nearbyTitle ?? "")
        timeCounter = reloadtime
        self.updatingDataByServalTime()
        
    }
    
    //     time relation parameter
    let showTheResetButtonTime = 3
    var time = 1800
    var timer = Timer()
    var rentedTimer = Timer()
    
    // in second
    var reloadtime = 360
    
    var timeCounter: Int = 360 {
        didSet {
            if timeCounter != reloadtime {
                updateTimeLabel.text = "\(timeCounter) 秒前更新"
            }
            
        }
    }
    
    var timerStatusReadyTo: TimerStatus = .play
    public var timerCurrentStatusFlag: TimerStatus = .reset
    var timeInPause = 5
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configuration()
        //        mapSearcherConfig()
    }
    
    func setupAuthrizationStatus() {
        self.authrizationStatus { [unowned self] in
            let delta = 0.03
            self.setCurrentLocation(latDelta: delta, longDelta: delta)
            self.updatingDataByServalTime()
        }
    }
    
    @objc func updatingDataByServalTime() {
        if timeCounter != reloadtime {
            timeCounter += 1
            
        } else {
            
            timer.invalidate()
            updateTimeLabel.text = "資料更新中"
            getData(userLocation: location)
            self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(MapViewController.updatingDataByServalTime), userInfo: nil, repeats: true)
            
            timeCounter = 0
        }
    }
    
    var isNearbyMode = true
    
    private func getData(userLocation: CLLocationCoordinate2D) {
        NetworkActivityIndicatorManager.shared.networkOperationStarted()
        segmentedControl.isEnabled = false
        NetworkActivityIndicatorManager.shared.networkOperationStarted()
        getStations(userLocation: userLocation, isNearbyMode: isNearbyMode) { [unowned self] (stations, apis) in
            NetworkActivityIndicatorManager.shared.networkOperationFinished()
            let estimated = self.getEstimated(from: apis)
            
            let determined = self.handleAnnotationInfo(stations: stations, estimated: estimated)
            
            self.bikeInUsing = determined.bikeIsUsing.currencyStyle
            let bikeOnStation = determined.bikeOnSite.currencyStyle
            
            self.shownData(bikeOnStation: bikeOnStation, bikeIsUsing: self.bikeInUsing, stations: stations, apis: apis)
            NetworkActivityIndicatorManager.shared.networkOperationFinished()
            self.segmentedControl.isEnabled = true
            
        }
    }
    
    private func shownData(bikeOnStation: String, bikeIsUsing: String, stations: [Station], apis: [API]) {
        
        print("\n站內腳踏車有: \(bikeOnStation) 台")
        print("目前有: \(bikeIsUsing) 人正在騎共享單車")
        print("目前地圖中有: \(stations.count.currencyStyle) 座")
        print("\n目前顯示城市名單:")
        print("  *****  ", terminator: "")
        apis.forEach { print($0.city, terminator: ", ") }
        print("  *****  \n")
        
        tableView.reloadData()
    }
    
    private func configuration() {
        performanceGuidePage()
        initializeLocationManager()
        setupRotatArrowBtnPosition()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundView?.alpha = 0
        viewConfriguation()
        #if Release
        setGoogleMobileAds()
        #endif
        setupAuthrizationStatus()
    }
    
    private func viewConfriguation() {
        effect = visualEffectView.effect
        visualEffectView.effect = nil
        applyMotionEffect(toView: tableView, updateTimeLabel, segmentedControl, magnitude: -20)
    }
    
}

extension MapViewController: HandleMapSearch {
    
    func mapSearcherConfig() {
        let uiBarbtnitem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(MapViewController.callSearcher))
        navigationItem.rightBarButtonItems?.insert(uiBarbtnitem, at: 0)
        
    }
    
    @objc func callSearcher() {
        let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "LocationSearchTable") as! LocationSearchTable
        print("call searcher")
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController.searchResultsUpdater = locationSearchTable
        
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for places"
        
        navigationItem.titleView = searchBar
        resultSearchController.hidesNavigationBarDuringPresentation = false
        resultSearchController.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        locationSearchTable.mapView = mapView
        locationSearchTable.handleMapSearchDelegate = self
    }
    
    func dropPinZoomIn(_ placemark: MKPlacemark) {
        // cache the pin
        
        // clear existing pins
        mapView.removeAnnotations(mapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        
        if let city = placemark.locality,
            let state = placemark.administrativeArea {
            annotation.subtitle = "\(city) \(state)"
        }
        
        mapView.addAnnotation(annotation)
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: placemark.coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
}
