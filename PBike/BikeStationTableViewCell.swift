//
//  BikeStationTableViewCell.swift
//  PBike
//
//  Created by 陳 冠禎 on 2016/10/16.
//  Copyright © 2016年 陳 冠禎. All rights reserved.
//

import UIKit

final class BikeStationTableViewCell: UITableViewCell {

    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var locationLabel: UILabel!
    @IBOutlet weak var currentBikeNumber: UILabel!
    @IBOutlet weak var parkNumber: UILabel!
    @IBOutlet var parkingImageView: UIImageView!
    @IBOutlet var bikeImageView: UIImageView!
    @IBOutlet var navigationImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
