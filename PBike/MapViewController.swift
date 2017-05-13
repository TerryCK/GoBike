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

protocol BikeStationDelegate: class  {
    var  citys:             [City]      { get }
    var  stations:          [Station]   { get }
    var  countOfAPIs:       Int         { get }
    var  netWorkDataSize:   Int         { get }
    func downloadInfoOfBikeFromAPI(completed: @escaping DownloadComplete)
    func statusOfStationImage(station: [Station], index: Int) -> String
    func findLocateBikdAPI2Download(userLocation: CLLocationCoordinate2D)
    
    
}

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
    
    var delegate: BikeStationDelegate?
//    var bikeStationModel: BikeStationsModel?
    
    let yDelta: CGFloat = 500
    let cellSpacingHeight: CGFloat = 5
    
    var myLocationManager: CLLocationManager!
    var effect:UIVisualEffect!
    
    
    var bikeStations = [Station]() //the object for save ["station"]
    var location = CLLocationCoordinate2D()
    var selectedPin: MKPlacemark?
    var selectedPinName: String?
    var currentPeopleOfRidePBike: String = ""
    //    var resultSearchController: UISearchController!
    var adUnitID = "ca-app-pub-3022461967351598/7933523718"
    var appId = "1168936145"
    var mailtitle =  "[GoBike]APP建議與回報"
    var govName = "屏東縣政府"
    var dataOwner = "高雄捷運局"
    var applink = "https://itunes.apple.com/tw/app/pbike-ping-dong-zui-piao-liang/id1168936145?l=zh&mt=8"
    var rideBikeWithYou = "人陪你騎腳踏車"
    
    var annotations = [MKAnnotation]()
    var bikeOnService = 0
    
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
    var timerStatusReadyTo: TimerStatus = .Play
    open var timerCurrentStatusFlag: TimerStatus = .Reset
    var timeInPause: Int = 5
    
    
    var bikesInStation = 0
    var nunberOfUsingBike = 0
    var bikeInUsing = ""
    var citycounter = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configuration()
        
        authrizationStatus {
            self.setCurrentLocation(latDelta: 0.03, longDelta: 0.03)
//            print("delegate mapview",self.delegate)
            self.delegate?.findLocateBikdAPI2Download(userLocation: self.location)
            self.updatingDataByServalTime()
        }
        
    }
    

    
    func updatingDataByServalTime() {
       
        if reloadtime > 0 {
            reloadtime -= 1
            updateTimeLabel.text = "\(30 - reloadtime) 秒前更新"
            
            
        } else {
            
            timer.invalidate()
            updateTimeLabel.text = "資料更新中"
            print("\n ***** 資料更新中 *****\n")
            self.citycounter = 1
            self.downloadDataFromAPI()
            timesOfLoadingAnnotationView = 1
            self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(MapViewController.updatingDataByServalTime), userInfo: nil, repeats: true)
            reloadtime = 30
        }
    }
    
    func downloadDataFromAPI(){

        delegate?.downloadInfoOfBikeFromAPI {
            self.bikeOnService = self.appVersionInit()
            self.handleAnnotationInfo()
            self.refreshShownData()
           
        }
    }
    
    func refreshShownData(){
        
        guard let cities = self.delegate?.citys,
                let netWorkDataSize = self.delegate?.netWorkDataSize.currencyStyle else {
                return
        }
        
        guard self.citycounter == cities.count else {
            self.citycounter += 1
            return
        }
        print("\n站內腳踏車有 \(self.bikesInStation.currencyStyle) 台")
        print("目前有 \(self.self.currentPeopleOfRidePBike) 人正在騎腳踏車")
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
        self.delegate = BikeStationsModel()
        //        bikeStationModel = BikeStationsModel.init()
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
        blurEffect()
        viewUpdateTimeLabel()
        applyMotionEffect(toView: self.UITableView, magnitude: -20)
        applyMotionEffect(toView: self.updateTimeLabel, magnitude: -20)
    }
}



