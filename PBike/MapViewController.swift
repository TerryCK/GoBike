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

//protocol BikeModelProtocol {
//    var  citys:             [City]      { get }
//    var  stations:          [Station]   { get }
//    var  countOfAPIs:       Int         { get }
//    var  netWorkDataSize:   Int         { get }
////    func getData(completed: @escaping DownloadComplete)
//    func getAPIFrom(userLocation: CLLocationCoordinate2D)
//}

final class MapViewController: UIViewController, MKMapViewDelegate, NavigationBarBlurEffectable, MotionEffectable, BikeStationModelProtocol, ConfigurationProtocol, TitleImageSetable {
    
    
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet weak var updateTimeLabel: UILabel!
    @IBOutlet weak var UITableView: UITableView!
    @IBOutlet weak var bannerView: GADBannerView!
    @IBOutlet weak var timerLabel: UIButton!
    @IBOutlet weak var rotationArrow: UIButton!
    @IBOutlet weak var topTitleimageView: UIButton!
    @IBOutlet weak var locationArrowImage: UIButton!
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    
    var myLocationManager: CLLocationManager!
    var effect:UIVisualEffect!
    
    var location = CLLocationCoordinate2D()
    var selectedPin: CustomPointAnnotation?
    
    var bikeInUsing = ""
    
    
    @IBOutlet weak var SegmentedControl: UISegmentedControl!
    
    var annotations = [MKAnnotation]()
    var oldAnnotations = [MKAnnotation]()
    
    
    
    
    var currentStateOfTableViewDisplaying = TableViewCurrentDisplaySwitcher.unDisplay
    var tableViewCanDoNext = true
    
    var timesOfLoadingAnnotationView = 1
    
    
    
    @IBAction func segbtnPress(_ sender: UISegmentedControl) {
        
        let title = sender.titleForSegment(at: sender.selectedSegmentIndex)
        isNearbyMode = title == "附近" ? true : false
        print(isNearbyMode)
        reloadtime = 0
        self.updatingDataByServalTime()
        
    }
    
    //     time relation parameter
    let showTheResetButtonTime = 3
    var time = 1800
    var timer = Timer()
    var rentedTimer = Timer()
    var reloadtime = 0 //seconds
    var timerStatusReadyTo: TimerStatus = .play
    open var timerCurrentStatusFlag: TimerStatus = .reset
    var timeInPause = 5
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configuration()
        authrizationStatus { [unowned self] in
            let delta = 0.03
            self.setCurrentLocation(latDelta: delta, longDelta: delta)
            self.updatingDataByServalTime()
        }
    }
    
    
    @objc func updatingDataByServalTime() {
        
        if reloadtime > 0 {
            reloadtime -= 1
            updateTimeLabel.text = "\(30 - reloadtime) 秒前更新"
            
        } else {
            
            timer.invalidate()
            updateTimeLabel.text = "資料更新中"
            print("\n ***** 資料更新中 *****\n")
            
            getData(userLocation: location)
            timesOfLoadingAnnotationView = 1
            self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(MapViewController.updatingDataByServalTime), userInfo: nil, repeats: true)
            reloadtime = 30
        }
    }
    
    var isNearbyMode = true
    
    private func getData(userLocation: CLLocationCoordinate2D) {
        SegmentedControl.isEnabled = false
        getStations(userLocation: userLocation, isNearbyMode: isNearbyMode) { (stations, apis) in
            
            let estimated = self.getEstimated(from: apis)
            let determined = self.handleAnnotationInfo(stations: stations, estimated: estimated)
            self.bikeInUsing = determined.bikeIsUsing.currencyStyle
            let bikeOnStation = determined.bikeOnSite.currencyStyle
            self.shownData(bikeOnStation: bikeOnStation, bikeIsUsing: self.bikeInUsing, stations: stations, apis: apis)
            self.SegmentedControl.isEnabled = true
            
        }
    }
    
    private func shownData(bikeOnStation: String, bikeIsUsing: String, stations:[Station], apis:[API]) {
        print("\n站內腳踏車有: \(bikeOnStation) 台")
        print("目前有: \(bikeIsUsing) 人正在騎腳踏車")
        print("目前地圖中有: \(stations.count.currencyStyle) 座")
        print("\n目前顯示城市名單:")
        print("  *****  ", terminator: "")
        apis.forEach{ print($0.city, terminator: ", ") }
        print("  *****  \n")
        UITableView.reloadData()
    }
    
    
   private func configuration() {
        performanceGuidePage()
        initializeLocationManager()
        setupRotatArrowBtnPosition()
        UITableView.delegate = self
        UITableView.dataSource = self
        UITableView.backgroundView?.alpha = 0
        viewConfriguation()
        setGoogleMobileAds()
    }
    
    private func viewConfriguation() {
        mapViewInfoCustomize()
        effect = self.visualEffectView.effect
        visualEffectView.effect = nil
        setNavigationBarBackgrondBlurEffect(to: self)
        viewUpdateTimeLabel()
        applyMotionEffect(toView: self.UITableView, magnitude: -20)
        applyMotionEffect(toView: self.updateTimeLabel, magnitude: -20)
        applyMotionEffect(toView: SegmentedControl, magnitude: -20)
        setTopTitleImage(to: self)
    }
    
}



