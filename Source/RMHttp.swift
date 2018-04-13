//
//  RMHttp.swift
//  RMHttp
//
//  Created by Roger Molas on 13/04/2018.
//  Copyright © 2018 Roger Molas. All rights reserved.
//

import Foundation

typealias RMHttpCompleteRequest = (Any) -> Swift.Void
typealias RMHttpCompleteString = (String?) -> Swift.Void
typealias RMHttpErrorRequest = (RMError?) -> Swift.Void

class RMHttp {

    class func jsonRequest(completionHandler: @escaping RMHttpCompleteRequest,
                           errorHandler: @escaping RMHttpErrorRequest,
                           request: RMRequest) {
        
        RMRequestManager.sharedManager.sendRequest(completionHandler: { (response) in
            let json = response?.JSONResponse(type: RMHttpJSON.array([Dictionary<String,Any>()]))
            print(json?.value ?? "")
            print(response?.statusCode)
            print(response?.allHeaders)
        }, errorHandler: { (error) in
            print(error?.response?.statusCode)
            errorHandler(error)
        }, request: request)
    }
    
    class func stringRequest(completionHandler: @escaping RMHttpCompleteString,
                             errorHandler: @escaping RMHttpErrorRequest,
                             request: RMRequest) {
        RMRequestManager.sharedManager.sendRequest(completionHandler: { (response) in
            let stringResponse = response?.StringResponse(encoding: .utf8)
            if stringResponse != nil {
                completionHandler(stringResponse?.value!)
            } else {
                errorHandler(RMError())
            }
        }, errorHandler: { (error) in
            errorHandler(error)
        }, request: request)
    }
}
