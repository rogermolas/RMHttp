//
//  RMHttp.swift
//  RMHttp
//
//  Created by Roger Molas on 13/04/2018.
//  Copyright © 2018 Roger Molas. All rights reserved.
//

import Foundation

open class RMHttp { }

// RESTful API Call
extension RMHttp {
    
    static let requestManager = RMRequestManager.sharedManager
    
    class func request<T:RMHttpProtocol>(completionHandler: @escaping (_ data: T?) -> Swift.Void,
                                         errorHandler: @escaping (_ error: RMError?) -> Swift.Void,
                                         request: RMRequest) {
        requestManager.sendRequest(completionHandler: { (response) in
            // JSON Object
            if (T.getType() == JSONObject.getType()) {
                let object = response?.JSONResponse(type: .object, value: JSONObject())
                if object?.value != nil {
                    completionHandler((object?.value as! T))
                } else {
                    errorHandler(object?.error)
                }
            // JSON Array
            } else if (T.getType() == JSONArray.getType()) {
                let array = response?.JSONResponse(type: .array, value: JSONArray())
                if array?.value != nil {
                    completionHandler((array?.value as! T))
                } else {
                    errorHandler(array?.error)
                }
            
            } else {
                // Other Response
                if (T.getType() == String.getType()) {
                    let stringResponse = response?.StringResponse(encoding: .utf8)
                    if stringResponse?.value != nil {
                        completionHandler((stringResponse?.value as! T))
                    } else {
                        errorHandler(stringResponse?.error)
                    }
                }
            }
        }, errorHandler: { (error) in // contains RMHttpError object
            errorHandler(error)
        
        }, request: request)
    }
}
