//
//  RMResponse.swift
//  RMHttp
//
//  Created by Roger Molas on 12/04/2018.
//  Copyright © 2018 Roger Molas. All rights reserved.
//

import Foundation

public enum HTTPObject<Value> {
    case value(Value)
    case error(RMError)
}

open class RMResponse {
    public var data: NSMutableData? = nil
    public var statusCode: Int!
    public var allHeaders: [AnyHashable : Any]!
    public var httpResponse: HTTPURLResponse!
    
    init() { }

    func dataResponse(data: NSMutableData) {
        self.data = data
    }
    
    func JSONResponse<T>(result: HTTPObject<T>) -> T {
        return httpResponseObject(data: self.data! as Data, result:result)
    }
    
    private func httpResponseObject<T>(data: Data, result:HTTPObject<T>) -> T {
        do {
            let object = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! T
            return object
        } catch {
            return HTTPObject<RMError>.error(RMError()) as! T
        }
    }
}

extension RMResponse: CustomStringConvertible {
    public var description: String {
        return """
        Headers: \(allHeaders!),
        
        Status: \(statusCode!)
        """
    }
}
