/*
 MIT License
 
 RMResponse.swift
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

// JSON Type (Object or Array)
public typealias JSONObject = Dictionary<String, Any>
public typealias JSONArray = [Dictionary<String, Any>]

public enum RMResponseType {
    case object
    case array
    case string
}

// Status code that do not contain response data.
private let successStatusCodes: Set<Int> = [204, 205]

open class RMResponse {
    public var data: NSMutableData? = nil
    public var url: URL? = nil
    public var statusCode: Int = 0
    public var allHeaders: [AnyHashable : Any]!
    public var httpResponse: HTTPURLResponse? = nil
    public var timeline: RMTime = RMTime()
    
    public var currentType: RMResponseType!
   
    public init() { }
}

//MARK:- Serialize JSON response via JSONSerialization
extension RMResponse {
    public func JSONResponse<T>(type: T.Type) -> RMHttpObject<T> {
        // Check if status code success but no response
        if self.data == nil && !successStatusCodes.contains((httpResponse?.statusCode)!) {
            let error = RMError()
            error.type = .statusCode
            error.statusCode = self.statusCode
            error.setHttpResponse(error: RMHttpParsingError.noData(NSNull()))
            error.response = self
            return .error(error)
        }
        
        if (T.self == JSONObject.getType()) {  /// JSON Object
            let data =  httpJSONResponseObject(expected: Dictionary<String, Any>())
            if data.isSuccess {
                return data as! RMHttpObject<T>
            }
            return .error(data.error!)
            
        } else if (T.self == JSONArray.getType()) {    /// JSON Array
            let data =  httpJSONResponseArray(expected: [Dictionary<String, Any>()])
            if data.isSuccess {
                return data as! RMHttpObject<T>
            }
            return .error(data.error!)
            
        } else if (T.self == String.getType()) {   /// String
            let data =  StringResponse(encoding: .utf8)
            if data.isSuccess {
                return data as! RMHttpObject<T>
            }
            return .error(data.error!)
        } else {
            let error = RMError()
            error.type = .parsing
            error.statusCode = self.statusCode
            return .error(error)
        }
    }
    
    // Serialize String response
    public func StringResponse(encoding: String.Encoding?) -> RMHttpObject<String> {
        return httpResponseString(encoding: encoding)
    }
}

//MARK: - Serialize JSON response using Codable
extension RMResponse {
    public func object<T:Decodable>(model: T.Type) -> RMHttpObject<T> {
        // Check if status code success but no response
        if self.data == nil && !successStatusCodes.contains((httpResponse?.statusCode)!) {
            let error = RMError()
            error.type = .statusCode
            error.statusCode = self.statusCode
            error.setHttpResponse(error: RMHttpParsingError.noData(NSNull()))
            error.response = self
            return .error(error)
        }
        
        let data =  decodableJSONResponseObject(model: model)
        if data.isSuccess {
            return data
        }
        return .error(data.error!)
    }
}

//MARK: - Private Operations
extension RMResponse {
    
    //MARK:- JSON Object
    private func httpJSONResponseObject<T>(expected: T) -> RMHttpObject<T> where T : RMHttpProtocol {
        let succesDictionary = ["success" : true] as! T
        if let response = httpResponse, successStatusCodes.contains(response.statusCode) { return .success(succesDictionary)}
        do {
            if let object = try JSONSerialization.jsonObject(with: self.data! as Data, options: .allowFragments) as? T {                
                return .success(object)
            } else {
                let error = RMError()
                error.type = .parsing
                error.statusCode = self.statusCode
                error.setHttpResponse(error: RMHttpParsingError.invalidType(expected))
                return .error(error)
            }
        } catch let error {
            let error = RMError(error: error)
            error.type = .parsing
            error.statusCode = self.statusCode
            return .error(error)
        }
    }
    
    //MARK:- JSON Array
    private func httpJSONResponseArray<T>(expected: T) -> RMHttpObject<T> where T : RMHttpProtocol {
        let succesDictionary = [["success" : true]] as! T
        
        if let response = httpResponse, successStatusCodes.contains(response.statusCode) {
            return .success(succesDictionary)
        }
        
        do {
            if let object = try JSONSerialization.jsonObject(with: self.data! as Data, options: .allowFragments) as? T {
                return .success(object)
            } else {
                let error = RMError()
                error.type = .parsing
                error.statusCode = self.statusCode
                error.setHttpResponse(error: RMHttpParsingError.invalidType(expected))
                return .error(error)
            }
        } catch let error {
            let error = RMError(error: error)
            error.type = .parsing
            error.statusCode = self.statusCode
            return .error(error)
        }
    }
    
    //MARK:- String Response
    private func httpResponseString(encoding: String.Encoding?) -> RMHttpObject<String> {
        if let response = httpResponse, successStatusCodes.contains(response.statusCode) { return .success("success") }
        if let string:String = String(data:self.data! as Data, encoding: encoding!) {
            return .success(string)
        }
        let error = RMError()
        error.type = .parsing
        error.statusCode = self.statusCode
        error.setHttpResponse(error: RMHttpParsingError.invalidType(String()))
        return .error(error)
    }
    
    
    //MARK:- Decodable JSON Response
    private func decodableJSONResponseObject<T>(model: T.Type) -> RMHttpObject<T> where T : Decodable {
        do {
            let object = try JSONDecoder().decode(model, from: self.data! as Data)
            return .success(object)
        } catch let error {
            let error = RMError(error: error)
            error.type = .parsing
            error.statusCode = self.statusCode
            return .error(error)
        }
    }
}

extension RMResponse: CustomStringConvertible {
    public var description: String {
        var desc: [String] = []
        if let headers = allHeaders {
            desc.append("\(headers)")
        }
        if let urlRequest = url {
            desc.append("\(urlRequest)")
        }
        desc.append("\(statusCode)")
        return desc.joined(separator: " : ")
    }
}
