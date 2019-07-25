//
//  GCDTimer.swift
//  bet188asia
//
//  Created by Kelly Chuang on 13/12/2016.
//  Copyright © 2016 Xuenn. All rights reserved.
//

import Foundation


class GCDTimer {
    
    private let timer: DispatchSourceTimer
    private var isRunning = false
    
   
    
    init(delay: DispatchTimeInterval? = nil, interval: DispatchTimeInterval, repeating: Bool = false, queue: DispatchQueue = .main , onTimeout handler: @escaping (GCDTimer) -> Void) {
        timer = DispatchSource.makeTimerSource(queue: queue)
        timer.setEventHandler { handler(self) }
        timer.schedule(deadline: .now() + (delay ?? interval), repeating: repeating ? interval : .never)
    }
    
    public func start() {
        if !timer.isCancelled {
            resume()
        }
    }
    
    public func resume() {
        if !isRunning {
            timer.resume()
            isRunning = true
        }
    }
    
    public func suspend() {
        if isRunning {
            timer.suspend()
            isRunning = false
        }
    }
    
    public func cancel() {
        if !timer.isCancelled, isRunning {
            timer.cancel()
            isRunning = false
        }
    }
    
    deinit {
        start()
        cancel()
    }
}
