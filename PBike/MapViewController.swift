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
    var mailtitle =  "[PBike]APP建議與回報"
    var govName = "屏東縣政府"
    var dataOwner = "高雄捷運局"
    var bike = "PBike"
    var applink = "https://itunes.apple.com/tw/app/pbike-ping-dong-zui-piao-liang/id1168936145?l=zh&mt=8"
    var rideBikeWithYou = "人陪你騎PBike"
    let cellSpacingHeight: CGFloat = 5
    var delegate: BikeStationDelegate?
    let queue = DispatchQueue(label: "com.MapVision.myqueue")
    var annotations = [MKAnnotation]()
    var bikeOnService = 0
    let yDelta:CGFloat = 500
    var tableViewCanDoNext:Bool = true
    var showInfoTableView:Bool = false
    var oldAnnotations = [MKAnnotation]()
    var timesOfLoadingAnnotationView = 1
    
    // time relation parameter
    var time = 1800
    var timer = Timer()
    var timerForAutoUpdate = Timer()
    var reloadtime = 0 //seconds
    var timerStatusReadyTo: TimerStatus = .play
    var timeCurrentStatus: TimerStatus = .reset
    var timeInPause: Int = 5
    let showTheResetButtonTime = 3
    
    
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
        mapViewInfoCustomize()
        effect = self.visualEffectView.effect
        visualEffectView.effect = nil
        addBlurEffect()
        applyMotionEffect(toView: self.UITableView, magnitude: -20)
        applyMotionEffect(toView: self.updateTimeLabel, magnitude: -20)
        
    }
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation.isKind(of: MKUserLocation.self) { return nil }
        
        let identifier = "station"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
            
        } else {
            annotationView?.annotation = annotation   }
        
        let customAnnotation = annotation as! CustomPointAnnotation
        let distance = Double(customAnnotation.distance!)!
        
        let width = distance > 100 ? 40 : 28
        let textSquare = CGSize(width:width , height: 40)
        let subTitleView:UILabel! = UILabel(frame: CGRect(origin: CGPoint.zero, size: textSquare))
        
        subTitleView.font = subTitleView.font.withSize(12)
        subTitleView.textAlignment = NSTextAlignment.right
        subTitleView.numberOfLines = 0
        subTitleView.textColor = UIColor.gray
        subTitleView.text = "\(distance) km"
        
        annotationView?.image =  customAnnotation.imageName
        
        let smallSquare = CGSize(width: 43, height: 43)
        let button = UIButton(frame: CGRect(origin: CGPoint.zero, size: smallSquare))
        button.setBackgroundImage(UIImage(named: "go"), for: UIControlState())
        button.addTarget(self, action: #selector(MapViewController.getDirections), for: .touchUpInside)
        annotationView?.rightCalloutAccessoryView = button
        annotationView?.leftCalloutAccessoryView = subTitleView
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print("Annotation selected")
        
        if let annotation = view.annotation as? CustomPointAnnotation {
            self.selectedPin = annotation.placemark
            
            if let name = annotation.subtitle {
                
                self.selectedPinName = "\(name)(\(bike))"
                print("Your annotationView title: \(name)")
                
            }
            if let image = annotation.imageName {
                print("image name \(image)")
            }
        }
    }
    
    func mapView(_ mapView:MKMapView , regionWillChangeAnimated: Bool){
        print("region will change")
    }
}

extension MapViewController {
    
    //get the authorization for location
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let defaults = UserDefaults.standard
        let hasSharedApp = defaults.bool(forKey: "hasSharedApp")
        let hasViewedGuidePage = defaults.bool(forKey: "hasViewedGuidePage")
        if !hasSharedApp {
            print("hasSharedApp: \(hasSharedApp)")
            setGoogleMobileAds()
        }
        if !hasViewedGuidePage {
            
            if let guidePageViewController = storyboard?.instantiateViewController(withIdentifier: "GuidePageViewController") as? GuidePageViewController {
                present(guidePageViewController, animated: true, completion: nil )
            }
        }
        print("hasSharedApp: \(hasSharedApp)")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        myLocationManager.stopUpdatingLocation()
    }
    
}

