//
//  aboutUsTableViewCell.swift
//  PBike
//
//  Created by 陳 冠禎 on 2016/10/27.
//  Copyright © 2016年 陳 冠禎. All rights reserved.
//

import UIKit

final class AboutUsTableViewCell: UITableViewCell {

    @IBOutlet weak var labNameLabel: UILabel! {
        didSet {
            labNameLabel.textColor = .white
        }
    }
}
