//
//  RMParser.swift
//  RMHttp
//
//  Created by Roger Molas on 12/04/2018.
//  Copyright © 2018 Roger Molas. All rights reserved.
//

import Foundation

public protocol RMParserDelegate: NSObjectProtocol {
    func rmParserDidfinished(_ parser: RMParser)
    func rmParserDidFail(_ parser: RMParser, error: RMError?)
    func rmParserDidCancel(_ parser: RMParser)
    func rmParserRestartAll(_ parser: RMParser)
}

typealias RMParserCompleteSuccess = ((RMResponse?) -> Swift.Void?)
typealias RMParserError = ((RMError?) -> Swift.Void?)

open class RMParser: NSObject {
    public var delegate: RMParserDelegate? = nil
    public var isCancel = false
    public var isError = false

    private var task: URLSessionDataTask? = nil
    private var receiveData: NSMutableData? = nil
    
    private var currentRequest: RMRequest? = nil
    private var currentResponse: RMResponse? = nil
    
    private var parserSuccessHandler: RMParserCompleteSuccess? = nil
    private var parserErrorHandler: RMParserError? = nil
    
    func parseWith(request: RMRequest,
                   completionHandler: @escaping RMParserCompleteSuccess,
                   errorHandler: @escaping RMParserError) {
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
        receiveData?.append(data)
    }
    
    // MARK: Start recieving response
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        let response = response as? HTTPURLResponse
        currentResponse = RMResponse()
        currentResponse?.statusCode = response?.statusCode
        currentResponse?.allHeaders = response?.allHeaderFields
        
        if receiveData != nil { receiveData = nil }
        receiveData = NSMutableData()
        receiveData?.length = 0
        completionHandler(.allow)
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
        
        if self.receiveData != nil && self.receiveData!.length > 0 {
            currentResponse?.data = self.receiveData!
        }
        parserSuccessHandler!(currentResponse)
    }
}

