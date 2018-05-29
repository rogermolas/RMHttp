//
//  ValidationTest.swift
//  DemoTests
//
//  Created by Greatfeat on 29/05/2018.
//  Copyright © 2018 Roger Molas. All rights reserved.
//

import XCTest

@testable import Demo
import RMHttp

class ValidationTest: XCTestCase {
    
    func testRequestResponseValidation() {
        let expectation = XCTestExpectation(description: "testRequestResponseValidation")
        let urlString = "https://httpbin.org/get"
        let request = RMRequest(urlString, method: .GET(.URLEncoding), parameters: nil, hearders: nil)
        RMHttp.response(request: request) { (response, error) in
            
            guard error == nil else {
                XCTFail()
                expectation.fulfill()
                return
            }
 
            guard let headers = response.allHeaders as? [String: String] else {
                XCTFail()
                expectation.fulfill()
                return
            }
            XCTAssertEqual(response.statusCode, 200)
            XCTAssertEqual(headers["Content-Type"], "application/json")
            XCTAssertEqual(request.urlRequest.httpMethod!, "GET")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)
    }
}
