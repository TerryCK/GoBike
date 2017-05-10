//
//  TimerHandle.swift
//  PBike
//
//  Created by 陳 冠禎 on 2016/12/29.
//  Copyright © 2016年 陳 冠禎. All rights reserved.
//

import UIKit

enum TimerStatus {
    case Pause
    case Play
    case Reset
    mutating func next() {
        
        switch self {
        case .Play:
            self = .Pause
            
        case .Pause:
            self = .Reset
            
        case .Reset:
            self = .Play
        }
    }
}

extension MapViewController {
    
    @IBAction func timerPressed(_ sender: AnyObject) {
        
        let date = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date)
        let seconds = calendar.component(.second, from: date)
        print("hours = \(hour):\(minutes):\(seconds)")
        
        
        
        switch timerStatusReadyTo {
            
        case .Play:
            print("Timer playing")
            
            timeCurrentStatus = .Play
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(MapViewController.decreaseTimer), userInfo: nil, repeats: true)
            timerStatusReadyTo.next()
            
        case .Pause:
            self.timeInPause = time
            print("Timer pause")
            
            timeCurrentStatus = .Pause
            timerLabel.setTitleColor(UIColor.red, for: .normal)
            timerLabel.setTitle("重置", for: .normal)
            timerStatusReadyTo.next()
            
        case .Reset:
            
            print("Timer reset")
            
            timeCurrentStatus = .Reset
            time = 1800
            timer.invalidate()
            timerLabel.setTitleColor(UIColor.gray, for: .normal)
            timerLabel.setTitle(time.convertToHMS, for: UIControlState.normal)
            timerStatusReadyTo.next()
        }
    }
    
    func decreaseTimer() {
        time -= 1
        
        if self.timeCurrentStatus == .Play {
            let timerTittle = time.convertToHMS
            
            switch time {
            case 600...3600:
                timerLabel.setTitleColor(UIColor.black, for: .normal)
                timerLabel.setTitle(timerTittle, for: .normal)
                
            case 0...600:
                timerLabel.setTitleColor(UIColor.red, for: .normal)
                timerLabel.setTitle(timerTittle, for: .normal)
                
            default:
                timerLabel.setTitleColor(UIColor.blue, for: .normal)
                timerLabel.setTitle(timerTittle, for: .normal)
            }
            
        } else if self.timeCurrentStatus == .Pause {
            
            print("reset \(self.time)")
            print("time in pause\(self.timeInPause)")
            let timeToShowReset = timeInPause - self.showTheResetButtonTime
            guard timeToShowReset == self.time else {
                return
            }
            //reset the timer status to defult
            self.timeCurrentStatus = .Play
            self.timerStatusReadyTo = .Pause
        }
    }
}
