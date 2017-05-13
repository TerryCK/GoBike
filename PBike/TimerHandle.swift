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



extension MapViewController: TimerHandlerDelegate  {

    
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
            
        case .Play:
            play()
            
        case .Pause:
            pause()
            
        case .Reset:
            reset()
        }
    }
    
    
    func decreaseTimer() {
        time -= 1
        
        if self.timerCurrentStatusFlag == .Play {
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
            
        } else if self.timerCurrentStatusFlag == .Pause {
            
            print("reset \(self.time)")
            print("time in pause time: \(self.timeInPause.convertToHMS)")
            let timeToShowReset = timeInPause - self.showTheResetButtonTime
            guard timeToShowReset == self.time else {
                return
            }
            //reset the timer status to defult
            self.timerCurrentStatusFlag = .Play
            self.timerStatusReadyTo = .Pause
        }
    }
    
    func play() {
        print("Timer playing")
        
        timerCurrentStatusFlag = .Play
        print("timerCurrentStatusFlag", timerCurrentStatusFlag)
        rentedTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(MapViewController.decreaseTimer), userInfo: nil, repeats: true)
        timerStatusReadyTo.next()
        

    }
    func pause() {
        self.timeInPause = time
        print("Timer pause")
        
        timerCurrentStatusFlag = .Pause
        print("timerCurrentStatusFlag", timerCurrentStatusFlag)
        timerLabel.setTitleColor(UIColor.red, for: .normal)
        timerLabel.setTitle("重置", for: .normal)
        timerStatusReadyTo.next()
        
        
    }
    
    func reset() {
        
        print("Timer reset")
        
        timerCurrentStatusFlag = .Reset
         print("timerCurrentStatusFlag", timerCurrentStatusFlag)
        time = 1800
        rentedTimer.invalidate()
        timerLabel.setTitleColor(UIColor.gray, for: .normal)
        timerLabel.setTitle(time.convertToHMS, for: UIControlState.normal)
        timerStatusReadyTo.next()
   

    }
}
