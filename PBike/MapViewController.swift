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
import MessageUI

protocol HandleMapSearch:class {
    func dropPinZoomIn(_ placemark:MKPlacemark)
}


class MapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    @IBOutlet weak var bannerView: GADBannerView!
    var effect:UIVisualEffect!
    @IBOutlet var mapView: MKMapView!
    var myLocationManager: CLLocationManager!
    var bikeStation = BikeStation() //the object for download and init station datas
    var bikeStations = BikeStation().stations //the object for save ["station"]
    var location = CLLocationCoordinate2D()
    var selectedPin: MKPlacemark?
    var selectedPinName:String?
    var currentPeopleOfRidePBike:String = ""
    var resultSearchController: UISearchController!
    var adUnitID = "ca-app-pub-3022461967351598/7933523718"
    var appId = "1168936145"
    let cellSpacingHeight: CGFloat = 5
    var mailtitle =  "[PBike]APP建議與回報"
    var govName = "屏東縣政府"
    
    
    func getDirections(){
        guard let selectedPin = self.selectedPin else {return}
        let mapItem = MKMapItem(placemark: selectedPin)
        mapItem.name = self.selectedPinName
        print(" mapItem.name \( mapItem.name)")
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking]
        mapItem.openInMaps(launchOptions: launchOptions)
        
    }
    
    @IBOutlet weak var locationArrowImage: UIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        effect = visualEffectView.effect
        visualEffectView.effect = nil
        UITableView.delegate = self
        UITableView.dataSource = self
        UITableView.backgroundView?.alpha = 0
        applyMotionEffect(toView: UITableView, magnitude: -20)
        appVersionInit()
        print("view did load ")
        setGoogleMobileAds()
        
        // 調整navigation 背景color
        //if inside a popover
        //        if let popover = navigationController?.popoverPresentationController {
        //            popover.backgroundColor = UIColor.clear()
        //        }
        
        let downloadPBikeData = bikeStation.downloadPBikeDetails
        initializeLocationManager()
        
        
        //下載資料
        downloadPBikeData() {
            self.handleAnnotationInfo()
            self.UITableView.reloadData()
        }
        mapViewInfoCustomize()
        
        
        
        //set ui to load Downloaded code
    }
    
    // Do any additional setup after loading the view.
    
    func mapViewInfoCustomize(){
        mapView.delegate = self
        mapView.mapType = .standard
        mapView.showsUserLocation = true
        mapView.isZoomEnabled = true
        mapView.showsCompass = false
        mapView.showsScale = false
        mapView.showsTraffic = false
    }
    
    func initializeLocationManager(){
        myLocationManager = CLLocationManager()
        myLocationManager.delegate = self
        myLocationManager.distanceFilter = kCLLocationAccuracyNearestTenMeters
        myLocationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    
    func handleAnnotationInfo() {
        
        let stations = self.bikeStation.stations
        self.bikeStations = stations
        let numberOfStation = stations.count
        var location = CLLocationCoordinate2D()
        location = self.location
        
        // analysis bike information
        
        let nunberOfUsingPBike = self.bikeStation.numberOfBikeIsUsing(station: stations, count: numberOfStation)
        
        let bikesInStation = self.bikeStation.bikesInStation(station: stations, count: numberOfStation)
        
        var bikeInUsing = ""
        switch nunberOfUsingPBike {
        case 0...5000:
            bikeInUsing = " \(nunberOfUsingPBike) "
        default:
            bikeInUsing = "不知道有多少人正在"
        }
        
        self.currentPeopleOfRidePBike = "\(bikeInUsing)"
        print("站內腳踏車有\(bikesInStation)台")
        print("目前有\(nunberOfUsingPBike)人正在騎BIke")
        print("目前站點有：\(stations.count)座")
        
        
        let currentLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        
        
        //set Annotation with xml imformation
        for index in 0...(stations.count - 1){
            
            let objectAnnotation = CustomPointAnnotation()
            
            //handle coordinate
            let _latitude:CLLocationDegrees = stations[index].latitude
            let _longitude:CLLocationDegrees = stations[index].longitude
            
            let coordinats = CLLocationCoordinate2D(latitude: _latitude, longitude: _longitude)
            let destinationOfCoordinats = CLLocation(latitude: _latitude, longitude: _longitude)
            objectAnnotation.coordinate = coordinats
            
            //handle distance
            let distanceInMeter = destinationOfCoordinats.distance(from: currentLocation) / 1000
            let distanceInKm = String(format:"%.1f", distanceInMeter)
            objectAnnotation.distance = distanceInKm
            
            //handle name for navigation
            if let name = stations[index].name {
                let placemark = MKPlacemark(coordinate: coordinats, addressDictionary:[name: ""])
                
                objectAnnotation.placemark = placemark
                
                
                
            }
            //handle picture of pin
            let pinImage = self.bikeStation.statusOfStationImage(station: stations, index: index)
            objectAnnotation.imageName = UIImage(named: pinImage)
            
            
            //handle bikes in each bike stations
            //handle bike station's name
            if let currentBikeNumber = stations[index].currentBikeNumber,
                let name = stations[index].name,
                let parkNumber = stations[index].parkNumber{
                objectAnnotation.subtitle = "\(name)"
                if (currentBikeNumber == 99) || (parkNumber == 99) {
                    objectAnnotation.title = "🚲: ??  🅿️: ??"
                }else{objectAnnotation.title = "🚲:  \(currentBikeNumber)   🅿️:  \(parkNumber)"}
                //print("\(objectAnnotation.title!), name:\(name)")
            }
            
            
            self.mapView?.addAnnotation(objectAnnotation)
        }
    }
    
    
    @IBAction func errorReportBtnPressed(_ sender: AnyObject) {
        let mailComposeViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposeViewController, animated: true, completion: nil)
        } else {
            self.showSendMailErrorAlert()
        }
    }
    //    func configuredMailComposeViewController() -> MFMailComposeViewController {
    //        let mailComposerVC = MFMailComposeViewController()
    //        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
    //
    //        mailComposerVC.setToRecipients(["pbikemapvision@gmail.com"])
    //        mailComposerVC.setSubject("PBikeAPP建議與回報")
    //        mailComposerVC.setMessageBody("感謝您提供錯誤訊息！", isHTML: false)
    //
    //        return mailComposerVC
    //    }
    //
    //    func showSendMailErrorAlert() {
    //        let sendMailErrorAlert = UIAlertView(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", delegate: self, cancelButtonTitle: "OK")
    //        sendMailErrorAlert.show()
    //    }
    //
    //    // MARK: MFMailComposeViewControllerDelegate
    //
    //    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
    //        controller.dismissViewControllerAnimated(true, completion: nil)
    //
    //    }
    
    
    
    
    @IBAction func ratingBtnPressed(_ sender: AnyObject) {

        let appID = self.appId
        if let checkURL = URL(string: "http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=\(appID)&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8") {
            if UIApplication.shared.canOpenURL(checkURL) {
                UIApplication.shared.openURL(checkURL)
                print("url successfully opened")
            }
        } else {
            print("invalid url")
        }
    }
    @IBOutlet weak var topTitleimageView: UIButton!
    
    @IBOutlet weak var UITableView: UITableView!
    var showInfoTableView:Bool = false
    
    
    
    @IBAction func titleBtnPressed(_ sender: AnyObject) {
        print("按按鈕有反應嗎？ \(tableViewCanDoNext)")
        print("秀表格嗎？ \(showInfoTableView)")
        
        
        if tableViewCanDoNext {
            if showInfoTableView {
                //do for unshow tabview
                
                unShowTableView(UITableView)
                showInfoTableView = false
                
                
            }else{
                // do for show tabview
                setTrackModeNone()
                showUpTableView(UITableView)
                showInfoTableView = true
                
            }
        }
    }
    
    let yDelta:CGFloat = 500
    var tableViewCanDoNext:Bool = true
    
    func toRadian(degree: Double) -> CGFloat {
        return CGFloat(degree * (M_PI/180))
    }
    
    func showUpTableView(_ moveView: UIView){
        //show subview from top
        print("self.tableViewCanDoNext \(self.tableViewCanDoNext)")
        self.tableViewCanDoNext = false
        
        //        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        print("UITableView Postition \(UITableView.center) ")
        print("Show up Table View   : Y + yDelta")
        moveView.center = CGPoint(x: moveView.center.x, y:moveView.center.y - self.yDelta )
        
        
        moveView.isHidden = false
        self.visualEffectView.isHidden = false
        
        UIView.animate(withDuration: 0.3, delay: 0, options:[ UIViewAnimationOptions.allowAnimatedContent, UIViewAnimationOptions.curveEaseInOut], animations: {
            
            moveView.center = CGPoint(x: moveView.center.x, y:moveView.center.y + self.yDelta)
            self.rotationArrow.imageView?.transform = CGAffineTransform(rotationAngle: self.toRadian(degree: 180))
            self.visualEffectView.effect = self.effect
            }, completion: { (Bool) in
                self.tableViewCanDoNext = true
                print("show Up animation is completion")
                
        })
        
        print("y: \(moveView.center.y)")
        
    }
    
    func unShowTableView(_ moveView: UIView){
        //show subview out to top
        print("Show off Table View  : Y - yDelta")
        
        self.tableViewCanDoNext = false
        
        
        UIView.animate(withDuration: 0.3, delay: 0, options:[ UIViewAnimationOptions.allowAnimatedContent, UIViewAnimationOptions.curveEaseInOut], animations: {
            
            moveView.center = CGPoint(x: moveView.center.x, y:moveView.center.y - self.yDelta)
            
            self.rotationArrow.imageView?.transform = CGAffineTransform(rotationAngle: 0)
            self.visualEffectView.effect = nil
            
            }, completion: { (Bool) in
                
                print("show off animation is completion")
                moveView.isHidden = true
                self.visualEffectView.isHidden = true
                moveView.center = CGPoint(x: moveView.center.x, y:moveView.center.y + self.yDelta )
                print("y: \(moveView.center.y)")
                
                
                self.tableViewCanDoNext = true
                
                
        })
    }
    
    //handle Tabview present animates
    
    @IBOutlet weak var rotationArrow: UIButton!
    
    
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
            let distance = Double(customAnnotation.distance!)!
            var width = 28
            if (distance > 100) {
                width = 40
            }
            else{
                width = 28
            }
            
            
            let textSquare = CGSize(width:width , height: 40)
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
            if let name = annotation.subtitle {
                self.selectedPinName = "\(name)(PBike)"
                print("Your annotationView title: \(name)")
            }
            
        }
        
        func mapView(_ mapView:MKMapView , regionWillChangeAnimated: Bool){
            print("region will change")
        }
    }
    
    
    func setCurrentLocation(latDelta:Double, longDelta:Double) {
        
        
        let currentLocationSpan:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, longDelta)
        var location = CLLocationCoordinate2D()
        print("myLocationManager.location , \(myLocationManager.location)")
        
        if let current = myLocationManager.location {
            location.latitude = Double(current.coordinate.latitude)
            location.longitude = Double(current.coordinate.longitude)
            print("取得使用者GPS位置")
        }else{
            
            #if CityBike
                //cibike Version
                location.latitude = 22.6384542
                location.longitude = 120.3019452
                print("無法取得使用者位置、改取得高雄火車站GPS位置")
            #else
                //Pbike Version
                location.latitude = 22.669248
                location.longitude = 120.4861926
                print("無法取得使用者位置、改取得屏東火車站GPS位置")
            #endif
            
           
            
        }
        
        print("北緯：\(location.latitude) 東經：\(location.longitude)")
        let center:CLLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        
        let currentRegion:MKCoordinateRegion = MKCoordinateRegion (center: center.coordinate, span:currentLocationSpan)
        
        self.mapView.setRegion(currentRegion, animated: false)
        
        print("currentRegion \(currentRegion)")
        self.location = location
        
    }
    
    //    var mapUserTrackingModFlag:Int = 0 //init tracking mode to none
    
    
    @IBAction func locationArrowPressed(_ sender: AnyObject) {
        
        
        switch (self.mapView.userTrackingMode) {
            
        case .none:
            setTrackModeToFollow()
            
        case .follow:
            setTrackModeToFollowWithHeading()
            
            
        case .followWithHeading:
            setTrackModeNone()
            
        }
    }
    
    
    @objc(mapView:didChangeUserTrackingMode:animated:) func mapView(_ mapView: MKMapView, didChange mode: MKUserTrackingMode, animated: Bool) {
        
        
        switch (self.mapView.userTrackingMode) {
            
        case .none:
            locationArrowImage.setImage(UIImage(named: "locationArrowNone"), for: UIControlState.normal)
            
            print("tracking mode has changed to none")
            
        case .followWithHeading:
            locationArrowImage.setImage(UIImage(named: "locationArrowFollewWithHeading"), for: UIControlState.normal)
            print("tracking mode has changed to followWithHeading")
            
            
            
        case .follow:
            locationArrowImage.setImage(UIImage(named: "locationArrow"), for: UIControlState.normal)
            print("tracking mode has changed to follow")
            
        }
        
        print("userTracking mode has been charged")
    }
    
    
    func setTrackModeToFollowWithHeading(){
        
        setCurrentLocation(latDelta: 0.01, longDelta: 0.01)
        //        self.mapView.setCenter(self.location, animated: true)
        self.mapView.setUserTrackingMode(MKUserTrackingMode.followWithHeading, animated: true)
    }
    
    func setTrackModeNone(){
        //        setCurrentLocation(latDelta: 0.05, longDelta: 0.05)
        self.mapView.setUserTrackingMode(MKUserTrackingMode.none, animated: false)
    }
    func setTrackModeToFollow(){
        
        //        setCurrentLocation(latDelta: 0.05, longDelta: 0.05)
        self.mapView.setUserTrackingMode(MKUserTrackingMode.follow, animated: false)
        //        locationArrowImage.setImage(UIImage(named: "locationArrow"), for: UIControlState.normal)
        //        print("follow")
        
    }
    
    
    @IBAction func searchBtnPressed(_ sender: AnyObject) {
        //        locationSearchFunc()
        let downloadPBikeData = bikeStation.downloadPBikeDetails
        downloadPBikeData(){
            self.handleAnnotationInfo()
            self.UITableView.reloadData()
        }
    }
}





