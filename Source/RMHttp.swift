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
typealias RMHttpErrorRequest = (RMHttpError?) -> Swift.Void

open class RMHttp {

    class func jsonRequest(completionHandler: @escaping RMHttpCompleteRequest,
                           errorHandler: @escaping RMHttpErrorRequest,
                           request: RMHttpRequest) {
        RMHttpRequestManager.sharedManager.sendRequest(completionHandler: { (response) in
            let json = response?.JSONResponse(type: RMHttpJSON.array, value: JSONArray())
            print(json?.getValue() ?? "")
        
        }, errorHandler: { (error) in
            errorHandler(error)
        }, request: request)
    }
    
    class func stringRequest(completionHandler: @escaping RMHttpCompleteString,
                             errorHandler: @escaping RMHttpErrorRequest,
                             request: RMHttpRequest) {
        RMHttpRequestManager.sharedManager.sendRequest(completionHandler: { (response) in
            let stringResponse = response?.StringResponse(encoding: .utf8)
            if stringResponse != nil {
                completionHandler(stringResponse?.value!)
            } else {
                errorHandler(RMHttpError())
            }
        }, errorHandler: { (error) in
            errorHandler(error)
        }, request: request)
    }
}
