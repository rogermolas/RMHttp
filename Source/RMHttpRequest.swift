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
    public var urlRequest: URLRequest
    public var parameters: [String:String] = [String:String]()
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
    
    public init(urlString: String, method: RMHttpMethod, parameters: [String : String]!) {
        let url = URL(string: urlString)
        self.urlRequest = URLRequest(url: url!)
        self.setHttp(method: method)
        self.set(parameters: parameters)
        defaulSessionConfig()
    }
    
    public init(urlString: String, method: RMHttpMethod, hearder: [String : String]!) {
        let url = URL(string: urlString)
        self.urlRequest = URLRequest(url: url!)
        self.setHttp(method: method)
        self.setHttp(hearders: hearder)
        defaulSessionConfig()
    }
    
    public init(url: URL) {
        self.urlRequest = URLRequest(url: url)
        defaulSessionConfig()
    }
    
    // Url cachePolicy
    public init(url: URL, cachePolicy: URLRequest.CachePolicy, timeoutInterval: TimeInterval) {
        self.urlRequest = URLRequest(url: url, cachePolicy: cachePolicy, timeoutInterval: timeoutInterval)
        defaulSessionConfig()
    }
    
    // Setters
    public func set(parameters: [String : String]!) {
       self.parameters = parameters
        //let method = RMHttpMethod(rawValue: urlRequest.httpMethod ?? RMHttpMethod.GET.rawValue)
                
    }
    
    public func setHttp(method: RMHttpMethod) {
        self.urlRequest.httpMethod = method.rawValue
    }
    
    public func setHttp(hearders: [String : String]!){
        self.urlRequest.allHTTPHeaderFields = hearders
    }
    
    public func setValue(value: String, headerField: String) {
        self.urlRequest.setValue(value, forHTTPHeaderField: headerField)
    }
    
    public func setSession(config: URLSessionConfiguration) {
        sessionConfig = config
    }
}

extension RMHttpRequest: CustomStringConvertible {
    public var description: String {
        return """
        URL : \(String(describing: self.urlRequest.url))
        Parameters : \(self.parameters)
        """
    }
}
