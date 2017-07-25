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
        guard tableViewCanDoNext else { return }

        let yDelta: CGFloat = 500

        switch tableViewIsShowing {

        case false:
            self.showUpTableView(self.UITableView, movedBy: yDelta)
            tableViewIsShowing = true
        case true:
            self.unShowTableView()
            tableViewIsShowing = false

        }

    }

     func showUpTableView(_ moveView: UIView, movedBy yDelta: CGFloat) {
        self.tableViewCanDoNext = false
        self.locationArrowImage.isEnabled = false
        self.setTrackModeNone()
        let originX = moveView.center.x
        let startPointY = moveView.center.y - yDelta
    
        
        
        visualEffectView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(unShowTableView)))

        moveView.center = CGPoint(x: originX, y: startPointY)
        moveView.isHidden = false

        self.visualEffectView.isHidden = false

        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       options:[.allowAnimatedContent, .curveEaseInOut],
                       animations: { doAnimation() },
                       completion: { completeAction(isFinished: $0) }
        )

        func doAnimation() {
            let endPointY  = moveView.center.y + yDelta
            moveView.center = CGPoint(x: originX, y: endPointY)
            self.rotationArrow.imageView?.transform = CGAffineTransform(rotationAngle: 180.toRadian)
            
            self.visualEffectView.effect = self.effect
            self.visualEffectView.alpha = 0.98
            moveView.alpha = 1
        }

        func completeAction(isFinished: Bool) {
            self.tableViewCanDoNext = isFinished
        }
    }

    @objc private func unShowTableView() {

        let moveView = UITableView!
        self.tableViewCanDoNext = false
        let originX = moveView.center.x
        let startPointY = moveView.center.y - yDelta

        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       options:[.allowAnimatedContent, .curveEaseInOut],
                       animations: { doAnimation() },
                       completion: { completeAction(isFinished: $0) }
        )

        func doAnimation() {
            moveView.alpha = 0
            moveView.center = CGPoint(x: originX, y: startPointY)
            self.rotationArrow.imageView?.transform = CGAffineTransform(rotationAngle: 0)
            self.visualEffectView.alpha = 0
            
            
        }

        func completeAction(isFinished: Bool) {
            moveView.isHidden = isFinished
            let endPoint = moveView.center.y + yDelta
            moveView.center = CGPoint(x: originX, y: endPoint)
            self.visualEffectView.isHidden = isFinished
            self.tableViewCanDoNext = isFinished
            self.locationArrowImage.isEnabled = true
            self.visualEffectView.effect = nil
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
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
            cell.peopleNumberLabel.text = String(self.bikeInUsing) ?? ""
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "aboutUs", for: indexPath) as! AboutUsTableViewCell
            cellCustomize(cell: cell)
            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.section).")
    }

    func cellCustomize(cell: UITableViewCell) {

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