extension MapViewController: CLLocationManagerDelegate {
    //get the authorization for location
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("view did apear ")
        authrizationStatus()
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        myLocationManager.stopUpdatingLocation()
        
    }
    
    func authrizationStatus(){
        
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
        
        setCurrentLocation(latDelta: 0.03, longDelta: 0.03)
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        //        guard let location = locations.first else { return }
        //        let span = MKCoordinateSpanMake(0.05, 0.05)
        //        let region = MKCoordinateRegion(center: location.coordinate, span: span)
        //        mapView.setRegion(region, animated: true)
        
        //        let currentLocation: CLLocation = locations[0] as CLLocation
        //        print("\(currentLocation.coordinate.latitude)")
        //        print(", \(currentLocation.coordinate.longitude)")
        
        print("did Update Location")
        
        
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

extension MapViewController {
    
    func applyMotionEffect(toView view: UIView, magnitude:Float){
        let xMotion = UIInterpolatingMotionEffect(keyPath: "center.x", type: .tiltAlongHorizontalAxis)
        xMotion.minimumRelativeValue = -magnitude
        xMotion.maximumRelativeValue = magnitude
        
        let yMotion = UIInterpolatingMotionEffect(keyPath: "center.y", type: .tiltAlongVerticalAxis)
        yMotion.maximumRelativeValue = magnitude
        yMotion.minimumRelativeValue = -magnitude
        
        let group = UIMotionEffectGroup()
        group.motionEffects = [xMotion, yMotion]
        view.addMotionEffect(group)
        
    }
}


class CustomPointAnnotation: MKPointAnnotation {
    var imageName: UIImage!
    var placemark: MKPlacemark!
    var distance: String!
    
}

// tableview
extension MapViewController:UITableViewDataSource, UITableViewDelegate{
    
    func numberOfSections(in tableView: UITableView) -> Int
    { return 4 }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    { return 12 } //set cell space hight
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    { return 1 }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = (indexPath as NSIndexPath).section
        if section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! StationTableViewCell
            cell.peopleNumberLabel.text = self.currentPeopleOfRidePBike
            print("cell.peopleNumberLabel.text \(cell.peopleNumberLabel.text)")
            cellCustomize(cell: cell)
            return cell
            
        } else if section == 1 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "RatingReprotCell", for: indexPath) as! RateingReportTableViewCell
            cellCustomize(cell: cell)
            return cell
            
        }else if section == 2 {
            
            print("ThanksforTableViewCell")
            let cell = tableView.dequeueReusableCell(withIdentifier: "ThanksforTableViewCell", for: indexPath) as! ThanksforTableViewCell
            cell.thanksLabel.text = "   本程式資料來源係由\(govName)與高雄捷運公司之公開資訊、恕不保證內容準確性，本程式之所有權為作者所有。"
            cellCustomize(cell: cell)
            return cell
            
        }else{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "aboutUs", for: indexPath) as! aboutUsTableViewCell
            print("aboutUsTableViewCell")
            cellCustomize(cell: cell)
            return cell
        }
        
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // note that indexPath.section is used rather than indexPath.row
        print("You tapped cell number \(indexPath.section).")
        
    }
    
    func cellCustomize(cell: UITableViewCell){
        
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        cell.layer.borderWidth = 0
        cell.layer.cornerRadius = 8
        cell.clipsToBounds = true
        cell.backgroundView = blurEffectView
        cell.backgroundView?.alpha = 0.85
        cell.layoutMargins = UIEdgeInsets.zero
    }
}




