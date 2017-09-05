//
//  NetworkActivityIndicatorManager.swift
//  PBike
//
//  Created by 陳 冠禎 on 2017/9/5.
//  Copyright © 2017年 陳 冠禎. All rights reserved.
//

import UIKit

final class NetworkActivityIndicatorManager: NSObject {
    
    private override init() { super.init() }
    
    static let shared = NetworkActivityIndicatorManager()
    
    private var loadingCount = 0
    
    
    func networkOperationStarted() {
        
        #if os(iOS)
            if loadingCount == 0 {
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
            }
            loadingCount += 1
        #endif
    }
    
    func networkOperationFinished() {
        #if os(iOS)
            if loadingCount > 0 {
                loadingCount -= 1
            }
            if loadingCount == 0 {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        #endif
    }
}

