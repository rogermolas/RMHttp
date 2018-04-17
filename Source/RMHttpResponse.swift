//
//  RMResponse.swift
//  RMHttp
//
//  Created by Roger Molas on 12/04/2018.
//  Copyright © 2018 Roger Molas. All rights reserved.
//

import Foundation

// JSON Type (Object or Array)
typealias JSONObject = Dictionary<String, Any>
typealias JSONArray = [Dictionary<String, Any>]

public enum RMHttpType: String {
    case object = "JSONObject"
    case array = "JSONArray"
    case string = "String"
    
}

// Status code that do not contain response data.
private let successStatusCodes: Set<Int> = [204, 205]

open class RMHttpResponse {
    public var data: NSMutableData? = nil
    public var url: URL? = nil
    public var statusCode: Int!
    public var allHeaders: [AnyHashable : Any]!
    public var httpResponse: HTTPURLResponse? = nil
    public var isSuccess: Bool = false
    public var timeline: RMHttpTime = RMHttpTime()
    
    public var currentType: RMHttpType!
   
    public init() { }
    
    // Serialize JSON response
    public func JSONResponse<T>(type:RMHttpType, value: T) -> RMHttpObject<T> {
        currentType = type // reference the type
        
        guard self.data != nil else { return .error(RMHttpError())}
        
        switch type {
        case .object:
            let data =  httpJSONResponseObject(expected: Dictionary<String, Any>())
            if data.isSuccess {
                return data as! RMHttpObject<T>
            }
            return RMHttpObject.error(RMHttpError())
        case .array:
            let data =  httpJSONResponseArray(expected: [Dictionary<String, Any>()])
            if data.isSuccess {
                return data as! RMHttpObject<T>
            }
            return RMHttpObject.error(RMHttpError())
        default:
            return RMHttpObject.error(RMHttpError())
        }
    }
    
    // Serialize String response
    public func StringResponse(encoding: String.Encoding?) -> RMHttpObject<String> {
        return httpResponseString(encoding: encoding)
    }
}

// Private Operations
extension RMHttpResponse {
    
    // JSON Object
    private func httpJSONResponseObject<T>(expected: T) -> RMHttpObject<T> {
        let succesDictionary = ["success" : true] as! T
        if let response = httpResponse, successStatusCodes.contains(response.statusCode) { return .success(succesDictionary)}
        do {
            if let object = try JSONSerialization.jsonObject(with: self.data! as Data, options: .allowFragments) as? T {
                return .success(object)
            } else {
                return .error(RMHttpError())
            }
        } catch let error {
            return .error(RMHttpError(error: error))
        }
    }
    
    // JSON Array
    private func httpJSONResponseArray<T>(expected: T) -> RMHttpObject<T> {
        let succesDictionary = [["success" : true]] as! T
        if let response = httpResponse, successStatusCodes.contains(response.statusCode) { return .success(succesDictionary)}
        do {
            if let object = try JSONSerialization.jsonObject(with: self.data! as Data, options: .allowFragments) as? T {
                return .success(object)
            } else {
                return .error(RMHttpError())
            }
        } catch let error {
            return RMHttpObject.error(RMHttpError(error: error))
        }
    }
    
    // String Response
    private func httpResponseString(encoding: String.Encoding?) -> RMHttpObject<String> {
        if let response = httpResponse, successStatusCodes.contains(response.statusCode) { return .success("success") }
        if let string:String = String(data:self.data! as Data, encoding: encoding!) {
            return .success(string)
        }
        return .error(RMHttpError())
    }
}

extension RMHttpResponse: RMHttpObjectAcceptable {
    public func set(object: String?) {
        
    }
    
    public func getValue() -> String? {
        return nil
    }
    
    public func getError() -> RMHttpError? {
        return nil
    }
    
    public typealias SerializedObject = String
    
}

extension RMHttpResponse: CustomStringConvertible {
    public var description: String {
        return """
        Headers: \(allHeaders!),
        Status: \(statusCode!)
        """
    }
}