//google ads



extension MapViewController: GADBannerViewDelegate{
    func setGoogleMobileAds(){
        let request: GADRequest = GADRequest()
        //set device to test devices
        //        request.testDevices = ["09f8ecd06be28585d166f429d404b8044ccecdbe", kGADSimulatorID]
        
        
        bannerView.rootViewController = self
        bannerView.adUnitID = adUnitID
        let test_iPhone:NSString = "09f8ecd06be28585d166f429d404b8044ccecdbe"
        let test_iPhones:String = "09f8ecd06be28585d166f429d404b8044ccecdbe"
        //        let test_iPad = ""
        request.testDevices = [test_iPhone, test_iPhones, kGADSimulatorID]
        bannerView.adSize = kGADAdSizeSmartBannerPortrait
        bannerView.load(request)
        print("Google Mobile Ads SDK version: \(GADRequest.sdkVersion())")
        print("TestID is \(request.testDevices!)")
    }
    
    private func adView(bannerView: GADBannerView!,
                        didFailToReceiveAdWithError error: GADRequestError!) {
        print("adView:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }
    
}



extension MapViewController: MFMailComposeViewControllerDelegate {
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        
        mailComposerVC.setToRecipients(["pbikemapvision@gmail.com"])
        mailComposerVC.setSubject(self.mailtitle)
        mailComposerVC.setMessageBody("我們非常感謝您使用此App，歡迎寫下您希望的功能/錯誤回報或是合作洽談，謝謝", isHTML: false)
        
        return mailComposerVC
    }
    
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertView(title: "無法傳送Email", message: "目前無法傳送郵件，請檢查E-mail設定並在重試", delegate: self, cancelButtonTitle: "OK")
        
        sendMailErrorAlert.show()
    }
    
    // MARK: MFMailComposeViewControllerDelegate
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
        
    }
    
    
}
// APP check version and default
extension MapViewController {
   
    func appVersionInit(){
        
        #if CityBike
            //cibike Version
            
            self.topTitleimageView.setImage(UIImage(named: "cityBikeTitle"), for: UIControlState.normal)
            self.mailtitle = "[CBike]APP建議與回報"
            self.appId = "1173313131"
            self.govName = "高雄市政府"
            self.adUnitID = "ca-app-pub-3022461967351598/9565570510"
            //高雄
        #else
            
            //Pbike Version
            self.appId = "1168936145"
        #endif
    }

}

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
