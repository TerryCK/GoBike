//
//  TimerHandle.swift
//  PBike
//
//  Created by 陳 冠禎 on 2016/12/29.
//  Copyright © 2016年 陳 冠禎. All rights reserved.
//

import UIKit

enum TimerStatus {
    case pause
    case play
    case reset
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
            
        case .play:
            
            print("Timer playing")
            timerStatusReadyTo = .pause
            timeCurrentStatus = .play
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(MapViewController.decreaseTimer), userInfo: nil, repeats: true)
            
        case .pause:
            
            self.timeInPause = time
            print("Timer pause")
            timerStatusReadyTo = .reset
            timeCurrentStatus = .pause
            timerLabel.setTitleColor(UIColor.red, for: .normal)
            timerLabel.setTitle("重置", for: .normal)
            
        case .reset:
            
            time = 1800
            timer.invalidate()
            print("Timer reset")
            timerStatusReadyTo = .play
            timeCurrentStatus = .reset
            timerLabel.setTitleColor(UIColor.gray, for: .normal)
            timerLabel.setTitle(timeConverterToHMS(_seconds: time), for: UIControlState.normal)
        }
    }
    
    func decreaseTimer() {
        time -= 1
        guard self.timeCurrentStatus == .play else { return }
        switch time {
        case 600...3600:
            
            timerLabel.setTitleColor(UIColor.black, for: .normal)
            timerLabel.setTitle(timeConverterToHMS(_seconds: time), for: .normal)
        case 0...600:
            
            timerLabel.setTitleColor(UIColor.red, for: .normal)
            timerLabel.setTitle(timeConverterToHMS(_seconds: time), for: .normal)
        
        default:
            
            timerLabel.setTitleColor(UIColor.blue, for: .normal)
            timerLabel.setTitle(timeConverterToHMS(_seconds: time), for: .normal)
        }
        guard self.timeCurrentStatus == .pause else { return }
        print("reset \(self.time)")
        print("time in pause\(self.timeInPause)")
        let timeToShowReset = timeInPause - self.showTheResetButtonTime
        guard timeToShowReset == self.time else { return }
        print("reset button unshow")
        self.timeCurrentStatus = .play
        self.timerStatusReadyTo = .pause
    }
    
    func timeConverterToHMS(_seconds:Int) -> String {
        var minutes: Int = 0
        var seconds: Int = 0
        var tempSeconds: Int = 0
        var zero:String = ""
        
        tempSeconds = _seconds
        
        if _seconds < 0 { tempSeconds = _seconds * -1 }
        
        minutes = tempSeconds / 60
        seconds = tempSeconds % 60
        
        if seconds < 10 && seconds >= 0 { zero = "0" }
        else { zero = "" }
        
        let time:String = "\(minutes):\(zero)\(seconds) "
        return (time)
    }
    
        
        
}
