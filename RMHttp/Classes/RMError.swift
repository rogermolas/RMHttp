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

open class RMError {
	/// Request local error type
	public var type: ErrorType = .none
	
	/// Request status code
	public var statusCode: Int = 0
	
	/// Request localizedDescription, set from`RMParser`
	public var localizedDescription: String = ""
	
	public var reason: String? = nil
	public var error: Error? = nil
	public var request: RMRequest? = nil
	public var response: RMResponse? = nil
	public var info:Dictionary<String, Any> = Dictionary<String, Any>()
	
	private let domain =  "com.RMError.response"
	
	public init(error: Error) {
		self.error = error
		self.reason = error.localizedDescription
	}
	
	public init() {
		self.reason = "Unknown Type"
	}
	
	public init(reason:String?) {
		self.reason = reason
	}
	
	public func set(info:Dictionary<String, Any>) {
		self.info = info
	}
	
	public func setHttpResponse<T>(error: RMHttpParsingError<T>) {
		var reason = ""
		let type:String? = String(describing: T.getType())
		switch error {
			case .invalidData:
				reason = "No data found : \(String(describing: response?.statusCode))"
				break
			case .invalidType:
				reason = "\(type!) : Response type mismatch"
				break
			case .noData:
				reason = "Failed \(type!) : Status: \(String(describing: response?.url?.absoluteString)) : \(String(describing: response?.statusCode))"
				break
			case .unknown:
				reason = "Unknown Error <\(type!)>"
				break
		}
		self.reason = reason
	}
}

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

