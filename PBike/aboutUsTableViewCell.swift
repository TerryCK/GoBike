//
//  aboutUsTableViewCell.swift
//  PBike
//
//  Created by 陳 冠禎 on 2016/10/27.
//  Copyright © 2016年 陳 冠禎. All rights reserved.
//

import UIKit

class aboutUsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var LabNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        LabNameLabel.textColor = UIColor.white
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
