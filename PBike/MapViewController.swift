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
import GoogleMobileAds

protocol BikeModelProtocol {
    var  citys:             [City]      { get }
    var  stations:          [Station]   { get }
    var  countOfAPIs:       Int         { get }
    var  netWorkDataSize:   Int         { get }
    func getData(completed: @escaping DownloadComplete)
    func getAPIFrom(userLocation: CLLocationCoordinate2D)
}

final class MapViewController: UIViewController, MKMapViewDelegate, NavigationBarBlurEffectable {
    
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
    var BikeOnRiding: String = ""
    
    var annotations = [MKAnnotation]()
    var estimatedBikeOnService = 0
    
    var currentStateOfTableViewDisplaying = TableViewCurrentDisplaySwitcher.unDisplay
    
    var tableViewCanDoNext: Bool = true
    var oldAnnotations = [MKAnnotation]()
    var timesOfLoadingAnnotationView = 1
    
    //     time relation parameter
    let showTheResetButtonTime = 3
    var time = 1800
    var timer = Timer()
    var rentedTimer = Timer()
    var reloadtime = 0 //seconds
    var timerStatusReadyTo: TimerStatus = .play
    open var timerCurrentStatusFlag: TimerStatus = .reset
    var timeInPause: Int = 5
    var bikesInStation = 0
    var nunberOfUsingBike = 0
    var bikeInUsing = ""
    var citycounter = 1
    
    var bikeModel: BikeModelProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configuration()
        
        authrizationStatus { [unowned self] in
            let delta = 0.03
            self.setCurrentLocation(latDelta: delta, longDelta: delta)
            self.bikeModel?.getAPIFrom(userLocation: self.location)
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
            citycounter = 1
            
            getedData()
            timesOfLoadingAnnotationView = 1
            self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(MapViewController.updatingDataByServalTime), userInfo: nil, repeats: true)
            reloadtime = 30
        }
    }
    
    func getedData(){
        bikeModel?.getData { [unowned self] in
            let estimated = self.estimatedBikeOnService
            self.estimatedBikeOnService = self.appVersionInit()
            self.BikeOnRiding = self.handleAnnotationInfo(estimated: estimated)
        }
    }
    
    
    func refreshShownData() {
        
        guard let cities = self.bikeModel?.citys,
            let netWorkDataSize = self.bikeModel?.netWorkDataSize.currencyStyle else { return }
        
            print("\n站內腳踏車有 \(self.bikesInStation.currencyStyle) 台")
            print("目前有 \(self.BikeOnRiding) 人正在騎腳踏車")
            print("目前地圖中有 \(self.annotations.count.currencyStyle) 座")
            print("目前顯示城市名單:\n")
            print("  *****  ", terminator: "")
            cities.forEach{ print($0, terminator: ", ") }
            print("  *****  \n\n累積下載資料量:", netWorkDataSize, "bytes\n")
            
            UITableView.reloadData()
        
    }
    
    
    func configuration() {
        performanceGuidePage()
        initializeLocationManager()
        setupRotatArrowBtnPosition()
        self.bikeModel = BikeStationsModel()
        UITableView.delegate = self
        UITableView.dataSource = self
        UITableView.backgroundView?.alpha = 0
        viewConfriguation()
        setGoogleMobileAds()
    }
    
    func viewConfriguation() {
        mapViewInfoCustomize()
        effect = self.visualEffectView.effect
        visualEffectView.effect = nil
        setNavigationBarBackgrondBlurEffect(to: self)
        viewUpdateTimeLabel()
        applyMotionEffect(toView: self.UITableView, magnitude: -20)
        applyMotionEffect(toView: self.updateTimeLabel, magnitude: -20)
    }
}



