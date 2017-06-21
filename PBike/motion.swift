//
//  motion.swift
//  GoBike
//
//  Created by 陳 冠禎 on 2016/12/29.
//  Refactored by 陳 冠禎 on 2017/06/20.
//  Copyright © 2016年 陳 冠禎. All rights reserved.
//

import UIKit

protocol MotionEffectable {
      func applyMotionEffect(toView view: UIView, magnitude: Float)
}

extension MotionEffectable {
    
    func applyMotionEffect(toView view: UIView, magnitude: Float) {
        let xMotion = UIInterpolatingMotionEffect(keyPath: "center.x", type: .tiltAlongHorizontalAxis)
        xMotion.minimumRelativeValue = -magnitude
        xMotion.maximumRelativeValue = magnitude
        
        let yMotion = UIInterpolatingMotionEffect(keyPath: "center.y", type: .tiltAlongVerticalAxis)
        yMotion.maximumRelativeValue = magnitude
        yMotion.minimumRelativeValue = -magnitude
        
        let group = UIMotionEffectGroup()
        group.motionEffects = [xMotion, yMotion]
        view.addMotionEffect(group)
        
    }
}
