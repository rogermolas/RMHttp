//
//  ParsingTest.swift
//  DemoTests
//
//  Created by Greatfeat on 29/05/2018.
//  Copyright © 2018 Roger Molas. All rights reserved.
//

import XCTest
import Foundation

@testable import Demo
@testable import RMHttp
import RMHttp

class ParsingTest: XCTestCase {

    func testParseJSONObject() {
        let expectation = XCTestExpectation(description: "testParseJSONObject")
        let urlString = "https://httpbin.org/get"
        let request = RMRequest(urlString, method: .GET(.URLEncoding), parameters: nil, hearders: nil)
        RMHttp.JSON(request: request) { (response:JSONObject?, error) in
            guard error == nil else {
                XCTFail()
                expectation.fulfill()
                return
            }
            
            if let data = response {
                XCTAssertNotNil(data, "No data was downloaded.")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testHandleParsingError() {
        let expectation = XCTestExpectation(description: "testHandleParsingError")
        let urlString = "https://httpbin.org/getxx"  // invalid URL
        let request = RMRequest(urlString, method: .GET(.URLEncoding), parameters: nil, hearders: nil)
        RMHttp.JSON(request: request) { (response:JSONObject?, error) in
            guard error == nil else {
                XCTAssertNotNil(error, "Expected Error")
                expectation.fulfill()
                return
            }
            XCTFail()
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)
    }
}
