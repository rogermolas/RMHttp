/*
 MIT License
 
 RMHttp.swift
 Copyright (c) 2018-2020 Roger Molas
 
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

public typealias JSONHandler<T> = (_ data:T?, _ error: RMError?) -> Void
public typealias ResponseHandler = (_ response: RMResponse, _ error: RMError?) -> Void

open class RMHttp {
    public static let requestManager = RMRequestManager.sharedManager
    public static var isDebug = false
}

// RESTful API Call
extension RMHttp {
    
    // Handle the object type response, on error invoke errorblock
    public class func JSON<T:RMHttpProtocol>(request: RMRequest, completionHandler: @escaping JSONHandler<T>) {
        requestManager.send(request: request) { (response, error) in
            
            guard error == nil else {
                if isDebug {
                    print("""
                        
                        RMHTTP :
                        -- ERROR --
                        - URL: \(request.url.absoluteURL.absoluteString)
                        - Method: \(request.urlRequest.httpMethod!)
                        - Parametters: \(request.parameters ?? [:])
                        - Headers: \(request.allHeaders ?? [:])
                        - Status Code: \(error!.statusCode)
                        - Reason: \(error!.localizeDescription)
                        
                        """)
                }
                completionHandler(nil, error)
                return
            }
            
            let object = response!.JSONResponse(type: T.self)
            if (object.isSuccess) {
                if isDebug {
                    print("""
                        
                        RMHTTP :
                        -- SUCCESS --
                        - URL: \(request.url.absoluteURL.absoluteString)
                        - Method: \(request.urlRequest.httpMethod!)
                        - Parametters: \(request.parameters ?? [:])
                        - Headers: \(request.allHeaders ?? [:])
                        - Status Code: \(response!.statusCode)
                        
                        \(object.value!)
                        
                        """)
                }
                completionHandler(object.value, nil)
                
            } else {
                if isDebug {
                    print("""
                        
                        RMHTTP :
                        -- ERROR --
                        - URL: \(request.url.absoluteURL.absoluteString)
                        - Method: \(request.urlRequest.httpMethod!)
                        - Parametters: \(request.parameters ?? [:])
                        - Headers: \(request.allHeaders ?? [:])
                        - Status Code: \(object.error!.statusCode)
                        
                        \(object.error!)
                        
                        """)
                }
                completionHandler(nil, object.error)
            }
        }
    }
    
    // Return raw response object and error object
    public class func response(request: RMRequest, completionHandler: @escaping ResponseHandler) {
        requestManager.send(request: request) { (response, error) in
            if isDebug {
                
                print("""
                    
                    RMHTTP :
                    -- RESPONSE --
                    - URL: \(request.url.absoluteURL.absoluteString)
                    - Method: \(request.urlRequest.httpMethod!)
                    - Parametters: \(request.parameters ?? [:])
                    - Headers: \(request.allHeaders ?? [:])
                    - Status Code: \(response!.statusCode)
                    
                    \(response!)
                    
                    """)
            }
            completionHandler(response!, error)
        }
    }
}

// MARK: - Codable
extension RMHttp {
    public class func JSON<T: Decodable>(request:RMRequest, model: T.Type, completionHandler:@escaping JSONHandler<T>) {
        requestManager.send(request: request) { (response, error) in
            guard error == nil else {
                if isDebug {
                    print("""
                        
                        RMHTTP :
                        -- ERROR --
                            - URL: \(request.url.absoluteURL.absoluteString)
                            - Method: \(request.urlRequest.httpMethod!)
                            - Parametters: \(request.parameters ?? [:])
                            - Headers: \(request.allHeaders ?? [:])
                            - Status Code: \(error!.statusCode)
                            - Reason: \(error!.localizeDescription)
                        
                        """)
                }
                completionHandler(nil, error)
                return
            }
            let object = response!.object(model: model)
            if (object.isSuccess) {
                if isDebug {
                    print("""
                        
                        RMHTTP :
                        -- SUCCESS --
                        - URL: \(request.url.absoluteURL.absoluteString)
                        - Method: \(request.urlRequest.httpMethod!)
                        - Parametters: \(request.parameters ?? [:])
                        - Headers: \(request.allHeaders ?? [:])
                        - Status Code: \(response!.statusCode)
                        
                        \(object.value!)
                        
                        """)
                }
                completionHandler(object.value, nil)
                
            } else {
                if isDebug {
                    print("""
                        
                        RMHTTP :
                        -- ERROR --
                        - URL: \(request.url.absoluteURL.absoluteString)
                        - Method: \(request.urlRequest.httpMethod!)
                        - Parametters: \(request.parameters ?? [:])
                        - Headers: \(request.allHeaders ?? [:])
                        - Status Code: \(object.error!.statusCode)
                        
                        \(object.error!)
                        
                        """)
                }
                completionHandler(nil, object.error)
            }
        }
    }
}
