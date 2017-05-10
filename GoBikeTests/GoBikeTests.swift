//
//  GoBikeTests.swift
//  GoBikeTests
//
//  Created by 陳 冠禎 on 2017/5/8.
//  Copyright © 2017年 陳 冠禎. All rights reserved.
//

import XCTest
@testable import GoBike

class GoBikeTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
//    func testDisplayOfTimeFormation() {
//        let testCaseA = 1800
//        let testCaseB = 9
//        let testCaseC = -1
//        let testCaseD = -10
//        let testCaseE = -1800
//        
//        let expectCaseA = "30:00"
//        let expectCaseB = "0:09"
//        let expectCaseC = "0:01"
//        let expectCaseD = "0:10"
//        let expectCaseE = "30:00"
//
//        let mapVC = MapViewController()
//        XCTAssertEqual(mapVC.timeConverterToHMS(time: testCaseA), expectCaseA)
//        XCTAssertEqual(mapVC.timeConverterToHMS(time: testCaseB), expectCaseB)
//        XCTAssertEqual(mapVC.timeConverterToHMS(time: testCaseC), expectCaseC)
//        XCTAssertEqual(mapVC.timeConverterToHMS(time: testCaseD), expectCaseD)
//        XCTAssertEqual(mapVC.timeConverterToHMS(time: testCaseE), expectCaseE)
//
//
//    }
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
