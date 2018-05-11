//
//  DestinationViewController.swift
//  RMHttp
//
//  Created by Roger Molas on 23/04/2018.
//  Copyright © 2018 Roger Molas. All rights reserved.
//

import Foundation
import UIKit

import RMHttp

//{
//    args: { },
//    headers: {
//        Accept: "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8",
//        Accept-Encoding: "gzip, deflate, br",
//        Accept-Language: "en-US,en;q=0.9",
//        Cache-Control: "max-age=0",
//        Connection: "close",
//        Cookie: "_gauges_unique_month=1; _gauges_unique_year=1; _gauges_unique=1",
//        Host: "httpbin.org",
//        Upgrade-Insecure-Requests: "1",
//        User-Agent: "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/66.0.3359.139 Safari/537.36"
//    },
//    origin: "180.232.71.19",
//    url: "https://httpbin.org/get"
//}

class DestinationViewController: UIViewController {
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var activity: UIActivityIndicatorView!
    
    public var type: String = ""
    
    var GET: RMRequest {
        let urlString = "https://httpbin.org/get"
        let request = RMRequest(urlString, method: .GET(.URLEncoding), parameters: nil, hearders: nil)
        print("\nHTTP : Sending GET request : \(request.url!)")
        print("HTTP : Parameters : \(request.parameters!)")
        return request
    }
    
    var GET_PARAMS: RMRequest {
        let params = [
            "string":"Ipsum",   // String
            "number": 100,      // Number
            "boolean":true      // Boolean
            ] as [String : Any]
        
        let urlString = "https://httpbin.org/get"
        let request = RMRequest(urlString, method: .GET(.URLEncoding), parameters: params, hearders: nil)
        print("\nHTTP : Sending GET request : \(request.url!)")
        print("HTTP : Parameters : \(request.parameters!)")
        return request
    }
    
    var POST: RMRequest {
        let urlString = "https://httpbin.org/post"
        let request = RMRequest(urlString, method: .POST(.URLEncoding), parameters: nil, hearders: nil)
        print("\nHTTP : Sending POST request : \(request.url!)")
        print("HTTP : Parameters : \(request.parameters!)")
        return request
    }
    
    var POST_PARAMS: RMRequest {
        let params = [
            "string":"Ipsum",   // String
            "number": 100,      // Number
            "boolean":true      // Boolean
            ] as [String : Any]
        
        let urlString = "https://httpbin.org/post"
        let request = RMRequest(urlString, method: .POST(.URLEncoding), parameters: params, hearders: nil)
        print("\nHTTP : Sending POST request : \(request.url!)")
        print("HTTP : Parameters : \(request.parameters!)")
        return request
    }
    
    var POST_JSON_BODY: RMRequest {
        let params = [
            "string":"Ipsum",   // String
            "number": 100,      // Number
            "boolean":true      // Boolean
            ] as [String : Any]
        
        let urlString = "https://httpbin.org/post"
        let request = RMRequest(urlString, method: .POST(.JSONEncoding), parameters: params, hearders: nil)
        print("\nHTTP : Sending POST request : \(request.url!)")
        print("HTTP : Parameters : \(request.parameters!)")
        return request
    }
    
    var DELETE: RMRequest {
        let urlString = "https://httpbin.org/delete"
        let request = RMRequest(urlString, method: .DELETE(.URLEncoding), parameters: nil, hearders:nil)
        print("\nHTTP : Sending DELETE request : \(request.url!)")
        print("HTTP : Parameters : \(request.parameters!)")
        return request
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if type == "GET" {
            reques(request: GET, expected: JSONObject())
        }
        if type == "GET with PARAMS" {
            reques(request: GET_PARAMS, expected: JSONObject())
        }

        if type == "POST" {
            reques(request: POST, expected: JSONObject())
        }
        if type == "POST with PARAMS" {
            reques(request: POST_PARAMS, expected: JSONObject())
        }
        if type == "POST JSON BODY" {
            reques(request: POST_JSON_BODY, expected: JSONObject())
        }
        
        if type == "DELETE" {
            reques(request: DELETE, expected: JSONObject())
        }
        
        if type == "STRING RESPONSE" {
            reques(request: buildGETHTMLStringRequest(), expected: String())
        }
    }
    
    func reques<T:RMHttpProtocol>(request: RMRequest, expected: T) {

        RMHttp.JSON(request: request) { (response:T?, error) in
            guard error == nil else {
                self.title = "Response Error"
                self.activity.stopAnimating()
                if let err = error {
                    self.textView.text = "\(err)"
                }
                return
            }
            if let data = response {
                self.title = "Response Sucess"
                self.textView.text = "\(data)"
            }
            self.activity.stopAnimating()
        }
    }
    
    func buildGETHTMLStringRequest() -> RMRequest {
        let urlString = "https://httpbin.org/html"
        let request = RMRequest(urlString, method: .GET(.URLEncoding), parameters: nil, hearders: nil)
        print("\nHTTP : Sending GET request : \(request.url!)")
        print("HTTP : Parameters : \(request.parameters!)")
        return request
    }
}
