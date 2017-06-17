//
//  TimerHandle.swift
//  PBike
//
//  Created by 陳 冠禎 on 2016/12/29.
//  Copyright © 2016年 陳 冠禎. All rights reserved.
//

import UIKit

protocol TimerHandlerDelegate: class {
    var timerCurrentStatusFlag: TimerStatus { get }
    var time: Int { set get }
}


protocol TimeStatueProtocol {
    func play()
    func pause()
    func reset()
}

enum TimerStatus {
    case pause
    case play
    case reset
    
    mutating func next() {
        
        switch self {
        case .play:
            self = .pause
            
        case .pause:
            self = .reset
            
        case .reset:
            self = .play
        }
    }
}



extension MapViewController: TimerHandlerDelegate, TimeStatueProtocol {
    
    
    @IBAction func timerPressed(_ sender: AnyObject) {
        timerCounterStatus()
    }
    
    
    func timerCounterStatus() {
        
        let date = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date)
        let seconds = calendar.component(.second, from: date)
        
        
        print("hours = \(hour):\(minutes):\(seconds)")
        print("timer flag" , self.timerCurrentStatusFlag)
        
        switch timerStatusReadyTo {
            
        case .play:
            play()
            
        case .pause:
            pause()
            
        case .reset:
            reset()
        }
    }
    
    
    @objc func decreaseTimer() {
        time -= 1
        if self.timerCurrentStatusFlag == .play {
            
            let timerTittle = time.convertToHMS
            let black = UIColor.black
            let red = UIColor.red
            let blue = UIColor.blue
            
            switch time {
                
            case 600...3600:
                timerLabel.setTitleColor(black, for: .normal)
                timerLabel.setTitle(timerTittle, for: .normal)
                
            case 0...600:
                timerLabel.setTitleColor(red, for: .normal)
                timerLabel.setTitle(timerTittle, for: .normal)
                
            default:
                timerLabel.setTitleColor(blue, for: .normal)
                timerLabel.setTitle(timerTittle, for: .normal)
            }
            
        } else if self.timerCurrentStatusFlag == .pause {
            
            print("reset \(self.time)")
            print("time in pause time: \(self.timeInPause.convertToHMS)")
            let timeToShowReset = timeInPause - self.showTheResetButtonTime
            guard timeToShowReset == self.time else {
                return
            }
            //reset the timer status to defult
            self.timerCurrentStatusFlag = .play
            self.timerStatusReadyTo = .pause
        }
    }
    
    func play() {
        print("Timer playing")
        
        timerCurrentStatusFlag = .play
        print("timerCurrentStatusFlag", timerCurrentStatusFlag)
        rentedTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(MapViewController.decreaseTimer), userInfo: nil, repeats: true)
        timerStatusReadyTo.next()
    }
    
    func pause() {
        self.timeInPause = time
        print("Timer pause")
        timerCurrentStatusFlag = .pause
        print("timerCurrentStatusFlag", timerCurrentStatusFlag)
        timerLabel.setTitleColor(UIColor.red, for: .normal)
        timerLabel.setTitle("重置", for: .normal)
        timerStatusReadyTo.next()
    }
    
    func reset() {
        print("Timer reset")
        timerCurrentStatusFlag = .reset
        print("timerCurrentStatusFlag", timerCurrentStatusFlag)
        time = 1800
        rentedTimer.invalidate()
        timerLabel.setTitleColor(UIColor.gray, for: .normal)
        timerLabel.setTitle(time.convertToHMS, for: UIControlState.normal)
        timerStatusReadyTo.next()
        
        
    }
}
