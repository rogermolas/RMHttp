/*
 MIT License
 
 RMHttp.swift
 Copyright (c) 2018 Roger Molas
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */


import Foundation

open class RMHttp { }

// RESTful API Call
extension RMHttp {
    
    public static let requestManager = RMRequestManager.sharedManager
    
    public class func request<T:RMHttpProtocol>(urlRequest: RMRequest,
                                                completionHandler: @escaping (_ data: T?) -> Swift.Void,
                                                errorHandler: @escaping (_ error: RMError?) -> Swift.Void) {
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
        
        }, request: urlRequest)
    }
}
