/*
MIT License

RMError.swift
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
	RMError is error object return in all HTTP error response
	
	See `ErrorType`
*/

open class RMError {
	/// Request local error type
	public var type: ErrorType = .none
	
	/// Request status code
	public var statusCode: Int = 0
	
	/// Request localizedDescription, set from`RMParser`
	public var localizedDescription: String = ""
	
	/// Error reason based on `ErrorType`
	public var reason: String? = nil
	
	/// Error return from `RMParser`
	public var error: Error? = nil
	
	/// Current request that assigned from`RMParser` if error was encountered
	public var request: RMRequest? = nil
	
	/// Current response that assigned from`RMParser` if error was encountered
	public var response: RMResponse? = nil
	
	private let domain =  "com.RMError.response"
	
	/// Initialize with `ErrorType`
	public init(errorType: ErrorType) {
		self.type = errorType
	}
	
	/// Initialize with Error, assign by `RMParser` if datatask returned an error, (e.g Network Timeout)
	public init(error: Error) {
		self.error = error
		self.reason = error.localizedDescription
		self.localizedDescription = error.localizedDescription
	}
		
	/// Initialize with reason, local error (e.g serialization of data was failed)
	public init(reason:String?) {
		self.reason = reason
	}
	
	/**
		Set local parsing error, this errors occurs during parsing of JSON data
			- T : generic type should `RMHttpProtocol` compliant
			- A type mismatch JSONObject or Array
	
		- Parameters:
			- error : Generic ` RMHttpParsingError`
	
	*/
	public func setHttpResponse<T>(error: RMHttpParsingError<T>) {
		var reason = ""
		let type:String? = String(describing: T.getType())
		let url = response?.url?.absoluteString  ?? ""
		let statusCode = response?.statusCode ?? -1
		switch error {
			case .invalidData:
				reason = "No data found, URL: \(url), Status Code: \(statusCode)"
				break
			case .invalidType:
				reason = "\(type!) : Response type mismatch, URL: \(url), Status Code: \(statusCode)"
				break
			case .noData:
				reason = "Failed \(type!), URL: \(url), Status Code: \(statusCode)"
				break
			case .unknown:
				reason = "Unknown Error <\(type!)>, URL: \(url), Status Code: \(statusCode)"
				break
		}
		self.reason = reason
	}
}

/// A textual representation of this instance, suitable for debugging.
///     let request = RMError(...)
///     let s = String(describing: request)
///     print(s)
///
///   	print:
///			domain : com.RMError.response
///			reason: Failed : URL : https://httpbin.org/get , Status Code: 404
///			request :
///
///			["headers": {
/// 			Accept = "*/*";
///				"Accept-Encoding" = "gzip, deflate, br";
///				"Accept-Language" = "en-us";
///				Host = "httpbin.org";
///				"User-Agent" = "Demo/1 CFNetwork/1121.2.1 Darwin/19.4.0";
///				"X-Amzn-Trace-Id" = "Root=1-5ec7b86b-98c5600039a93890a569a340";
///				}, "origin": xxx.xxx.xxx.xx, "url": https://httpbin.org/get, "args": {
///			}]
///

extension RMError: CustomStringConvertible {
	public var description: String {
		var desc: [String] = []
		desc.append("\n\(domain)")
		
		if let mReason = reason {
			desc.append(mReason)
		}
		if let mError = error {
			desc.append(mError.localizedDescription)
		}
		if let mRequest = request {
			desc.append(mRequest.description)
		}
		return desc.joined(separator: " : ")
	}
}

