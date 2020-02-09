/*
 MIT License
 
 RMRequest.swift
 Copyright (c) 2018 Roger Molas
 
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
    public var urlRequest:URLRequest!
    public var url:URL!
    public var parameters:[String : Any]? = nil
	public var requestEncoding: String = ""
    public var allHeaders:[String : String]? = nil
    public var sessionConfig:URLSessionConfiguration!
    public var restrictStatusCodes:Set<Int> = []  // e.g 404, 500, return Error
    
    public var timeoutIntervalForRequest: TimeInterval = 30
    public var timeoutIntervalForResource: TimeInterval = 30
    public var httpMaximumConnectionsPerHost: Int = 1
    
	private func defaulSessionConfig() {
        sessionConfig = URLSessionConfiguration.default
        sessionConfig.allowsCellularAccess = true // use cellular data
        sessionConfig.timeoutIntervalForRequest = timeoutIntervalForRequest // timeout per request
        sessionConfig.timeoutIntervalForResource = timeoutIntervalForResource // timeout per resource access
        sessionConfig.httpMaximumConnectionsPerHost = httpMaximumConnectionsPerHost // connection per host
    }
	
	//MARK: - Building default request configurations
    public init(_ urlString: String,
                method: RMHttpMethod<Encoding>,
                parameters: [String : Any]!,
                hearders: [String : String]!) {
        
        self.url = URL(string: urlString)
        self.urlRequest = URLRequest(url: url!)
		self.requestEncoding = method.encoder.encoding
        self.setHttp(method: method)
        self.setHttp(hearders: hearders)
        self.set(parameters: parameters, method: method)
        defaulSessionConfig()
    }
	
	public init(url: URL) {
		self.url = url
		self.urlRequest = URLRequest(url: url)
		defaulSessionConfig()
	}
	
	// Url cachePolicy
	public init(url: URL, cachePolicy: URLRequest.CachePolicy, timeoutInterval: TimeInterval) {
		self.url = url
		self.urlRequest = URLRequest(url: url, cachePolicy: cachePolicy, timeoutInterval: timeoutInterval)
		defaulSessionConfig()
	}
	
	// Set and append parameters to base URL
	public func set(parameters: [String : Any]!, method: RMHttpMethod<Encoding>) {
		self.parameters = (parameters != nil) ? parameters : [String:Any]()
		let request = RMBuilder().build(request: urlRequest, parameter: parameters, method: method)
		self.urlRequest = request
	}
	
	// Set and append parameters to base URL
	public func set(parameters: [RMParams], method: RMHttpMethod<Encoding>) {
		self.parameters = [String:Any]()
		self.requestEncoding = method.encoder.encoding
		self.setHttp(method: method)
		let request = RMBuilder().build(request: urlRequest, parameter: parameters, method: method)
		self.urlRequest = request
	}
}

//MARK: - Building a custom request
extension RMRequest {
	// Assign http Method
	public func setHttp(method: RMHttpMethod<Encoding>) {
		self.urlRequest.httpMethod = method.httpMethod
	}
	
	// Assign all headers
	public func setHttp(hearders: [String : String]!){
		self.allHeaders = hearders
		if let mHeaders = hearders {
			for (field, value) in mHeaders {
				self.setValue(value: value, headerField: field)
			}
		}
	}
	
	// Manual assign value to header
	public func setValue(value: String, headerField: String) {
		self.urlRequest.setValue(value, forHTTPHeaderField: headerField)
	}
	
	// Custom Http body
	public func setHttpBody(data: Data) {
		self.urlRequest.httpBody = data
	}
	
	// Custom Session config
	public func setSession(config: URLSessionConfiguration) {
		sessionConfig = config
	}
	
	// Form-Data from params
	public func setFormData(fields: [String : Any]) {
		let boundary = UUID().uuidString
		if urlRequest.value(forHTTPHeaderField: HeaderField.contentType.rawValue) == nil {
			urlRequest.setValue("\(HeaderValue.FormData.rawValue)\(boundary)",
				forHTTPHeaderField: HeaderField.contentType.rawValue)
		}
		var data = Data()
		for (key, value) in fields {
			data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
			data.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
			data.append("\(value)".data(using: .utf8)!)
		}
		self.urlRequest.httpBody = data
	}
	
	// Form-Data adding single field
	public func addForm(fieldName:String, value: Any) {
		let boundary = UUID().uuidString
		if urlRequest.value(forHTTPHeaderField: HeaderField.contentType.rawValue) == nil {
			urlRequest.setValue("\(HeaderValue.FormData.rawValue)\(boundary)",
				forHTTPHeaderField: HeaderField.contentType.rawValue)
		}
		var data = Data()
		data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
		data.append("Content-Disposition: form-data; name=\"\(fieldName)\"\r\n\r\n".data(using: .utf8)!)
		data.append("\(value)".data(using: .utf8)!)
		self.urlRequest.httpBody = data
	}
	
	// Form-Data adding file to request
	public func addForm(field: String, file: Data, fileName: String, mimeType:String) {
		let boundary = UUID().uuidString
		if urlRequest.value(forHTTPHeaderField: HeaderField.contentType.rawValue) == nil {
			urlRequest.setValue("\(HeaderValue.FormData.rawValue)\(boundary)",
				forHTTPHeaderField: HeaderField.contentType.rawValue)
		}
		var data = Data()
		data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
		data.append("Content-Disposition: form-data; name=\"\(field)\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
		data.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
		data.append(file)
		data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
		self.urlRequest.httpBody = data
	}
}

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
