//
//  RMHttp.swift
//  RMHttp
//
//  Created by Roger Molas on 13/04/2018.
//  Copyright © 2018 Roger Molas. All rights reserved.
//

import Foundation

typealias RMHttpCompleteRequest = (RMResponse) -> Swift.Void
typealias RMHttpCompleteString = (String?) -> Swift.Void
typealias RMHttpErrorRequest = (RMError?) -> Swift.Void

open class RMHttp {

}

// RESTful API Call
extension RMHttp {
    class func request(completionHandler:@escaping RMHttpCompleteRequest,
                       errorHandler: @escaping RMHttpErrorRequest,
                       type: RMResponseType,
                       request: RMRequest) {
        
        RMRequestManager.sharedManager.sendRequest(completionHandler: { (response) in
            
//            response?.statusCode
            if type == .object {
                let object = response?.JSONResponse(type: .object, value: JSONObject())
               print(object?.value ?? "\(String(describing: object!.error))")
            
            } else if type == .array {
                let array = response?.JSONResponse(type: .array, value: JSONArray())
                print(array?.value ?? "\(String(describing: array!.error))")
            
            } else {
                let stringResponse = response?.StringResponse(encoding: .utf8)
                print(stringResponse?.value ?? "\(String(describing: stringResponse!.error))")
            }
        
        }, errorHandler: { (error) in // contains RMHttpError object
            errorHandler(error)
        
        }, request: request)
    }
}
