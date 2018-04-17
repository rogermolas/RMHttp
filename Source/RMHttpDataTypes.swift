//
//  RMHttpDataTypes.swift
//  RMHttp
//
//  Created by Roger Molas on 17/04/2018.
//  Copyright © 2018 Roger Molas. All rights reserved.
//

import Foundation

// RMHttp Base object protocol
public protocol RMHttpProtocol {
    associatedtype BaseObject
    
    func getType() -> BaseObject.Type?
}

// Response object protocol
public protocol RMHttpObjectAcceptable {
    associatedtype SerializedObject
    
    mutating func set(object: SerializedObject?)
    
    func getValue() -> SerializedObject?
    
    func getError() -> RMHttpError?
}

// Response object type
public enum RMHttpObject<Value:RMHttpProtocol> : RMHttpObjectAcceptable {
    public typealias SerializedObject = Value
    
    case success(Value)
    case error(RMHttpError)
    
    public func getValue() -> Value? {
        switch self {
        case .success(let value): return value
        case .error: return nil
        }
    }
    
    public func getError() -> RMHttpError? {
        switch self {
        case .success:
            return nil
        case .error(let error):
            return error
        }
    }
    
    public var isSuccess: Bool {
        switch self {
        case .success:
            return true
        case .error:
            return false
        }
    }
    
    // Additional setter if custom object added
    public func set(object: SerializedObject?) { }
}

// Comply to RMHttp base object Protocol


extension RMHttpObject : RMHttpProtocol {
    
    public typealias BaseObject = Value
    
    public func getType() -> BaseObject.Type? {
        switch self {
        case .success: return Value.self
        case .error: return nil //RMHttpError.self
        }
    }
    
    public var type: BaseObject.Type? {
        return getType() // Dynamic Object type
    }
}

extension RMHttpObject {
    
    public var value: Value? { return getValue() }
    
    public var error: RMHttpError? { return getError() }
}
