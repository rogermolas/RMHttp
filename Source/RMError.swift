//
//  RMError.swift
//  RMHttp
//
//  Created by Roger Molas on 12/04/2018.
//  Copyright © 2018 Roger Molas. All rights reserved.
//

import Foundation

open class RMError {
    
    var response: RMResponse? = nil
    init() { }
}

extension RMError: CustomStringConvertible {
    public var description: String {
        return "Error Logs"
    }
}
