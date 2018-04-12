//
//  RMRequestManager.swift
//  RMHttp
//
//  Created by Roger Molas on 12/04/2018.
//  Copyright © 2018 Roger Molas. All rights reserved.
//

import Foundation

class RMRequestManager {
    static let sharedManager: RMRequestManager = RMRequestManager() // Single shared instance
    
    fileprivate var requestList: NSMutableArray = NSMutableArray()  // Holds all request objects
    
    // MARK: Dealloc objects
    deinit { requestList.removeAllObjects() }
    
    // MARK: - Public POST request
    public func generalPOST(completionHandler: @escaping RMParserCompleteSuccess,
                            errorHandler: @escaping RMParserError,
                            params: NSDictionary?,
                            urlString: String,
                            tag: Int) {
        let request = RMRequest(url: URL(string: urlString)!)
        let parser = RMParser()
        parser.delegate = self
        parser.parseWith(request: request,
                         completionHandler: completionHandler,
                         errorHandler: errorHandler)
    }
    
    public func generalGET(completionHandler: @escaping RMParserCompleteSuccess,
                           errorHandler: @escaping RMParserError,
                           params: NSDictionary?,
                           urlString: String,
                           tag: Int) {
        let request = RMRequest(url: URL(string: urlString)!)
        let parser = RMParser()
        parser.delegate = self
        parser.parseWith(request: request,
                         completionHandler: completionHandler,
                         errorHandler: errorHandler)
    }
    
    public func generalDELETE(completionHandler: @escaping RMParserCompleteSuccess,
                              errorHandler: @escaping RMParserError,
                              params: NSDictionary?,
                              urlString: String,
                              tag: Int) {
        let request = RMRequest(url: URL(string: urlString)!)
        let parser = RMParser()
        parser.delegate = self
        parser.parseWith(request: request,
                         completionHandler: completionHandler,
                         errorHandler: errorHandler)
    }
    
    // MARK: Stop all requests
    public func stopAllRequest() {
        requestList.enumerateObjects({ (parser, index, isFinished) in
            (parser as? RMParser)?.cancel()
        })
    }
}

// Build Custom URL Request
extension RMRequestManager {
    public func customRequest(completionHandler: @escaping RMParserCompleteSuccess,
                              errorHandler: @escaping RMParserError,
                              urlString: String,
                              method: RMRequestMethod,
                              hearder: [String:Any]) {
        let request = RMRequest(urlString: urlString, method: method, hearder: hearder)
        let parser = RMParser()
        parser.delegate = self
        parser.parseWith(request: request,
                         completionHandler: completionHandler,
                         errorHandler: errorHandler)
    }
    
    public func buildRequest(completionHandler: @escaping RMParserCompleteSuccess,
                              errorHandler: @escaping RMParserError,
                              request: RMRequest,
                              method: RMRequestMethod,
                              hearder: [String:Any]) {
        let parser = RMParser()
        parser.delegate = self
        parser.parseWith(request: request,
                         completionHandler: completionHandler,
                         errorHandler: errorHandler)
    }
}

// MARK - RMParserDelegate
extension RMRequestManager: RMParserDelegate {
    func rmParserDidfinished(_ parser: RMParser) {
        requestList.remove(parser)
    }
    
    func rmParserDidCancel(_ parser: RMParser) {
        requestList.remove(parser)
    }
    
    func rmParserDidFail(_ parser: RMParser, error: RMError?) {
        requestList.remove(parser)
    }
}
