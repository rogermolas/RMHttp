//
//  RMResponse.swift
//  RMHttp
//
//  Created by Roger Molas on 12/04/2018.
//  Copyright © 2018 Roger Molas. All rights reserved.
//

import Foundation

open class RMResponse {
    open var data: NSMutableData? = nil
    open var statusCode: Int!
    open var allHeaders: [AnyHashable : Any]!

    init() {
    }
    
    func dataResponse(data: NSMutableData) {
        self.data = data
    }
}

extension RMResponse: CustomStringConvertible {
    public var description: String {
        return """
        Headers: \(allHeaders),
        Status: \(statusCode)
        """
    }
}
