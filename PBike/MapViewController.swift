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
import Cluster

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didChange mode: MKUserTrackingMode, animated: Bool) {
        locationArrowImage.setImage(mode.arrowImage, for: .normal)
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        guard gestureRecognizerStatus == .release else { return }
        clusterManager.reload(mapView: mapView)
    }
    
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        views.forEach { $0.alpha = 0 }
        UIView.animate(withDuration: 0.35,
                       animations: { views.forEach { $0.alpha = 1 } }
        )
    }
}

final class MapViewController: UIViewController, NavigationBarBlurEffectable, MotionEffectable, BikeStationModelProtocol, ConfigurationProtocol, LocationManageable, Navigatorable, CLLocationManagerDelegate {
    
    lazy var locationManager : CLLocationManager = {
        $0.delegate = self
        $0.distanceFilter = kCLLocationAccuracyNearestTenMeters
        $0.desiredAccuracy = kCLLocationAccuracyBest
        return $0
    }(CLLocationManager())
    
    @objc func navigating() {
        mapView.selectedAnnotations.first.map(go)
    }
    
    @IBAction func locationArrowPressed(_ sender: AnyObject) {
        mapView.setUserTrackingMode(mapView.userTrackingMode.nextMode, animated: true)
    }
    
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
    
    
    var location = CLLocationCoordinate2D()
    var selectedPin: CustomPointAnnotation?
    var bikeInUsing = ""
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    private let clusterManager: ClusterManager = {
        $0.maxZoomLevel = 17
        $0.minCountForClustering = 3
        $0.clusterPosition = .nearCenter
        return $0
    }(ClusterManager())
    
    var annotations: [CustomPointAnnotation] = [] {
        didSet {
            clusterManager.removeAll()
            clusterManager.add(annotations)
            clusterManager.reload(mapView: mapView)
        }
    }
    
    
    let yDelta: CGFloat = 500
    
    var tableViewCanDoNext = true
    var tableViewIsShowing = false
    
    @IBAction func segbtnPress(_ sender: UISegmentedControl) {
        isNearbyMode = sender.titleForSegment(at: sender.selectedSegmentIndex) == "附近"
    }
    
    lazy var countDownTimer: GCDTimer = {
        return GCDTimer(interval: .seconds(1), repeating: true, queue: DispatchQueue(label: "\(self).queue"), onTimeout: { (timer) in
            DispatchQueue.main.async {
                self.autoUpdate(timeInterval: 30)
            }
        })
    }()
    //     time relation parameter
    let showTheResetButtonTime = 3
    var time = 1800
    var timer = Timer()
    var rentedTimer = Timer()
    
    // in second
    var reloadtime = 360

    enum Status {
        case lock, release
    }
    var timerStatusReadyTo: TimerStatus = .play
    public var timerCurrentStatusFlag: TimerStatus = .reset
    var timeInPause = 5
    
    var lastUodateTime: Date = Date()
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        locationManager.stopUpdatingLocation()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        countDownTimer.start()
        configuration()
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(action))
        longPressRecognizer.numberOfTapsRequired = 1
        longPressRecognizer.minimumPressDuration = 0.1
        mapView.addGestureRecognizer(longPressRecognizer)
    }
    
    @objc func action(sender: UILongPressGestureRecognizer) {
        let isLongPressGestureRecognizerActive = [.possible, .began, .changed].contains(sender.state)
        gestureRecognizerStatus = isLongPressGestureRecognizerActive ? .lock : .release
        guard isLongPressGestureRecognizerActive, let lastTouchPoint = lastTouchPoint else {
            clusterManager.reload(mapView: mapView)
            return
        }
        let current = sender.location(in: mapView)
        let deltaY = current.y - lastTouchPoint.y
        self.lastTouchPoint = current
        
        mapZoomWith(scale: deltaY > 0 ? 1.05 : 0.95)
    }
    
    private var lastTouchPoint: CGPoint?
    
    private var gestureRecognizerStatus: Status  = .release
    
    
    private func autoUpdate(timeInterval: TimeInterval) {
        
        if Date().timeIntervalSince(lastUodateTime) > timeInterval {
            self.updateTimeLabel.text = "資料更新中"
            getData(userLocation: mapView.userLocation.coordinate)
            lastUodateTime = Date()
            
        } else {
            self.updateTimeLabel.text = "\(Int(Date().timeIntervalSince(self.lastUodateTime))) 秒前更新"
        }
    }
    
    private func mapZoomWith(scale: Double) {
        var span = mapView.region.span
        var region = mapView.region
        let latDelt = min(158.0, max(span.latitudeDelta * scale, 0))
        let longDelt = min(145.5, max(span.longitudeDelta * scale, 0))
        span.latitudeDelta = latDelt
        span.longitudeDelta = longDelt
        region.span = span
        mapView.setRegion(region, animated: false)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastTouchPoint = touches.first?.location(in: mapView)
    }
    
    var isNearbyMode = true
    
    private func getData(userLocation: CLLocationCoordinate2D) {
        segmentedControl.isEnabled = false
        NetworkActivityIndicatorManager.shared.networkOperationStarted()
        getStations(userLocation: userLocation, isNearbyMode: isNearbyMode) { [unowned self] (stations, apis) in
            NetworkActivityIndicatorManager.shared.networkOperationFinished()
            let estimated = self.getEstimated(from: apis)
            let determined = self.handleAnnotationInfo(stations: stations, estimated: estimated)
            
            self.bikeInUsing = determined.bikeIsUsing.currencyStyle
            let bikeOnStation = determined.bikeOnSite.currencyStyle
            self.shownData(bikeOnStation: bikeOnStation, bikeIsUsing: self.bikeInUsing, stations: stations, apis: apis)
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
        
        authorizationStatus()
        setupRotatArrowBtnPosition()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundView?.alpha = 0
        viewConfriguation()
        #if Release
        setGoogleMobileAds()
        #endif
    }
    
    private func viewConfriguation() {
        effect = visualEffectView.effect
        visualEffectView.effect = nil
        applyMotionEffect(toView: tableView, updateTimeLabel, segmentedControl, magnitude: -20)
    }
}
