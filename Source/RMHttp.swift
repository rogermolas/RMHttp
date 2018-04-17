//
//  RMHttp.swift
//  RMHttp
//
//  Created by Roger Molas on 13/04/2018.
//  Copyright © 2018 Roger Molas. All rights reserved.
//

import Foundation

typealias RMHttpCompleteRequest = (RMHttpResponse) -> Swift.Void
typealias RMHttpCompleteString = (String?) -> Swift.Void
typealias RMHttpErrorRequest = (RMHttpError?) -> Swift.Void

open class RMHttp {

    class func request(completionHandler: @escaping RMHttpCompleteRequest,
                       errorHandler: @escaping RMHttpErrorRequest,
                       type: RMHttpType,
                       request: RMHttpRequest) {
        RMHttpRequestManager.sharedManager.sendRequest(completionHandler: { (response) in
            
            if type == .object {
                let object = response?.JSONResponse(type: RMHttpType.object, value: JSONObject())
                print(object?.value ?? "Erroor")
                print(object?.type ?? "Erroor")
            }
                
            
            else if type == .array {
                let array = response?.JSONResponse(type: RMHttpType.array, value: JSONArray())
                print(array?.value ?? "Erroor")
                print(array?.type ?? "Erroor")
            }
            
            else {
                let stringResponse = response?.StringResponse(encoding: .utf8)
                print(stringResponse?.value ?? "Erroor")
                print(stringResponse?.type ?? "Erroor")
            }
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
