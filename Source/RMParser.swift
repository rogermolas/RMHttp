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
        
        // Session configuration
        var session = URLSession.shared
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.allowsCellularAccess = true // use cellular data
        sessionConfig.timeoutIntervalForRequest = request.timeoutIntervalForRequest // timeout per request
        sessionConfig.timeoutIntervalForResource = 30.0 // timeout per resource access
        sessionConfig.httpMaximumConnectionsPerHost = 1 // connection per host
        session = URLSession(configuration: sessionConfig, delegate: self, delegateQueue: OperationQueue.main)
        task = session.dataTask(with: request.request)
        task?.resume()
    }
    
    // MARK: Life cycle
    deinit {
        parserSuccessHandler = nil
        parserErrorHandler = nil
    }
    
    // MARK: Suppend task operations
    public func suspend() {
        task?.suspend()
    }
    
    // MARK: Cancel task operations
    public func cancel() {
        task?.cancel()
        task = nil
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
            self.currentResponse = RMResponse()
            self.currentResponse?.statusCode = response?.statusCode
            self.currentResponse?.allHeaders = response?.allHeaderFields
            
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
        guard error == nil else {
            isError = true
            let responseError = RMError()
            parserErrorHandler!(responseError)
            self.delegate?.rmParserDidFail(self, error: responseError)
            return
        }
        /** Spawn output to main queue */
        DispatchQueue.main.async {
            if self.receiveData != nil && self.receiveData!.length > 0 {
                self.currentResponse?.data = self.receiveData!
            }
            self.parserSuccessHandler!(self.currentResponse)
            self.delegate?.rmParserDidfinished(self)
        }
    }
}
