//
//  LocationSearchTable.swift
//  PBike
//
//  Created by 陳 冠禎 on 2016/10/22.
//  Copyright © 2016年 陳 冠禎. All rights reserved.
//

import UIKit
import MapKit

protocol HandleMapSearch:class {
    func dropPinZoomIn(_ placemark:MKPlacemark)
}

class LocationSearchTable: UITableViewController {

    weak var handleMapSearchDelegate: HandleMapSearch?
    var matchingItems: [MKMapItem] = []
    var mapView: MKMapView?
    
    func parseAddress(_ selectedItem:MKPlacemark) -> String {
        
        // put a space between "4" and "Melrose Place"
        let firstSpace = (selectedItem.subThoroughfare != nil &&
            selectedItem.thoroughfare != nil) ? " " : ""
        
        // put a comma between street and city/state
        let comma = (selectedItem.subThoroughfare != nil || selectedItem.thoroughfare != nil) &&
            (selectedItem.subAdministrativeArea != nil || selectedItem.administrativeArea != nil) ? ", " : ""
        
        // put a space between "Washington" and "DC"
        let secondSpace = (selectedItem.subAdministrativeArea != nil &&
            selectedItem.administrativeArea != nil) ? " " : ""
        
        let addressLine = String(
            format:"%@%@%@%@%@%@%@",
            // street number
            selectedItem.subThoroughfare ?? "",
            firstSpace,
            // street name
            selectedItem.thoroughfare ?? "",
            comma,
            // city
            selectedItem.locality ?? "",
            secondSpace,
            // state
            selectedItem.administrativeArea ?? ""
        )
        
        return addressLine
    }
}

extension LocationSearchTable: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let mapView = mapView, let searchBarText = searchController.searchBar.text
            else {
                return}
        
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = searchBarText
        request.region = mapView.region
        let search = MKLocalSearch(request: request)
        
        search.start { response, _ in guard let response = response else {
            return
            }
            self.matchingItems = response.mapItems
            self.tableView.reloadData()
        }
        
    }
}

extension LocationSearchTable {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchingItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
        let selectedItem = matchingItems[(indexPath as NSIndexPath).row].placemark
        cell.textLabel?.text = parseAddress(selectedItem)
        return cell
    }
}

extension LocationSearchTable {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = matchingItems[(indexPath as NSIndexPath).row].placemark
        handleMapSearchDelegate?.dropPinZoomIn(selectedItem)
        dismiss(animated: true, completion: nil)
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

