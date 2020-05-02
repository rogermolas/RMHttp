/*
MIT License

RMBuilder.swift
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

public enum HeaderField: String {
	case contentType = "Content-Type"
}

public enum HeaderValue: String {
	case JSON = "application/json"
	case URLEncoded = "application/x-www-form-urlencoded; charset=utf-8"
	case FormData = "multipart/form-data; boundary="
}

/**
RMBuilder - Handle URL parameters and methods constructions
- Note
	- for supported methods - See `RMHttpMethod`
	- for supported encoding - See `Encoding`
*/
open class RMBuilder {
	/**
	Build request from Dictionary type parameters
	
	- Parameters
		`request`: URLRequest object
		`parameter`: Dictionary object that contains request parameters
		`method`:  `RMHttpMethod<Encoding>`.  see `RMHttpMethod` and `Encoding`
	
	- Returns: The constructed URLRequest object.
	
	- Important:
		* Encoding of Files such as `Images`, `Videos` or etc. is not supported when using `FomDataEncoding` as method encoding.
		* For adding file in request  use `addFile(field:file:fileName:mimeType)` from `RMRequest`
	
	*/
	public func build(request: URLRequest?, parameter: [String: Any]?, method: RMHttpMethod<Encoding>) -> URLRequest {
		
		var mUrlRequest = request
		guard parameter != nil else { return mUrlRequest! }
		
		if method.encoder == .URLEncoding { // URL Default
			// Default Encoding
			if encodeParametersInUrl(method: method) {
				mUrlRequest = buildQuery(request!, parameters: parameter!)
			} else {
				mUrlRequest = buildHttpBodyQuery(request!, parameters: parameter!)
			}
		
		} else if method.encoder == .FomDataEncoding { // Form data Body
			mUrlRequest = addForm(request: request, parameters: parameter!)
		
		} else { // JSON Body
			mUrlRequest = buildJSONHttpBody(request!, parameters: parameter!)
			if mUrlRequest?.httpBody == nil {
				let data = try! JSONSerialization.data(withJSONObject: parameter ?? "", options: [])
				if mUrlRequest?.value(forHTTPHeaderField: HeaderField.contentType.rawValue) == nil {
					mUrlRequest?.setValue(HeaderValue.JSON.rawValue, forHTTPHeaderField: HeaderField.contentType.rawValue)
				}
				mUrlRequest?.httpBody = data
			}
		}
		return mUrlRequest!
	}
	
	/**
	Build request from RMParams container type
	
	e.g This is use for the same url query fields (e.g fields[]=1&fields[]=2)
	
	- Parameters
		`request`: URLRequest object
		`parameter`:  Array of `RMParams`
		`method`:  `RMHttpMethod<Encoding>`.  see `RMHttpMethod` and `Encoding`
	
	- Returns: The constructed URLRequest object.
	
	- Important:
		* Encoding of Files such as `Images`, `Videos` or etc. is not supported when using `FomDataEncoding` as method encoding.
		* For adding file in request  use `addFile(field:file:fileName:mimeType)` from `RMRequest`
	*/
	public func build(request: URLRequest?, parameter: [RMParams]?, method: RMHttpMethod<Encoding>) -> URLRequest {
		
		var mUrlRequest = request
		guard parameter != nil else { return mUrlRequest! }
		
		if method.encoder == .URLEncoding { // URL Default
			// Default Encoding
			if encodeParametersInUrl(method: method) {
				mUrlRequest = buildQuery(request!, parameters: parameter!)
			} else {
				mUrlRequest = buildHttpBodyQuery(request!, parameters: parameter!)
			}
		
		} else if method.encoder == .FomDataEncoding { // Form data Body
			mUrlRequest = addForm(request: request, parameters: parameter!)
		
		} else { // JSON Body
			assertionFailure("JSON Body not supported! Please use - build(request:URLRequest, parameter: [String: Any]?, method: RMHttpMethod<Encoding>)")
		}
		return mUrlRequest!
	}
	
	//MARK:- Build URL parameters
	/**
	Build URL query from Dictionary type parameters
	- Parameters
	`parameters`: Dictionary object that contains request parameters
	
	- Returns: String url components.
	*/
	public func buildQuery(_ parameters: [String: Any]) -> String {
		var components: [String] = []
		for key in parameters.keys.sorted(by: <) {
			let value = parameters[key]!
			components += ["\(key)=\(encodeParameter(value: value)!)"]
		}
		return components.joined(separator: "&")
	}
	
	/**
	Build URL query from array of `RMParams` type
	- Parameters
	`parameters`: Array of `RMParams`
	
	- Returns: String url components.
	*/
	public func buildQuery(_ parameters: [RMParams]) -> String {
		var components: [String] = []
		for item in parameters {
			components += ["\(item.key)=\(encodeParameter(value: item.value)!)"]
		}
		return components.joined(separator: "&")
	}
	
