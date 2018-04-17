//
//  RMParser.swift
//  RMHttp
//
//  Created by Roger Molas on 12/04/2018.
//  Copyright © 2018 Roger Molas. All rights reserved.
//

import Foundation

public protocol RMHttpParserDelegate {
    func rmParserDidfinished(_ parser: RMHttpParser)
    func rmParserDidFail(_ parser: RMHttpParser, error: RMHttpError?)
    func rmParserDidCancel(_ parser: RMHttpParser)
}

public typealias RMHttpParserComplete = (RMHttpResponse?) -> Swift.Void
public typealias RMHttpParserError = (RMHttpError?) -> Swift.Void

open class RMHttpParser: NSObject {
    public var delegate: RMHttpParserDelegate? = nil
    public var isCancel = false
    public var isError = false

    private var task: URLSessionDataTask? = nil
    private var receiveData: NSMutableData? = nil
    
    private var currentError: RMHttpError? = nil
    private var currentRequest: RMHttpRequest? = nil
    private var currentResponse: RMHttpResponse? = nil
    
    private var parserSuccessHandler:RMHttpParserComplete? = nil
    private var parserErrorHandler: RMHttpParserError? = nil
    
    private var startTime: CFAbsoluteTime?
    private var initializeResponseTime: CFAbsoluteTime?
    private var endTime: CFAbsoluteTime?
    
    private var restrictedStatusCodes:Set<Int> = []
    
    public override init() { super.init() }
    
    public func parseWith(request: RMHttpRequest,
                          completionHandler: RMHttpParserComplete?,
                          errorHandler: RMHttpParserError?) {
        
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
    
    // MARK: Set timeline for Task
    private func setTimeline() {
        self.currentResponse?.timeline = RMHttpTime(
            requestTime: self.startTime!,
            initializeResponseTime: self.initializeResponseTime!,
            requestCompletionTime: self.endTime!)
    }
}

// MARK - URLSessionDataDelegate
extension RMHttpParser: URLSessionDataDelegate {
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        print(data ?? "No data")
        self.receiveData?.append(data)
       
    }
    
    // MARK: Start recieving response
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        let response = response as? HTTPURLResponse
        self.initializeResponseTime = CFAbsoluteTimeGetCurrent()
        
        self.currentResponse = RMHttpResponse()
        self.currentResponse?.httpResponse = response
        self.currentResponse?.statusCode = response?.statusCode
        self.currentResponse?.allHeaders = response?.allHeaderFields
        
        // Callback on Error
        if let currentResponse = response, self.restrictedStatusCodes.contains(currentResponse.statusCode) {
            self.isError = true
            self.endTime = CFAbsoluteTimeGetCurrent()
            self.setTimeline()
            let responseError = RMHttpError()
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

// MARK - URLSessionTaskDelegate
extension RMHttpParser: URLSessionTaskDelegate {
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        self.endTime = CFAbsoluteTimeGetCurrent()
        /** Spawn output to main queue */
        DispatchQueue.main.async {
            // Callback on Error
            guard error == nil else {
                self.isError = true
                self.setTimeline()
                let responseError = RMHttpError(error: error!)
                self.parserErrorHandler!(responseError)
                self.delegate?.rmParserDidFail(self, error: responseError)
                return
            }
            if self.receiveData != nil && self.receiveData!.length > 0 {
                self.currentResponse?.data = self.receiveData!
                self.setTimeline()
            }
            self.parserSuccessHandler!(self.currentResponse)
            self.delegate?.rmParserDidfinished(self)
        }
    }
}
