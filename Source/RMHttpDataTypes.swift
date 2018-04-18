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
    
    static func getType() -> BaseObject.Type
    
    static func internalError() -> RMHttpError?
}

// Response object protocol
public protocol RMHttpObjectAcceptable {
    associatedtype SerializedObject
    
    mutating func set(object: SerializedObject?)
    
    func getValue() -> SerializedObject?
    
    func getError() -> RMHttpError? // Http Error value)
}

// Data Parsing Problems
public enum RMHttpParsingError<TYPE:RMHttpProtocol> {
    case invalidType(TYPE)
    case noData(TYPE)
    case invalidData(TYPE)
    case unknown(TYPE)
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
            case .success: return nil
            case .error (let error): return error
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

extension RMHttpObject {
    public var value: Value? { return getValue() }
    
    public var error: RMHttpError? { return getError() }
}

// Comply to RMHttp base object Protocol
extension RMHttpObject : RMHttpProtocol {
    public typealias BaseObject = Value
    
    public static func internalError() -> RMHttpError? {
        return nil
    }
    
    public static func getType() -> BaseObject.Type { return Value.self }
    
    public var type: BaseObject.Type {
        return RMHttpObject.getType() // Dynamic Object type
    }
}

// Dictionary Response (JSON object)
extension Dictionary:RMHttpProtocol {
    public typealias BaseObject = Dictionary<String, Any>
    
    public static func internalError() -> RMHttpError? {
        return nil
    }

    public static func getType() -> Dictionary<String, Any>.Type {
        return Dictionary<String, Any>.self
    }
}

// Array Response (JSON Array)
extension Array:RMHttpProtocol {
    public typealias BaseObject = [Dictionary<String, Any>]
    
    public static func internalError() -> RMHttpError? {
        return nil
    }
    
    public static func getType() -> [Dictionary<String, Any>].Type {
        return [Dictionary<String, Any>].self
    }
}

// String Response (all Strings, e.g HTM string)
extension String: RMHttpProtocol {
    public typealias BaseObject = String
    
    public static func internalError() -> RMHttpError? {
        return nil
    }
    
    public static func getType() -> String.Type {
        return String.self
    }
}

// Error Response (All error)
extension RMHttpError: RMHttpProtocol {
    public typealias BaseObject = RMHttpError
    
    public static func internalError() -> RMHttpError? {
        return nil
    }
    
    public static func getType() -> RMHttpError.Type {
        return RMHttpError.self
    }
}

extension NSNull: RMHttpProtocol {
    public typealias BaseObject = NSNull
    
    public static func internalError() -> RMHttpError? {
        return nil
    }
    
    public static func getType() -> NSNull.Type {
        return NSNull.self
    }
}

func associatedObject<ValueType: AnyObject>( base: AnyObject, key: UnsafePointer<UInt8>, initialiser: () -> ValueType) -> ValueType {
    if let associated = objc_getAssociatedObject(base, key) as? ValueType { return associated }
    let associated = initialiser()
    objc_setAssociatedObject(base, key, associated, .OBJC_ASSOCIATION_RETAIN)
    return associated
}

func associateObject<ValueType: AnyObject>(base: AnyObject, key: UnsafePointer<UInt8>, value: ValueType) {
    objc_setAssociatedObject(base, key, value,.OBJC_ASSOCIATION_RETAIN)
}