	//MARK:- Encode parameter value
	/**
	Encode parameter value
	- Parameters
	`value`:   Any of types (`Bool`, `Int`, `Double`, `String`)
	
	- Note
		default character set is `.urlHostAllowed`
	*/
	public func encodeParameter(value: Any, _ characterSet: CharacterSet = .urlHostAllowed) -> String! {
		var mValue: String
		if let bool = value as? Bool  {
			mValue = bool ? "1" : "0"
		} else {
			mValue = "\(value)"
		}
		let escapedString = mValue.addingPercentEncoding(withAllowedCharacters: characterSet)
		return escapedString!
	}
	
	//MARK:- Parameters Encoding (GET, DELETE)
	private func buildQuery(_ urlRequest: URLRequest, parameters: [String: Any]) -> URLRequest? {
		var mUrlRequest = urlRequest
		let paramString = buildQuery(parameters)
		var component = URLComponents(url: mUrlRequest.url!, resolvingAgainstBaseURL: false)
		component?.percentEncodedQuery = paramString
		if mUrlRequest.value(forHTTPHeaderField: HeaderField.contentType.rawValue) == nil {
			mUrlRequest.setValue(HeaderValue.JSON.rawValue, forHTTPHeaderField: HeaderField.contentType.rawValue)
		}
		mUrlRequest.url = component?.url
		return mUrlRequest
	}
	
	private func buildQuery(_ urlRequest: URLRequest, parameters: [RMParams]) -> URLRequest? {
		var mUrlRequest = urlRequest
		let paramString = buildQuery(parameters)
		var component = URLComponents(url: mUrlRequest.url!, resolvingAgainstBaseURL: false)
		component?.percentEncodedQuery = paramString
		if mUrlRequest.value(forHTTPHeaderField: HeaderField.contentType.rawValue) == nil {
			mUrlRequest.setValue(HeaderValue.JSON.rawValue, forHTTPHeaderField: HeaderField.contentType.rawValue)
		}
		mUrlRequest.url = component?.url
		return mUrlRequest
	}
	
	//MARK:- Parameters Encoding (POST, PUT, PATCH)
	private func buildHttpBodyQuery(_ urlRequest: URLRequest, parameters: [String:Any]) -> URLRequest? {
		var mUrlRequest = urlRequest
		let paramString = buildQuery(parameters)
		if mUrlRequest.value(forHTTPHeaderField: HeaderField.contentType.rawValue) == nil {
			mUrlRequest.setValue(HeaderValue.URLEncoded.rawValue, forHTTPHeaderField: HeaderField.contentType.rawValue)
		}
		mUrlRequest.httpBody = paramString.data(using: .utf8, allowLossyConversion: false)
		return mUrlRequest
	}
	
	private func buildHttpBodyQuery(_ urlRequest: URLRequest, parameters: [RMParams]) -> URLRequest? {
		var mUrlRequest = urlRequest
		let paramString = buildQuery(parameters)
		if mUrlRequest.value(forHTTPHeaderField: HeaderField.contentType.rawValue) == nil {
			mUrlRequest.setValue(HeaderValue.URLEncoded.rawValue, forHTTPHeaderField: HeaderField.contentType.rawValue)
		}
		mUrlRequest.httpBody = paramString.data(using: .utf8, allowLossyConversion: false)
		return mUrlRequest
	}
	
	//MARK: - JSON Data Encoding
	private func buildJSONHttpBody(_ urlRequest: URLRequest, parameters: [String:Any]) -> URLRequest? {
		var mUrlRequest = urlRequest
		do {
			let data = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
			if mUrlRequest.value(forHTTPHeaderField: HeaderField.contentType.rawValue) == nil {
				mUrlRequest.setValue(HeaderValue.JSON.rawValue, forHTTPHeaderField: HeaderField.contentType.rawValue)
			}
			mUrlRequest.httpBody = data
		} catch {
			return nil
		}
		return urlRequest
	}
	
	//MARK: - Form-data Encoding
	private func addForm(request: URLRequest?, parameters: [String: Any]) -> URLRequest {
		var mUrlRequest = request
		let boundary = UUID().uuidString
		mUrlRequest?.setValue("\(HeaderValue.FormData.rawValue)\(boundary)",
			forHTTPHeaderField: HeaderField.contentType.rawValue)
		var data = Data()
		for key in parameters.keys.sorted(by: <) {
			let value = parameters[key]!
			data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
			data.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
			data.append("\(value)".data(using: .utf8)!)
		}
		mUrlRequest?.httpBody = data
		return mUrlRequest!
	}
	
	private func addForm(request: URLRequest?, parameters: [RMParams]) -> URLRequest {
		var mUrlRequest = request
		let boundary = UUID().uuidString
		mUrlRequest?.setValue("\(HeaderValue.FormData.rawValue)\(boundary)",
			forHTTPHeaderField: HeaderField.contentType.rawValue)
		var data = Data()
		
		for item in parameters {
			data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
			data.append("Content-Disposition: form-data; name=\"\(item.key)\"\r\n\r\n".data(using: .utf8)!)
			data.append("\(item.value)".data(using: .utf8)!)
		}
		mUrlRequest?.httpBody = data
		return mUrlRequest!
	}
	
	// Check if parameters encoded to HttpBody or within URL
	private func encodeParametersInUrl(method: RMHttpMethod<Encoding>) -> Bool {
		switch method.httpMethod {
			case "GET", "DELETE":
				return true
			default:
				return false
		}
	}
}

