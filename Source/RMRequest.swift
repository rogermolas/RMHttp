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
    open var request: URLRequest
    open var timeoutIntervalForRequest: TimeInterval = 30
    
    init(urlString: String, method: RMRequestMethod, hearder: [AnyHashable : Any]!) {
        let url = URL(string: urlString)
        self.request = URLRequest(url: url!)
        self.request.httpMethod = method.rawValue
        self.request.allHTTPHeaderFields = hearder as? [String : String]
    }
    
    init(url: URL) {
        self.request = URLRequest(url: url)
    }
    
    init(urlRequest: URLRequest) {
        self.request = urlRequest
    }
    
    init(url: URL, cachePolicy: URLRequest.CachePolicy, timeoutInterval: TimeInterval) {
        self.request = URLRequest(url: url, cachePolicy: cachePolicy, timeoutInterval: timeoutInterval)
    }
}
