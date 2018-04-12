//
//  RMRequest.swift
//  RMHttp
//
//  Created by Roger Molas on 12/04/2018.
//  Copyright © 2018 Roger Molas. All rights reserved.
//

import Foundation

open class RMRequest {
    open var request: URLRequest
    open var timeoutIntervalForRequest: TimeInterval = 30
    
    init(url: URL) {
        self.request = URLRequest(url: url)
    }
    
    init(url: URL, cachePolicy: URLRequest.CachePolicy, timeoutInterval: TimeInterval) {
        self.request = URLRequest(url: url, cachePolicy: cachePolicy, timeoutInterval: timeoutInterval)
    }
}
