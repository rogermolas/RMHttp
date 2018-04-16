//
//  RMResponse.swift
//  RMHttp
//
//  Created by Roger Molas on 12/04/2018.
//  Copyright © 2018 Roger Molas. All rights reserved.
//

import Foundation

public enum RMHttpObject<Value> {
    case success(Value)
    case error(RMHttpError)
    
    public var value: Value? {
        switch self {
            case .success(let value): return value
            case .error: return nil
        }
    }
}

protocol RMHttpObjectAcceptable {
    associatedtype SerializedObject
    
    mutating func set(object: RMHttpObject<SerializedObject>)
    
    func getValue() -> RMHttpObject<SerializedObject>
}

//// JSON Type (Object or Array)
//public enum RMHttpJSON<TYPE> {
//    case object(TYPE)
//    case array(TYPE)
//
//    public var type: TYPE? {
//        switch self {
//            case .object(let type):  return type
//            case .array(let type):  return type
//        }
//    }
//}

// JSON Type (Object or Array)


typealias JSONObject = Dictionary<String, Any>
typealias JSONArray = [Dictionary<String, Any>]

public enum RMHttpJSON: String {
    case object = "JSONObject"
    case array = "JSONArray"
}

public struct Value<T>:RMHttpObjectAcceptable {
    
    typealias SerializedObject = T
    
    var httpObject: RMHttpObject<T>
    
    mutating func set(object: RMHttpObject<T>) {
        httpObject = object
    }
    
    func getValue() -> RMHttpObject<T> {
        return httpObject
    }
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
    
    public init() { }
    
    // Serialize JSON response
    public func JSONResponse<T>(type:RMHttpJSON, value: T) -> Value<T> {
        switch type {
        case .object:
            let data =  httpJSONResponseObject(data: self.data! as Data, type: Dictionary<String, Any>())
            let value = Value(httpObject: data)
            return value as! Value<T>
        case .array:
            let data =  httpJSONResponseArray(data: self.data! as Data, type: [Dictionary<String, Any>()])
            let value = Value(httpObject: data)
            return value as! Value<T>
        }
    }
    
    // Serialize String response
    public func StringResponse(encoding: String.Encoding?) -> RMHttpObject<String> {
        return httpResponseString(data: self.data! as Data, encoding: encoding)
    }
}

// Private Operations
extension RMHttpResponse {
    
    // JSON Object
    private func httpJSONResponseObject<T>(data: Data, type: T) -> RMHttpObject<T> {
        let succesDictionary = ["success" : true] as! T
        if let response = httpResponse, successStatusCodes.contains(response.statusCode) { return .success(succesDictionary)}
        do {
            let object = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! T
            return .success(object)
        } catch {
            return .error(RMHttpError())
        }
    }
    
    // JSON Array
    private func httpJSONResponseArray<T>(data: Data, type: T) -> RMHttpObject<T> {
        let succesDictionary = [["success" : true]] as! T
        if let response = httpResponse, successStatusCodes.contains(response.statusCode) { return .success(succesDictionary)}
        do {
            let object = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! T
            return .success(object)
        } catch {
            return RMHttpObject.error(RMHttpError())
        }
    }
    
    // String Response
    private func httpResponseString(data: Data, encoding: String.Encoding?) -> RMHttpObject<String> {
        if let response = httpResponse, successStatusCodes.contains(response.statusCode) { return .success("success") }
        if let string:String = String(data: data, encoding: encoding!) {
            return .success(string)
        }
        return .error(RMHttpError())
    }
}

extension RMHttpResponse: CustomStringConvertible {
    public var description: String {
        return """
        Headers: \(allHeaders!),
        Status: \(statusCode!)
        """
    }
}
