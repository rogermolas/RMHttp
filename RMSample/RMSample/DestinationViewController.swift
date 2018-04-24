//
//  DestinationViewController.swift
//  RMHttp
//
//  Created by Roger Molas on 23/04/2018.
//  Copyright © 2018 Roger Molas. All rights reserved.
//

import Foundation
import UIKit

class DestinationViewController: UIViewController {
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var activity: UIActivityIndicatorView!
    
    public var type: String = ""

    
    override func viewDidLoad() {
        super.viewDidLoad()
        if type == "GET" {
            reques(request: buildGETRequest()!, expected: JSONObject())
        }
        if type == "POST" {
            reques(request: buildPOSTRequest()!, expected: JSONObject())
        }
        if type == "DELETE" {
            reques(request: buildDELETERequest()!, expected: JSONObject())
        }
        if type == "STRING RESPONSE" {
            reques(request: buildGETHTMRequest()!, expected: String())
        }
    }
    
    func reques<T:RMHttpProtocol>(request: RMRequest, expected: T) {
        RMHttp.request(completionHandler: { (response: T?) in
            if let data = response {
                self.title = "Response Sucess"
                self.textView.text = "\(data)"
            }
            self.activity.stopAnimating()
        }, errorHandler: { (error) in
            self.title = "Response Error"
            self.activity.stopAnimating()
            if let err = error {
                self.textView.text = "\(err)"
            }
        }, request: request)
    }

    
    // MARK: - Build POST Request
    func buildPOSTRequest() -> RMRequest? {
        let urlString = "https://httpbin.org/post"
        let request = RMRequest(urlString: urlString,
                                method: RMHttpMethod.POST(Encoding.URLEncoding),
                                parameters: nil,
                                hearders: nil)
        
        print("\nHTTP : Sending POST request : \(request.url!)")
        print("HTTP : Parameters : \(request.parameters!)")
        return request
    }
    
    // MARK: - Build DELETE Request
    func buildDELETERequest() -> RMRequest? {
        let urlString = "https://httpbin.org/delete"
        let request = RMRequest(urlString: urlString,
                                method: RMHttpMethod.DELETE(Encoding.URLEncoding),
                                parameters: nil,
                                hearders:nil)
        
        print("\nHTTP : Sending DELETE request : \(request.url!)")
        print("HTTP : Parameters : \(request.parameters!)")
        return request
    }
    
    // MARK: - Build GET Request
    func buildGETRequest() -> RMRequest? {
        let urlString = "https://httpbin.org/get"
        let request = RMRequest(urlString: urlString,
                                method: RMHttpMethod.GET(Encoding.URLEncoding),
                                parameters: nil,
                                hearders: nil)
        
        print("\nHTTP : Sending GET request : \(request.url!)")
        print("HTTP : Parameters : \(request.parameters!)")
        return request
    }
    
    func buildGETHTMRequest() -> RMRequest? {
        let urlString = "https://httpbin.org/html"
        let request = RMRequest(urlString: urlString,
                                method: RMHttpMethod.GET(Encoding.URLEncoding),
                                parameters: nil,
                                hearders: nil)
        
        print("\nHTTP : Sending GET request : \(request.url!)")
        print("HTTP : Parameters : \(request.parameters!)")
        return request
    }
}
