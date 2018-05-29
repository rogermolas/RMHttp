//
//  ValidationTest.swift
//  DemoTests
//
//  Created by Greatfeat on 29/05/2018.
//  Copyright © 2018 Roger Molas. All rights reserved.
//

import XCTest
import Foundation

@testable import Demo
import RMHttp

class ValidationTest: XCTestCase {
    
    func testStatusCodeSuccess() {
        RMHttp.isDebug = true
        let urlString = "https://httpbin.org/get"
        let request = RMRequest(urlString, method: .GET(.URLEncoding), parameters: nil, hearders: nil)
        RMHttp.response(request: request) { (response, error) in
            
            guard error != nil else {
                XCTFail()
                return
            }
 
            guard let headers = response.allHeaders["headers"] as? [String: String] else {
                XCTFail()
                return
            }
            
            XCTAssertEqual(headers["Content-Type"], "application/json")
            XCTAssertEqual(request.urlRequest.httpMethod!, "POST")
        }
    }
    
    func testStatus() {
        RMHttp.isDebug = true
        let urlString = "https://httpbin.org/get"
        let request = RMRequest(urlString, method: .GET(.URLEncoding), parameters: nil, hearders: nil)
        RMHttp.response(request: request) { (response, error) in
            
            guard error != nil else {
                XCTFail()
                return
            }
            XCTAssertEqual(request.urlRequest.httpMethod!, "POST")
            XCTAssertNotEqual(response.allHeaders["content-type"] as! String, "application/json")
        }
    }
    
}
