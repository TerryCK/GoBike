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
    
    
    func testDisplayOfTimeFormation() {
        let testCaseA: String = 1800.convertToHMS
        let testCaseB: String = 9.convertToHMS
        let testCaseC: String = (-1).convertToHMS
        let testCaseD: String = (-10).convertToHMS
        let testCaseE: String = (-1800).convertToHMS
        
        let expectCaseA = "30:00 "
        let expectCaseB = "0:09 "
        let expectCaseC = "0:01 "
        let expectCaseD = "0:10 "
        let expectCaseE = "30:00 "
        
        XCTAssertEqual(testCaseA, expectCaseA)
        XCTAssertEqual(testCaseB, expectCaseB)
        XCTAssertEqual(testCaseC, expectCaseC)
        XCTAssertEqual(testCaseD, expectCaseD)
        XCTAssertEqual(testCaseE, expectCaseE)
        
    }
    
//    func testBikeAPI() {
//        
//        let city: City = .Taipei
//        
//        let url = Bundle.main.path(forResource: "YouBikeTP", ofType: ".gz")!
//        let isHere = true
//        let bikeVision:BikeVision = .UBike
//        let dataType:DataType  = .JSON
//        
//        let caseApi = BikeAPI(city: city, url: url, isHere: isHere, bikeVision: bikeVision , dataType: dataType)
//        
//        let bikeStationModel = BikeStationsModel()
//        
//            
//        
//    }
    
    
    
    func testGetTheUserLocationBikeStationInfo() {
        
    }
    //
    //    func testParser(){
    //        //JSON
    //        //XML
    //        //HTML
    //    }
    //
    //    func testCustomAnnotationView(){
    //
    //    }
    //
    //    func testTableViewContorller(){
    //
    //    }
    
    
    
    
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
