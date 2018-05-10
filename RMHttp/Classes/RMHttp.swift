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

open class RMHttp {
    public static let requestManager = RMRequestManager.sharedManager
}

// RESTful API Call
extension RMHttp {
    public class func JSON<T:RMHttpProtocol>( request: RMRequest,
                                              completionHandler:@escaping (_ data:T?, _ error: RMError?) -> ()) {
        
        requestManager.send(request: request) { (response, error) in
            guard error == nil else {
                completionHandler(nil, error)
                return
            }
            
            if let object = response?.JSONResponse(type: T.self) {
                if object.isSuccess {
                    completionHandler(object.value, nil)
                } else {
                    completionHandler(nil, object.error)
                }
            } else { }
        }
    }
}

// MARK: - Codable
extension RMHttp {
    
    public class func JSON<T:Codable>(
        request: RMRequest,
        completionHandler:@escaping (_ data:T?, _ error: RMError?) -> ()) {
        
        requestManager.send(request: request) { (response, error) in
            guard error == nil else {
                completionHandler(nil, error)
                return
            }
            completionHandler(nil, nil)
        }
    }
}
