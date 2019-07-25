//
//  StationTableViewCell.swift
//  PBike
//
//  Created by 陳 冠禎 on 2016/10/24.
//  Copyright © 2016年 陳 冠禎. All rights reserved.
//

import UIKit

final class StationTableViewCell: UITableViewCell {

    @IBOutlet weak var peopleNumberLabel: UILabel! {
        didSet {
            peopleNumberLabel.textColor = UIColor.white
            peopleNumberLabel.numberOfLines = 1
            peopleNumberLabel.minimumScaleFactor = 8
            peopleNumberLabel.adjustsFontSizeToFitWidth = true
        }
    }
    @IBOutlet weak var rideBikeWithYouLabel: UILabel!

}
