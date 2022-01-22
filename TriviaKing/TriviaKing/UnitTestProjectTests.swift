//
//  UnitTestProjectTests.swift
//  TriviaKing
//
//  Created by Chris Spiegel on 22.01.22.
//

import XCTest
@testable import TriviaKing

class UnitTestProjectTests: XCTestCase {
    
    

    override func setUpWithError() throws {
        database = LocalStorageController(appDelegate)
        
        
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
