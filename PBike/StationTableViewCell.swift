//
//  StationTableViewCell.swift
//  PBike
//
//  Created by 陳 冠禎 on 2016/10/24.
//  Copyright © 2016年 陳 冠禎. All rights reserved.
//

import UIKit

final class StationTableViewCell: UITableViewCell {

    @IBOutlet weak var peopleNumberLabel: UILabel!
    @IBOutlet weak var rideBikeWithYouLabel: UILabel!

    override func awakeFromNib() {
        peopleNumberLabel.textColor = UIColor.white
        peopleNumberLabel.numberOfLines = 1
        peopleNumberLabel.minimumScaleFactor = 8
        peopleNumberLabel.adjustsFontSizeToFitWidth = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
