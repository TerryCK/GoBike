//
//  TableViewController.swift
//  PBike
//
//  Created by 陳 冠禎 on 2016/12/29.
//  Copyright © 2016年 陳 冠禎. All rights reserved.
//


import UIKit

enum TableViewCurrentDisplaySwitcher {
    case displaying, unDisplay
    mutating func next(){
        
        switch self {
        case .displaying:
            self = .unDisplay
            
        case .unDisplay:
            self = .displaying
            
        }
        
    }
}

extension MapViewController: UITableViewDataSource, UITableViewDelegate {
    
    var yDelta: CGFloat { get { return 500 } }
    var cellSpacingHeight: CGFloat { get { return 5 } }
    
    @IBAction func titleBtnPressed(_ sender: AnyObject) {
        guard tableViewCanDoNext else {
            return
        }
        
        switch currentStateOfTableViewDisplaying {
            
        case .unDisplay:
            //defult on the screen
            DispatchQueue.main.async {
                self.showUpTableView(self.UITableView)
                self.locationArrowImage.isEnabled = false
            }
            
            setTrackModeNone()                          //turn off the Tracking module
            currentStateOfTableViewDisplaying.next()
            
        case .displaying:
            
            DispatchQueue.main.async {
                
                self.unShowTableView(self.UITableView)
                self.locationArrowImage.isEnabled = true
            }
            
            
            currentStateOfTableViewDisplaying.next()
        }
        
    }
    
    func showUpTableView(_ moveView: UIView){
        self.tableViewCanDoNext = false
        
        //        show subview from top
        //        print("self.tableViewCanDoNext \(self.tableViewCanDoNext)")
        //        print("UITableView Postition \(UITableView.center) ")
        //        print("Show up Table View   : Y + yDelta")
        
        moveView.center = CGPoint(x: moveView.center.x, y:moveView.center.y - self.yDelta )
        moveView.isHidden = false
        self.visualEffectView.isHidden = false
        
        UIView.animate(withDuration: 0.3, delay: 0, options:[UIViewAnimationOptions.allowAnimatedContent, UIViewAnimationOptions.curveEaseInOut],
        animations: {
                        
        moveView.center = CGPoint(x: moveView.center.x, y:moveView.center.y + self.yDelta)
        self.rotationArrow.imageView?.transform = CGAffineTransform(rotationAngle: 180.toRadian)
        self.visualEffectView.effect = self.effect
           moveView.alpha = 1
        },
                       
        completion: { (finished: Bool) in
                        
        self.tableViewCanDoNext = true
                        
                        //        print("y: \(moveView.center.y)")
                        
        })
    }
    
    
    
    
    func unShowTableView(_ moveView: UIView){
        //        show subview out to top
        //        print("Show off Table View  : Y - yDelta")
        
        self.tableViewCanDoNext = false //operation for safe display tableview
        
        
        UIView.animate(withDuration: 0.3, delay: 0, options:[UIViewAnimationOptions.allowAnimatedContent, UIViewAnimationOptions.curveEaseInOut], animations: {
            
            moveView.center = CGPoint(x: moveView.center.x, y:moveView.center.y - self.yDelta)
            self.rotationArrow.imageView?.transform = CGAffineTransform(rotationAngle: 0)
            self.visualEffectView.effect = nil
            moveView.alpha = 0
        }, completion: { _ in
            //            print("show off animation is completion")
            
            moveView.isHidden = true
            self.visualEffectView.isHidden = true
            
            moveView.center = CGPoint(x: moveView.center.x, y:moveView.center.y + self.yDelta )
            //            print("y: \(moveView.center.y)")
            self.tableViewCanDoNext = true
            
        })
    }
    
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 12
    }
    //    set cell space hight
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
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
            cell.thanksLabel.text = "   本程式資料來源係由各地方政府及其合作廠商之公開資訊、恕不保證內容準確性，本程式之所有權為作者所有。"
            cellCustomize(cell: cell)
            return cell
            
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "aboutUs", for: indexPath) as! aboutUsTableViewCell
            cellCustomize(cell: cell)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
