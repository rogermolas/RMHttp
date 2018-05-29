//
//  RequestTest.swift
//  DemoTests
//
//  Created by Greatfeat on 29/05/2018.
//  Copyright © 2018 Roger Molas. All rights reserved.
//

import XCTest
import Foundation

@testable import Demo
import RMHttp

class RequestTest: XCTestCase {
    
    let params = [
        "string":"Ipsum",   // String
        "number": 100,      // Number
        "boolean":true      // Boolean
        ] as [String : Any]
    
    func testGETRequest() {
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
    
    func testPOSTRequest() {
        RMHttp.isDebug = true
        let urlString = "https://httpbin.org/post"
        let request = RMRequest(urlString, method: .POST(.URLEncoding), parameters: nil, hearders: nil)
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
    
    func testDELETERequest() {
        RMHttp.isDebug = true
        let urlString = "https://httpbin.org/delete"
        let request = RMRequest(urlString, method: .DELETE(.URLEncoding), parameters: nil, hearders: nil)
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
    
    func testGETwithParamsRequest() {
        RMHttp.isDebug = true
        let urlString = "https://httpbin.org/get"
        let request = RMRequest(urlString, method: .GET(.URLEncoding), parameters: params, hearders: nil)
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
}
