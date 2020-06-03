/*
MIT License

RMCommons.swift
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

/**
	RMCommons - Contains defined types such as Methods, Encoding, Protocols and Headers
*/

public enum HeaderField: String {
	case contentType = "Content-Type"
}

/// HTTP Header types
public enum HeaderValue: String {
	case JSON = "application/json"
	case URLEncoded = "application/x-www-form-urlencoded; charset=utf-8"
	case FormData = "multipart/form-data; boundary="
}

/// RMHttp base object response protocol
public protocol RMHttpProtocol {
	associatedtype BaseObject
	
	/// Current object type NSNull, Dictionary or Array
	static func getType() -> BaseObject.Type
	
	/// Current object reponse error. see `RMError`
	static func internalError() -> RMError?
}

/// HTTP request parameters encoding
public enum Encoding {
	/// URL in application/x-www-form-urlencoded;
	case URLEncoding
	
	/// JSON request body
	case JSONEncoding
	
	/// Form data encoding
	case FomDataEncoding
	
	/// Parameters encoding in string representation
	public var encoding: String {
		switch self {
			case .URLEncoding: return "URL Default/Query Encoding"
			case .JSONEncoding: return "JSON Body Encoding"
			case .FomDataEncoding: return "Fom-data Encoding"
		}
	}
}

/// HTTP request methods
public enum RMHttpMethod<Encoder> {
	/// GET request
	case GET(Encoder)
	/// POST request
	case POST(Encoder)
	/// DELETE request
	case DELETE(Encoder)
	/// PUT request
	case PUT(Encoder)
	/// PATCH request
	case PATCH(Encoder)
	
	/**
	Current request parameters encoding
		- Returns: Encoder type of current request
	*/
	public var encoder: Encoder {
		switch self {
			case .GET (let encoder): return encoder
			case .POST(let encoder): return encoder
			case .DELETE(let encoder): return encoder
			case .PATCH(let encoder): return encoder
			case .PUT(let encoder): return encoder
		}
	}
	/**
	HTTP methods in string representations
		- Returns: Request method used in string representation
	*/
	public var httpMethod: String {
		switch self {
			case .GET: return "GET"
			case .POST: return "POST"
			case .DELETE: return "DELETE"
			case .PATCH: return "PATCH"
			case .PUT: return "PUT"
		}
	}
}

/**
	Defined data parsing errors
	 - invalidType - when codable models is not equal to reponse model
	 - noData - no data reponse
	 - invalidData - not a valid JSON reponse
	 - unknown - other errors return by JSonSerialization
*/
public enum RMHttpParsingError<TYPE:RMHttpProtocol> {
	case invalidType(TYPE)
	case noData(TYPE)
	case invalidData(TYPE)
	case unknown(TYPE)
}

/**
	Defined error types for `RMError`
	- parsing - when data parsing is not successfull
	- sessionTask - when url request fail (e.g Network Timeout)
	- server - server reponse error ( status codes 4.x.x, 5.x.x)
	- none - no error encounter, default status code 0, use for custom error response
*/
public enum ErrorType {
	case parsing
	case sessionTask
	case server
	case none
}

/// Response object types
public enum RMHttpObject<Value> {
	public typealias SerializedObject = Value
	
	/// Request finished and parsing of data was successful (e.g status code: 200)
	case success(Value)
	
	/// Request finished but has error an error encounter (e.g failed to serialize or server response error)
	case error(RMError)
	
	/// Return True if response parsing or casting was successful otherwise False
	public var isSuccess: Bool {
		switch self {
			case .success: return true
			case .error: return false
		}
	}
	
	/// Return value assigned as expected response like Dictionary, Array or Codable types
	public var value: Value? {
		switch self {
			case .success(let value): return value
			case .error: return nil
		}
	}
	
	/// Return error during response parsing see also `RMHttpParsingError` and `RMError`
	public var error: RMError? {
		switch self {
			case .success: return nil
			case .error (let error): return error
		}
	}
}

/// RMHttpObject comply to `RMHttpProtocol` as base of for RMHttp response Dictionary, Array or String
extension RMHttpObject : RMHttpProtocol {
	/// Base object value
	public typealias BaseObject = Value
	
	/// Object error see `RMError` default to nil
	public static func internalError() -> RMError? {
		return nil
	}
	
	/// Object value type
	public static func getType() -> BaseObject.Type {
		return Value.self
	}
	
	/// Return object type (e.g Dictionary, Array, String)
	public var type: BaseObject.Type {
		return RMHttpObject.getType()
	}
}

/// Dictionary Response (JSON object)
extension Dictionary:RMHttpProtocol {
	/// Define the based type as  `Dictionary<String, Any>`
	public typealias BaseObject = Dictionary<String, Any>
	
	/// Return the type mismatch error
	public static func internalError() -> RMError? {
		return RMError(reason: "Invalid response type, expecting Dictionary type")
	}
	
	/// Return Dictionary type
	public static func getType() -> Dictionary<String, Any>.Type {
		return Dictionary<String, Any>.self
	}
}

/// Array Response (Array object)
extension Array:RMHttpProtocol {
	/// Define the based type as  `Array<Any>`
	public typealias BaseObject = [Dictionary<String, Any>]
	
	/// Return the type mismatch error
	public static func internalError() -> RMError? {
		return RMError(reason: "Invalid response type, expecting Array type")
	}
	
	/// Return  Array of Dictionary type
	public static func getType() -> [Dictionary<String, Any>].Type {
		return [Dictionary<String, Any>].self
	}
}

//MARK: - String Response (all Strings, e.g HTML String)
extension String: RMHttpProtocol {
	
	public typealias BaseObject = String
	
	public static func internalError() -> RMError? {
		return RMError(reason: "Invalid response type, expecting String")
	}
	
	/// Return  raw String type (e.g String like HTML strings)
	public static func getType() -> String.Type {
		return String.self
	}
}

extension NSNull: RMHttpProtocol {
	
	public typealias BaseObject = NSNull
	
	public static func internalError() -> RMError? {
		return RMError(reason: "Invalid Response Type")
	}
	
	public static func getType() -> NSNull.Type {
		return NSNull.self
	}
}

