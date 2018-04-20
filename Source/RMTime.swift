//
//  RMTime.swift
//  RMHttp
//
//  Created by Roger Molas on 13/04/2018.
//  Copyright © 2018 Roger Molas. All rights reserved.
//

import Foundation

public struct RMTime {
    public let requestTime: CFAbsoluteTime
    public let initialResponseTime: CFAbsoluteTime
    public let requestCompletionTime: CFAbsoluteTime
    
    public let requestDuration: TimeInterval
    
    public init(
        requestTime:CFAbsoluteTime = 0.0,
        initializeResponseTime: CFAbsoluteTime = 0.0,
        requestCompletionTime: CFAbsoluteTime = 0.0) {
        
        self.requestTime = requestTime
        self.initialResponseTime = initializeResponseTime
        self.requestCompletionTime = requestCompletionTime
        self.requestDuration = requestTime - requestCompletionTime
    }
}
