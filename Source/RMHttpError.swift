//
//  RMError.swift
//  RMHttp
//
//  Created by Roger Molas on 12/04/2018.
//  Copyright © 2018 Roger Molas. All rights reserved.
//

import Foundation

open class RMHttpError {
    var domain: String? = nil
    var error: Error? = nil
    var request: RMHttpRequest? = nil
    var response: RMHttpResponse? = nil
    var info:Dictionary<String, Any> = Dictionary<String, Any>()
    
    public init() { }
    
    public func set(info:Dictionary<String, Any>) {
        self.info = info
    }
}

extension RMHttpError: CustomStringConvertible {
    public var description: String {
        return """
        Domain: \(domain ?? "Unknown")
        Debug Description: \(error.debugDescription)
        """
    }
}
