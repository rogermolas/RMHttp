//
//  RMRequest.swift
//  RMHttp
//
//  Created by Roger Molas on 12/04/2018.
//  Copyright © 2018 Roger Molas. All rights reserved.
//

import Foundation

public enum RMRequestMethod: String {
    case GET        = "GET"
    case POST       = "POST"
    case DELETE     = "DELETE"
    case PATCH      = "PATCH"
}

open class RMRequest {
    var urlRequest: URLRequest
    var sessionConfig:URLSessionConfiguration!
    var restrictStatusCodes:Set<Int> = []  // e.g 404, 500, return Error
    
    private var timeoutIntervalForRequest: TimeInterval = 30
    private var timeoutIntervalForResource: TimeInterval = 30
    private var httpMaximumConnectionsPerHost: Int = 1
    
    private func setSessionConfig() {
        sessionConfig = URLSessionConfiguration.default
        sessionConfig.allowsCellularAccess = true // use cellular data
        sessionConfig.timeoutIntervalForRequest = timeoutIntervalForRequest // timeout per request
        sessionConfig.timeoutIntervalForResource = timeoutIntervalForResource // timeout per resource access
        sessionConfig.httpMaximumConnectionsPerHost = httpMaximumConnectionsPerHost // connection per host
    }
    
    init(urlString: String, method: RMRequestMethod, hearder: [String : String]!) {
        let url = URL(string: urlString)
        self.urlRequest = URLRequest(url: url!)
        self.urlRequest.httpMethod = method.rawValue
        self.urlRequest.allHTTPHeaderFields = hearder
        setSessionConfig()
    }
    
    init(url: URL) {
        self.urlRequest = URLRequest(url: url)
        setSessionConfig()
    }

    init(urlRequest: URLRequest) {
        self.urlRequest = urlRequest
        setSessionConfig()
    }
    
    init(url: URL, cachePolicy: URLRequest.CachePolicy, timeoutInterval: TimeInterval) {
        self.urlRequest = URLRequest(url: url, cachePolicy: cachePolicy, timeoutInterval: timeoutInterval)
        setSessionConfig()
    }
  
    func setHttp(method: RMRequestMethod) {
        self.urlRequest.httpMethod = method.rawValue
    }
    
    func setHttp(hearders: [String : String]!){
        self.urlRequest.allHTTPHeaderFields = hearders
    }
    
    func setValue(value: String, headerField: String) {
        self.urlRequest.setValue(value, forHTTPHeaderField: headerField)
    }
    
    func setSession(config: URLSessionConfiguration) {
        sessionConfig = config
    }
}
