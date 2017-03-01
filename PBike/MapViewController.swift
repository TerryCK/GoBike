//
//  MapViewController.swift
//  PBike
//
//  Created by 陳 冠禎 on 2016/10/19.
//  Copyright © 2016年 陳 冠禎. All rights reserved.
//

import UIKit
import MapKit
import Crashlytics
import CoreLocation
import GoogleMobileAds

class MapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var updateTimeLabel: UILabel!
    @IBOutlet var mapView: MKMapView!
    @IBOutlet weak var timerLabel: UIButton!
    @IBOutlet weak var rotationArrow: UIButton!
    @IBOutlet weak var UITableView: UITableView!
    @IBOutlet weak var bannerView: GADBannerView!
    @IBOutlet weak var topTitleimageView: UIButton!
    @IBOutlet weak var locationArrowImage: UIButton!
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    
    
    let yDelta:CGFloat = 500
    let queue = DispatchQueue(label: "com.MapVision.myqueue")
    let cellSpacingHeight: CGFloat = 5
    
    var myLocationManager: CLLocationManager!
    var effect:UIVisualEffect!
    var bikeStations = BikeStation().stations //the object for save ["station"]
    var location = CLLocationCoordinate2D()
    var selectedPin: MKPlacemark?
    var selectedPinName:String?
    var currentPeopleOfRidePBike:String = ""
    var resultSearchController: UISearchController!
    var adUnitID = "ca-app-pub-3022461967351598/7933523718"
    var appId = "1168936145"
    var mailtitle =  "[GoBike]APP建議與回報"
    var govName = "屏東縣政府"
    var dataOwner = "高雄捷運局"
    var bike = "PBike"
    var applink = "https://itunes.apple.com/tw/app/pbike-ping-dong-zui-piao-liang/id1168936145?l=zh&mt=8"
    var rideBikeWithYou = "人陪你騎PBike"
    var delegate: BikeStationDelegate?
    var annotations = [MKAnnotation]()
    var bikeOnService = 0
    var tableViewCanDoNext:Bool = true
    var showInfoTableView:Bool = false
    var oldAnnotations = [MKAnnotation]()
    var timesOfLoadingAnnotationView = 1
    
//     time relation parameter
    let showTheResetButtonTime = 3
    var time = 1800
    var timer = Timer()
    var timerForAutoUpdate = Timer()
    var reloadtime = 0 //seconds
    var timerStatusReadyTo: TimerStatus = .play
    var timeCurrentStatus: TimerStatus = .reset
    var timeInPause: Int = 5
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        self.updatingDataByServalTime()
    }
    
    func updatingDataByServalTime() {
        if reloadtime > 0 {
            reloadtime -= 1
            updateTimeLabel.text = "\(30 - reloadtime) 秒前更新"
            print("\(reloadtime) seconds ")
            
        } else {
            timerForAutoUpdate.invalidate()
            updateTimeLabel.text = "資料更新中"
            delegate?.downloadInfoOfBikeFromAPI {
                self.bikeOnService = self.appVersionInit()
                print("bikeOnService", self.bikeOnService)
                self.handleAnnotationInfo()
                self.UITableView.reloadData()
            }
            
            timesOfLoadingAnnotationView = 1
            self.timerForAutoUpdate = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(MapViewController.updatingDataByServalTime), userInfo: nil, repeats: true)
            reloadtime = 30
        }
    }
    
    func setup() {
        delegate = BikeStation()
        setupRotatArrowBtnPosition()
        UITableView.delegate = self
        UITableView.dataSource = self
        UITableView.backgroundView?.alpha = 0
        initializeLocationManager()
        authrizationStatus()
        viewInit()
    }
    
    func viewInit() {
        mapViewInfoCustomize()
        effect = self.visualEffectView.effect
        visualEffectView.effect = nil
        blurEffect()
        viewUpdateTimeLabel()
        applyMotionEffect(toView: self.UITableView, magnitude: -20)
        applyMotionEffect(toView: self.updateTimeLabel, magnitude: -20)
    }
}



