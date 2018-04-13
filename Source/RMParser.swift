//
//  RMParser.swift
//  RMHttp
//
//  Created by Roger Molas on 12/04/2018.
//  Copyright © 2018 Roger Molas. All rights reserved.
//

import Foundation

public protocol RMParserDelegate {
    func rmParserDidfinished(_ parser: RMParser)
    func rmParserDidFail(_ parser: RMParser, error: RMError?)
    func rmParserDidCancel(_ parser: RMParser)
}

typealias RMParserCompleteSuccess = (RMResponse?) -> Swift.Void
typealias RMParserError = (RMError?) -> Swift.Void

open class RMParser: NSObject {
    public var delegate: RMParserDelegate? = nil
    public var isCancel = false
    public var isError = false

    private var task: URLSessionDataTask? = nil
    private var receiveData: NSMutableData? = nil
    
    private var currentRequest: RMRequest? = nil
    private var currentResponse: RMResponse? = nil
    
    private var parserSuccessHandler:RMParserCompleteSuccess? = nil
    private var parserErrorHandler: RMParserError? = nil
    
    private var startTime: CFAbsoluteTime?
    private var initializeResponseTime: CFAbsoluteTime?
    private var endTime: CFAbsoluteTime?
    
    var restrictedStatusCodes:Set<Int> = []
    
    public override init() {
        super.init()
    }
    
    func parseWith(request: RMRequest,
                   completionHandler: RMParserCompleteSuccess?,
                   errorHandler: RMParserError?) {
        parserSuccessHandler = nil
        parserErrorHandler = nil
        currentRequest = nil
        
        // Reference Callbacks and request
        parserSuccessHandler = completionHandler
        parserErrorHandler = errorHandler
        currentRequest = request
        restrictedStatusCodes = request.restrictStatusCodes
        
        // Session configuration
        var session = URLSession.shared
        let sessionConfig = request.sessionConfig // connection per host
        session = URLSession(configuration: sessionConfig!, delegate: self, delegateQueue: OperationQueue.main)
        task = session.dataTask(with: request.urlRequest)
        self.resume()
    }
    
    // MARK: Life cycle
    deinit {
        parserSuccessHandler = nil
        parserErrorHandler = nil
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
}

// MARK - URLSessionDataDelegate
extension RMParser: URLSessionDataDelegate {
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        DispatchQueue.main.async {
            self.receiveData?.append(data)
        }
    }
    
    // MARK: Start recieving response
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        DispatchQueue.main.async {
            let response = response as? HTTPURLResponse
            self.initializeResponseTime = CFAbsoluteTimeGetCurrent()
            
            self.currentResponse = RMResponse()
            self.currentResponse?.httpResponse = response
            self.currentResponse?.statusCode = response?.statusCode
            self.currentResponse?.allHeaders = response?.allHeaderFields
            
            if let currentResponse = response, self.restrictedStatusCodes.contains(currentResponse.statusCode) {
                self.isError = true
                self.endTime = CFAbsoluteTimeGetCurrent()
                let responseError = RMError()
                responseError.response = self.currentResponse
                responseError.request = self.currentRequest
                
                self.parserErrorHandler!(responseError)
                self.delegate?.rmParserDidFail(self, error: responseError)
                completionHandler(.cancel)
            }
            
            if self.receiveData != nil { self.receiveData = nil }
            self.receiveData = NSMutableData()
            self.receiveData?.length = 0
            completionHandler(.allow)
        }
    }
}

// MARK - URLSessionTaskDelegate
extension RMParser: URLSessionTaskDelegate {
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        self.endTime = CFAbsoluteTimeGetCurrent()
        guard error == nil else {
            isError = true
            /** Spawn output to main queue */
            DispatchQueue.main.async {
                let responseError = RMError()
                self.parserErrorHandler!(responseError)
                self.delegate?.rmParserDidFail(self, error: responseError)
            }
            return
        }
        /** Spawn output to main queue */
        DispatchQueue.main.async {
            if self.receiveData != nil && self.receiveData!.length > 0 {
                self.currentResponse?.data = self.receiveData!
            }
            self.currentResponse?.timeline = RMTime(
                requestTime: self.startTime!,
                initializeResponseTime: self.initializeResponseTime!,
                requestCompletionTime: self.endTime!)
            self.parserSuccessHandler!(self.currentResponse)
            self.delegate?.rmParserDidfinished(self)
        }
    }
}
