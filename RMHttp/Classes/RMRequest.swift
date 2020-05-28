/*
MIT License

RMRequest.swift
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

open class RMRequest {
	/// Request URL session configuration
	public var sessionConfig:URLSessionConfiguration!
	/// Request URL
	public var url:URL!
	/// URL Request
	public var urlRequest:URLRequest!
	/// Request parameters
	public var parameters:[String : Any]? = nil
	/// Request Encoding
	public var requestEncoding: String = ""
	/// Request headers
	public var allHeaders:[String : String]? = nil
	/// User defined restricted status code  e.g 404, 500, return Error
	public var restrictStatusCodes:Set<Int> = []
	/// Request allow Cellular Data,  default to True
	public var allowsCellularAccess: Bool = true
	/// Request time out default to 60
	public var timeoutIntervalForRequest: TimeInterval = 60
	/// Request time out for resources default to 60
	public var timeoutIntervalForResource: TimeInterval = 60
	/// Maximun connection per host
	public var httpMaximumConnectionsPerHost: Int = 1
	
	// Form-Data
	private var formBody = Data()
	private let boundary = UUID().uuidString
	
	/**
		Initialization
		
		- Parameters:
			- urlString: Request url in string  of the receiver.
			- method: Request method and its encoding.
			- parameters: Request parameters in Dictionary container.
			- hearders: HTTP request headers.
	*/
	public init(_ urlString: String,
				_ method: RMHttpMethod<Encoding>,
				_ parameters: [String : Any]!,
				_ hearders: [String : String]!) {
		
		self.url = URL(string: urlString)
		self.urlRequest = URLRequest(url: url!)
		self.requestEncoding = method.encoder.encoding
		self.setHttp(method: method)
		self.setHttp(hearders: hearders)
		self.set(parameters: parameters, method: method)
		defaulSessionConfig()
	}
	
	/**
		Initialization
	
		- Parameters:
			- urlString: Request url in string  of the receiver.
			- method: Request method and its encoding.
			- rm_params: Request parameters in `RMParams` container.
			- hearders: HTTP request headers.
	*/
	public init(_ urlString: String,
				_ method: RMHttpMethod<Encoding>,
				_ rm_params:[RMParams],
				_ hearders: [String : String]!) {
		
		self.url = URL(string: urlString)
		self.urlRequest = URLRequest(url: url!)
		self.requestEncoding = method.encoder.encoding
		self.setHttp(method: method)
		self.setHttp(hearders: hearders)
		self.set(parameters: rm_params, method: method)
		defaulSessionConfig()
	}
	
	/**
		Initialization
	
		- Parameters:
			- url: The URL of the receiver.
	*/
	public init(url: URL) {
		self.url = url
		self.urlRequest = URLRequest(url: url)
		defaulSessionConfig()
	}
	
	/**
		Initialization
	
		- Parameters:
			- url: The URL of the receiver.
			- cachePolicy: The cache policy of the receiver.
			- timeoutInterval: The timeout interval for the request. Defaults to 60.0
	*/
	public init(url: URL, cachePolicy: URLRequest.CachePolicy, timeoutInterval: TimeInterval) {
		self.url = url
		self.urlRequest = URLRequest(url: url, cachePolicy: cachePolicy, timeoutInterval: timeoutInterval)
		defaulSessionConfig()
	}
	
	private func defaulSessionConfig() {
		sessionConfig = URLSessionConfiguration.default
		sessionConfig.allowsCellularAccess = allowsCellularAccess // allow access to cellular data
		sessionConfig.timeoutIntervalForRequest = timeoutIntervalForRequest // timeout per request
		sessionConfig.timeoutIntervalForResource = timeoutIntervalForResource // timeout per resource access
		sessionConfig.httpMaximumConnectionsPerHost = httpMaximumConnectionsPerHost // connection per host
	}
	
	// Set and append parameters from Dictionary to base URL
	private func set(parameters: [String : Any]!, method: RMHttpMethod<Encoding>) {
		self.parameters = (parameters != nil) ? parameters : [String:Any]()
		let request = RMBuilder().build(parameters, urlRequest, method)
		self.urlRequest = request
	}
	
	// Set and append parameters from RMParams wraper to base URL
	private func set(parameters: [RMParams], method: RMHttpMethod<Encoding>) {
		var dictionaryArray = [Dictionary<String, Any>]()
		for param in parameters {
			dictionaryArray.append(param.dictionary)
		}
		self.parameters = ["parameters" : dictionaryArray] // Log params from container
		let request = RMBuilder().buildCustom(parameters, urlRequest, method)
		self.urlRequest = request
	}
	
	/**
		Set Request method. see `RMHttpMethod` for supported methods
	
		- Parameters:
			- method: Request method with generic type `Encoding`
	*/
	public func setHttp(method: RMHttpMethod<Encoding>) {
		self.urlRequest.httpMethod = method.httpMethod
	}
	
	/**
		Set Request headers.
	
		- Parameters:
			- hearders: Request headers
	*/
	public func setHttp(hearders: [String : String]!){
		self.allHeaders = hearders
		if let mHeaders = hearders {
			for (field, value) in mHeaders {
				self.setValue(value: value, headerField: field)
			}
		}
	}
	
	/**
		Set Request header value.
	
		- Parameters:
			- value: Header value
			- headerField: Header field
	*/
	public func setValue(value: String, headerField: String) {
		self.urlRequest.setValue(value, forHTTPHeaderField: headerField)
	}
	
	/**
		Set Request http body.
	
		- Parameters:
			- data: Data body
	*/
	public func setHttpBody(data: Data) {
		self.urlRequest.httpBody = data
	}
	
	/**
		Set Custom Session config
	
		- Parameters:
			- config: URLSessionConfiguration
	*/
	public func setSession(config: URLSessionConfiguration) {
		sessionConfig = config
	}
	
	/**
		Form data request, adding field and files in form request
	
		- Parameters:
			- fields: Request field and its value in Dictionary type
			- files: Files to be send in request, Array of `RMFormDataFile`
	*/
	public func setFormData(fields: [String : Any]?, _ files: [RMFormDataFile]? = nil) {
		let boundary = UUID().uuidString
		if urlRequest.value(forHTTPHeaderField: HeaderField.contentType.rawValue) == nil {
			urlRequest.setValue("\(HeaderValue.FormData.rawValue)\(boundary)", forHTTPHeaderField: HeaderField.contentType.rawValue)
		}
		
		var data = Data()
		// Add Text fields (optional)
		if fields != nil {
			for (key, value) in fields! {
				data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
				data.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
				data.append("\(value)".data(using: .utf8)!)
			}
		}
		
		// Add File fields (optional)
		if files != nil {
			for file in files! {
				data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
				data.append("Content-Disposition: form-data; name=\"\(file.fieldName)\"; filename=\"\(file.fileName)\"\r\n".data(using: .utf8)!)
				data.append("Content-Type: \(file.mimeType)\r\n\r\n".data(using: .utf8)!)
				data.append(file.file) // In data representation
				data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
			}
		}
		self.urlRequest.httpBody = data // One time set data body
	}
	
	// Form-Data adding single field
	public func addForm(fieldName:String, value: Any) {
		if urlRequest.value(forHTTPHeaderField: HeaderField.contentType.rawValue) == nil {
			urlRequest.setValue("\(HeaderValue.FormData.rawValue)\(boundary)",
				forHTTPHeaderField: HeaderField.contentType.rawValue)
		}
		formBody.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
		formBody.append("Content-Disposition: form-data; name=\"\(fieldName)\"\r\n\r\n".data(using: .utf8)!)
		formBody.append("\(value)".data(using: .utf8)!)
		self.urlRequest.httpBody = formBody
	}
	
	// Form-Data adding file to request
	public func addFile(field: String, file: Data, fileName: String, mimeType: String) {
		if urlRequest.value(forHTTPHeaderField: HeaderField.contentType.rawValue) == nil {
			urlRequest.setValue("\(HeaderValue.FormData.rawValue)\(boundary)",
				forHTTPHeaderField: HeaderField.contentType.rawValue)
		}
		formBody.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
		formBody.append("Content-Disposition: form-data; name=\"\(field)\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
		formBody.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
		formBody.append(file) // In data representation
		formBody.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
		self.urlRequest.httpBody = formBody
	}
}

/// A textual representation of this instance, suitable for debugging.
///     let request = RMRequest(...)
///     let s = String(describing: request)
///     print(s)
///
///     // Prints "
///			https://httpbin.org/get :
///			[params1: value1, params2: value2 ] :
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

extension RMRequest: CustomStringConvertible {
	public var description: String {
		var desc: [String] = []
		if let request = urlRequest {
			desc.append("\(String(describing: request.url?.absoluteString))")
		}
		if let mParameters = parameters {
			desc.append("\(mParameters)")
		}
		if let mAllHeaders = allHeaders {
			desc.append("\(mAllHeaders)")
		}
		return desc.joined(separator: " : ")
	}
}
