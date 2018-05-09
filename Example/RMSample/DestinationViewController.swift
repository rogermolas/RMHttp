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
    
    var POST: RMRequest {
        let urlString = "https://httpbin.org/post"
        let request = RMRequest(urlString, method: .POST(.URLEncoding), parameters: nil, hearders: nil)
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
        if type == "POST" {
            reques(request: POST, expected: JSONObject())
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
