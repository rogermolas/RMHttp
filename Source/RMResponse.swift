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
    case error(RMError)
    
    public var value: Value? {
        switch self {
        case .success(let value):
            return value
        case .error:
            return nil
        }
    }
}

public enum RMHttpJSON<TYPE> {
    case object(TYPE)
    case array(TYPE)
}

/// Status code that do not contain response data.
private let successStatusCodes: Set<Int> = [204, 205]

open class RMResponse {
    public var data: NSMutableData? = nil
    public var statusCode: Int!
    public var allHeaders: [AnyHashable : Any]!
    public var httpResponse: HTTPURLResponse!
    public var isSuccess: Bool = false
    public var timeline: RMTime = RMTime()
    
    init() { }
    
    func JSONResponse<T>(type: RMHttpJSON<T>) -> RMHttpObject<T>{
        switch type {
        case .object( _):
            return httpResponseObject(data: self.data! as Data, result: type)
        case .array( _):
            return httpResponseArray(data: self.data! as Data, result: type)
        }
    }
    
    func StringResponse(encoding: String.Encoding?) -> RMHttpObject<String> {
        return httpResponseString(data: self.data! as Data, encoding: encoding)
    }
}

// Private Operations
extension RMResponse {
    private func httpResponseObject<T>(data: Data, result:RMHttpJSON<T>) -> RMHttpObject<T> {
//        let succesDictionary = [{"success" : true}] as! T
//        if let response = httpResponse, successStatusCodes.contains(response.statusCode) { return .success(succesDictionary)}

        do {
            let object = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! T
            return .success(object)
        } catch {
            return .error(RMError())
        }
    }
    
    private func httpResponseArray<T>(data: Data, result:RMHttpJSON<T>) -> RMHttpObject<T> {
//        let succesDictionary = ["success" : true] as! T
//        if let response = httpResponse, successStatusCodes.contains(response.statusCode) { return .success(succesDictionary)}
        do {
            let object = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! T
            return .success(object)
        } catch {
            return .error(RMError())
        }
    }
    
    private func httpResponseString(data: Data, encoding: String.Encoding?) -> RMHttpObject<String> {
        if let response = httpResponse, successStatusCodes.contains(response.statusCode) { return .success("success") }
        if let string:String = String(data: data, encoding: encoding!) {
            return .success(string)
        }
        return .error(RMError())
    }
}

extension RMResponse: CustomStringConvertible {
    public var description: String {
        return """
        Headers: \(allHeaders!),
        Status: \(statusCode!)
        """
    }
}
