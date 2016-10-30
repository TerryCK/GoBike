//
//  RateingReportTableViewCell.swift
//  PBike
//
//  Created by 陳 冠禎 on 2016/10/28.
//  Copyright © 2016年 陳 冠禎. All rights reserved.
//

import UIKit

class RateingReportTableViewCell: UITableViewCell {

    @IBOutlet weak var report: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        report.layer.borderWidth = 0
        report.layer.cornerRadius = 8
        report.clipsToBounds = true
       
//        report.backgroundView.alpha = 0.9
        report.layoutMargins = UIEdgeInsets.zero
      
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
