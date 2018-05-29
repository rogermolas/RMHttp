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
import RMHttp

class ParsingTest: XCTestCase {
    
    func testParseJSONObject() {
        RMHttp.isDebug = true
        let urlString = "https://httpbin.org/get"
        let request = RMRequest(urlString, method: .GET(.URLEncoding), parameters: nil, hearders: nil)
        RMHttp.JSON(request: request) { (response:JSONObject?, error) in
            guard error == nil else {
                XCTFail()
                return
            }
            if let data = response {
                XCTAssert(true, "\(data)")
            }
        }
    }
    
    func testHandleParsingError() {
        RMHttp.isDebug = true
        let urlString = "https://httpbin.org/getxx"  // invalid URL
        let request = RMRequest(urlString, method: .GET(.URLEncoding), parameters: nil, hearders: nil)
        RMHttp.JSON(request: request) { (response:JSONObject?, error) in
            guard error == nil else {
                XCTAssertTrue(error != nil)
                return
            }
            XCTFail()
        }
    }
}
