//
//  RMError.swift
//  RMHttp
//
//  Created by Roger Molas on 12/04/2018.
//  Copyright © 2018 Roger Molas. All rights reserved.
//

import Foundation

public var RMHttpErrorKey:UInt8 = 0

open class RMError {
    var domain: String? = nil
    var reason: String? = nil
    var error: Error? = nil
    var request: RMRequest? = nil
    var response: RMResponse? = nil
    var info:Dictionary<String, Any> = Dictionary<String, Any>()
    
    public init(error: Error) {
        self.domain = "com.RMError.response"
        self.error = error
    }
    
    public init() {
        self.domain = "com.RMError.response"
    }
    
    public func set(info:Dictionary<String, Any>) {
        self.info = info
    }
    
    public func setHttpResponse<T>(error: RMHttpParsingError<T>) {
        var reason = ""
        let type:String? = String(describing: T.getType())
        switch error {
        case .invalidData:
            reason = "No data found : \(String(describing: response?.statusCode))"
            break
        case .invalidType:
            reason = "\(type!) : Response type mismatch"
            break
        case .noData:
            reason = "Failed \(type!) : Status: \(String(describing: response?.url?.absoluteString)) : \(String(describing: response?.statusCode!))"
            break
        case .unknown:
            reason = "Unknown Error <\(type!)>"
            break
        }
        self.reason = reason
    }
}

extension RMError: CustomStringConvertible {
    public var description: String {
        var desc: [String] = []
        if let mDomain = domain {
            desc.append("\n\(mDomain)")
        }
        if let mReason = reason {
            desc.append(mReason)
        }
        if let mError = error {
            desc.append(mError.localizedDescription)
        }
        if let mRequest = request {
            desc.append(mRequest.description)
        }
        return desc.joined(separator: " : ")
    }
}
