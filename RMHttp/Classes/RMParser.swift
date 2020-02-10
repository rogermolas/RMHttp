/*
 MIT License
 
 RMParser.swift
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

public typealias RMParserCompletionHandler = (RMResponse?, RMError?) -> Void

public protocol RMHttpParserDelegate {
    func rmParserDidfinished(_ parser: RMParser)
    func rmParserDidFail(_ parser: RMParser, error: RMError?)
    func rmParserDidCancel(_ parser: RMParser)
}

open class RMParser: NSObject {
    public var delegate: RMHttpParserDelegate? = nil
    public var isCancel = false
    public var isError = false

    private var task: URLSessionDataTask? = nil
    private var receiveData: NSMutableData? = nil
    
    private var currentError: RMError? = nil
    private var currentRequest: RMRequest? = nil
    private var currentResponse: RMResponse? = nil
    
    private var completionHandler:RMParserCompletionHandler? = nil
    
    private var startTime: CFAbsoluteTime?
    private var initializeResponseTime: CFAbsoluteTime?
    private var endTime: CFAbsoluteTime?
    
    //https://en.wikipedia.org/wiki/List_of_HTTP_status_codes#4xx_Client_errors
    private var HTTPClientError:Set<Int> = [400, 401, 403, 404, 405, 408, 409]
    
    //https://en.wikipedia.org/wiki/List_of_HTTP_status_codes#5xx_Server_errors
    private var HTTPServerError:Set<Int> = [500, 501, 502, 503, 504, 505, 511]

    
    public override init() { super.init() }
    
    public func parseWith(request: RMRequest, callback: RMParserCompletionHandler?) {
        completionHandler = nil
        currentRequest = nil
        
        // Reference Callbacks and request
        completionHandler = callback
        currentRequest = request
        
        // Session configuration
        var session = URLSession.shared
        let sessionConfig = request.sessionConfig // connection per host
        session = URLSession(configuration: sessionConfig!, delegate: self, delegateQueue: OperationQueue.main)
        task = session.dataTask(with: request.urlRequest)
        self.resume()
    }
    
    // MARK: Life cycle
    deinit {
        completionHandler = nil
    }
    
    // MARK: Resume task operations
    public func resume() {
        guard let task = task else { return }
        if startTime == nil { startTime = CFAbsoluteTimeGetCurrent() }
        task.resume()
    }
    
    // MARK: Suppend task operations
    public func suspend() {
        guard let task = task else { return }
        task.suspend()
    }
    
    // MARK: Cancel task operations
    public func cancel() {
        guard let task = task else { return }
        
        task.cancel()
        receiveData = nil
        isCancel = true
        if delegate != nil {
            self.delegate?.rmParserDidCancel(self)
        }
    }
    
    // MARK: Set timeline for Task
    private func setTimeline() {
        self.currentResponse?.timeline = RMTime(
            requestTime: self.startTime!,
            initializeResponseTime: self.initializeResponseTime!,
            requestCompletionTime: self.endTime!)
    }
}

// MARK - URLSessionDataDelegate
extension RMParser: URLSessionDataDelegate {
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        self.receiveData?.append(data)
    }
    
    // MARK: Start recieving response
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse,
                           completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        let response = response as? HTTPURLResponse
        self.initializeResponseTime = CFAbsoluteTimeGetCurrent()
        
        // initial current response
        self.currentResponse = RMResponse()
        self.currentResponse?.url = response?.url
        self.currentResponse?.httpResponse = response
        self.currentResponse?.statusCode = response!.statusCode
        self.currentResponse?.allHeaders = response?.allHeaderFields
        
        // Check Client Request Error
        if let currentResponse = response, self.HTTPClientError.contains(currentResponse.statusCode) {
            self.isError = true
        }
        
        // Check Client Request Error, from user define status code
        if let currentResponse = response, (self.currentRequest?.restrictStatusCodes.contains(currentResponse.statusCode))! {
            self.isError = true
        }
        
        // Check Server Response Error
        if let currentResponse = response, self.HTTPServerError.contains(currentResponse.statusCode) {
            self.isError = true
        }
        
        // Initialize data
        if self.receiveData != nil { self.receiveData = nil }
        self.receiveData = NSMutableData()
        self.receiveData?.length = 0
        completionHandler(.allow)
    }
}

// MARK - URLSessionTaskDelegate
extension RMParser: URLSessionTaskDelegate {
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        self.endTime = CFAbsoluteTimeGetCurrent()
        /** Spawn output to main queue */
        DispatchQueue.main.async {
             self.setTimeline() // Set response end time
            // Callback on Error
            guard error == nil else {
                self.isError = true
                let responseError = RMError(error: error!)
                responseError.type = .sessionTask
                responseError.localizeDescription = error!.localizedDescription
                self.completionHandler!(nil, responseError)
                self.delegate?.rmParserDidFail(self, error: responseError)
                return
            }
            
            // Raw data response
            if self.receiveData != nil && self.receiveData!.length > 0 {
                self.currentResponse?.data = self.receiveData!
            }
            
            // Due to restricted Error Code it will return an error
            if self.isError {
                // Add error object into response object
                let responseError = RMError()
                responseError.type = .statusCode
                responseError.localizeDescription = HTTPURLResponse.localizedString(
                    forStatusCode: self.currentResponse!.statusCode)
                responseError.statusCode = self.currentResponse!.statusCode
                responseError.response = self.currentResponse
                responseError.request = self.currentRequest
                self.completionHandler!(self.currentResponse, responseError)
            } else {
                self.completionHandler!(self.currentResponse, nil)
            }
            self.delegate?.rmParserDidfinished(self)
        }
    }
}
