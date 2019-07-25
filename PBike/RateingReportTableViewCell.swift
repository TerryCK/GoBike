//
//  RateingReportTableViewCell.swift
//  PBike
//
//  Created by 陳 冠禎 on 2016/10/28.
//  Copyright © 2016年 陳 冠禎. All rights reserved.
//

import UIKit

final class RateingReportTableViewCell: UITableViewCell {

    @IBOutlet weak var report: UIButton! {
        didSet {
            report.layer.borderWidth = 0
            report.layer.cornerRadius = 8
            report.clipsToBounds = true
            report.layoutMargins = .zero
        }
    }

}
