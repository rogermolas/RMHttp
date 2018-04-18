//
//  RMRequestManager.swift
//  RMHttp
//
//  Created by Roger Molas on 12/04/2018.
//  Copyright © 2018 Roger Molas. All rights reserved.
//

import Foundation

open class RMHttpRequestManager {
    
    static let sharedManager = RMHttpRequestManager() // Single shared instance
    
    private var requestList: NSMutableArray = NSMutableArray()  // Holds all request objects
    
    private let queue = DispatchQueue(label: "com.RMHttp.request.started")
    
    var stopAllRequestOnFailure = false
    
    // MARK: Dealloc objects
    deinit { requestList.removeAllObjects() }
    
    // MARK: - Public request
    public func sendRequest(completionHandler: @escaping RMHttpParserComplete,
                            errorHandler: @escaping RMHttpParserError,
                            request: RMHttpRequest) {
        let parser = RMHttpParser()
        parser.delegate = self
        parser.parseWith(request: request,
                         completionHandler: completionHandler,
                         errorHandler: errorHandler)
    }

    // MARK: Stop all requests
    public func stopAllRequest() {
        requestList.enumerateObjects({ (parser, index, isFinished) in
            (parser as? RMHttpParser)?.cancel()
        })
    }
}

// MARK - RMParserDelegate
extension RMHttpRequestManager: RMHttpParserDelegate {
    public func rmParserDidfinished(_ parser: RMHttpParser) {
        if stopAllRequestOnFailure {
            stopAllRequest()
        }
        requestList.remove(parser)
    }
    
    public func rmParserDidCancel(_ parser: RMHttpParser) {
        if parser.isCancel {
            requestList.remove(parser)
        }
        
        if stopAllRequestOnFailure {
            stopAllRequest()
        }
    }
    
    public func rmParserDidFail(_ parser: RMHttpParser, error: RMHttpError?) {
        if parser.isError {
            requestList.remove(parser)
        }
        
        if stopAllRequestOnFailure {
            stopAllRequest()
        }
    }
}
