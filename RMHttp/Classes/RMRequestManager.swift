/*
 MIT License
 
 RMRequestManager.swift
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

open class RMRequestManager {
    
    static let sharedManager = RMRequestManager() // Single shared instance
    
    private var requestList: NSMutableArray = NSMutableArray()  // Holds all request objects
    
    var stopAllRequestOnFailure = false
    
    // MARK: Dealloc objects
    deinit { requestList.removeAllObjects() }
    
    // MARK: - Public request
    public func send(request: RMRequest, completionHandler: @escaping RMParserCompletionHandler) {
        let parser = RMParser()
        parser.delegate = self
        parser.parseWith(request: request, callback: completionHandler)
    }

    // MARK: Stop all requests
    public func stopAllRequest() {
        requestList.enumerateObjects({ (parser, index, isFinished) in
            (parser as? RMParser)?.cancel()
        })
    }
}

// MARK - RMParserDelegate
extension RMRequestManager: RMHttpParserDelegate {
    public func rmParserDidfinished(_ parser: RMParser) {
        if stopAllRequestOnFailure {
            stopAllRequest()
        }
        requestList.remove(parser)
    }
    
    public func rmParserDidCancel(_ parser: RMParser) {
        if parser.isCancel {
            requestList.remove(parser)
        }
        
        if stopAllRequestOnFailure {
            stopAllRequest()
        }
    }
    
    public func rmParserDidFail(_ parser: RMParser, error: RMError?) {
        if parser.isError {
            requestList.remove(parser)
        }
        
        if stopAllRequestOnFailure {
            stopAllRequest()
        }
    }
}
