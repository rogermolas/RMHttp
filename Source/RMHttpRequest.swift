//
//  RMRequest.swift
//  RMHttp
//
//  Created by Roger Molas on 12/04/2018.
//  Copyright © 2018 Roger Molas. All rights reserved.
//

import Foundation

public enum RMHttpMethod: String {
    case GET        = "GET"
    case POST       = "POST"
    case DELETE     = "DELETE"
    case PATCH      = "PATCH"
    case PUT        = "PUT"
}

open class RMHttpRequest {
    public var urlRequest: URLRequest!
    public var parameters: [String:String]!
    public var allHeaders: [String:String]!
    public var sessionConfig:URLSessionConfiguration!
    public var restrictStatusCodes:Set<Int> = []  // e.g 404, 500, return Error
    
    public var timeoutIntervalForRequest: TimeInterval = 30
    public var timeoutIntervalForResource: TimeInterval = 30
    public var httpMaximumConnectionsPerHost: Int = 1
    
    private func defaulSessionConfig() {
        sessionConfig = URLSessionConfiguration.default
        sessionConfig.allowsCellularAccess = true // use cellular data
        sessionConfig.timeoutIntervalForRequest = timeoutIntervalForRequest // timeout per request
        sessionConfig.timeoutIntervalForResource = timeoutIntervalForResource // timeout per resource access
        sessionConfig.httpMaximumConnectionsPerHost = httpMaximumConnectionsPerHost // connection per host
    }
    
    public init(urlString: String,
                method: RMHttpMethod,
                parameters: [String : String]!) {
        
        let url = URL(string: urlString)
        self.urlRequest = URLRequest(url: url!)
        
        self.setHttp(method: method)
        self.set(parameters: parameters)
        defaulSessionConfig()
    }
    
    public init(urlString: String,
                method: RMHttpMethod,
                parameters: [String : String]!,
                hearders: [String : String]!) {
        
        let url = URL(string: urlString)
        self.urlRequest = URLRequest(url: url!)
        self.setHttp(method: method)
        self.setHttp(hearders: hearders)
        defaulSessionConfig()
    }
    
    // -
    public init(url: URL) {
        self.urlRequest = URLRequest(url: url)
        defaulSessionConfig()
    }
    
    // Url cachePolicy
    public init(url: URL, cachePolicy: URLRequest.CachePolicy, timeoutInterval: TimeInterval) {
        self.urlRequest = URLRequest(url: url, cachePolicy: cachePolicy, timeoutInterval: timeoutInterval)
        defaulSessionConfig()
    }
    
    // Set and append parameters to base URL
    public func set(parameters: [String : String]!) {
        self.parameters = parameters
        let paramString = RMHttpBuilder().build(parameters)
        var component = URLComponents(url: urlRequest.url!, resolvingAgainstBaseURL: false)
        component?.percentEncodedQuery = paramString
        urlRequest.url = component?.url
    }
    
    // Assign http Method
    public func setHttp(method: RMHttpMethod) {
        self.urlRequest.httpMethod = method.rawValue
    }
    
    // Assign all headers
    public func setHttp(hearders: [String : String]!){
        self.allHeaders = hearders
        if let mHeaders = hearders {
            for (field, value) in mHeaders {
                self.setValue(value: value, headerField: field)
            }
        }
    }
    
    // Manual assign value to header
    public func setValue(value: String, headerField: String) {
        self.urlRequest.setValue(value, forHTTPHeaderField: headerField)
    }
    
    // Custom Session config
    public func setSession(config: URLSessionConfiguration) {
        sessionConfig = config
    }
}

extension RMHttpRequest: CustomStringConvertible {
    public var description: String {
        var desc: [String] = []
        if let request = urlRequest {
            desc.append("\(String(describing: request.url?.absoluteString))")
        }
        if let mParameters = parameters {
            desc.append("\(mParameters)")
        }
        if let mAllHeaders = allHeaders {
            desc.append("\(mAllHeaders)")
        }
        return desc.joined(separator: " : ")
    }
}
