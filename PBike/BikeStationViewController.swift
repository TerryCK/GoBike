//
//  BikeStationViewController.swift
//  PBike
//
//  Created by 陳 冠禎 on 2016/10/16.
//  Copyright © 2016年 陳 冠禎. All rights reserved.
//

import UIKit
import SWXMLHash

class BikeStationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    

    
    @IBOutlet weak var tableView: UITableView!
    

    var bikeStation = BikeStation()
    var bikeStations = BikeStation().stations
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        tableView.delegate = self
        tableView.dataSource = self
        

        
        bikeStation.downloadPBikeDetails {
        //call to download xml from offical website
        let stations = self.bikeStation.stations
            self.bikeStations = stations
            let numberOfStation = stations.count
           
            
            self.tableView.reloadData()
            
            let nunberOfUsingPBike = self.bikeStation.numberOfBikeIsUsing(station: stations, count: numberOfStation)
            print("目前有\(nunberOfUsingPBike)人正在騎PBIke")
            //set ui to load Downloaded code
        }
        

        // Do any additional setup after loading the view.
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.bikeStations.count
    }
    
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "Cell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! BikeStationTableViewCell
        
        // Configure the cell...
        if let name = self.bikeStations[indexPath.row].name{
            cell.nameLabel?.text! = name
        }
        
        cell.parkNumber?.text! = "\(self.bikeStations[indexPath.row].parkNumber!)"
        cell.currentBikeNumber?.text! = "\(self.bikeStations[indexPath.row].currentBikeNumber!)"
        
        
        return cell
    }

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */


    
}
