//
//  TableViewController.swift
//  PBike
//
//  Created by 陳 冠禎 on 2016/12/29.
//  Copyright © 2016年 陳 冠禎. All rights reserved.
//


import UIKit

extension MapViewController: UITableViewDataSource, UITableViewDelegate {

    @IBAction func titleBtnPressed(_ sender: AnyObject) {
        print("titleBtnPressed？ \(tableViewCanDoNext)")
        print("秀表格嗎？ \(showInfoTableView)")
        
        
        if tableViewCanDoNext {
            if showInfoTableView {
                //do for unshow tabview
                self.locationArrowImage.isEnabled = true
                unShowTableView(UITableView)
                showInfoTableView = false
                print("locationArrowImage Button is enabled")
                
            }else{
                // do for show tabview
                setTrackModeNone()
                showUpTableView(UITableView)
                self.locationArrowImage.isEnabled = false
                showInfoTableView = true
                print("locationArrowImage Button is unabled")
            }
        }
    }
    
    func toRadian(degree: Double) -> CGFloat {
        return CGFloat(degree * (M_PI/180))
    }
    
    func showUpTableView(_ moveView: UIView){
        //show subview from top
        print("self.tableViewCanDoNext \(self.tableViewCanDoNext)")
        self.tableViewCanDoNext = false
        
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
        
        switch section {
            
        case 0:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! StationTableViewCell
            cell.peopleNumberLabel.text = self.currentPeopleOfRidePBike
            cell.rideBikeWithYouLabel.text = self.rideBikeWithYou
            cellCustomize(cell: cell)
            return cell
            
        case 1:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "RatingReprotCell", for: indexPath) as! RateingReportTableViewCell
            cellCustomize(cell: cell)
            return cell
            
        case 2:
            
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "ThanksforTableViewCell", for: indexPath) as! ThanksforTableViewCell
            cell.thanksLabel.text = "   本程式資料來源係由\(govName)與\(dataOwner)之公開資訊、恕不保證內容準確性，本程式之所有權為作者所有。"
            cellCustomize(cell: cell)
            return cell
            
        default:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "aboutUs", for: indexPath) as! aboutUsTableViewCell
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
