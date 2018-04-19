//
//  RMHttpBuilder.swift
//  RMHttp
//
//  Created by Roger Molas on 12/04/2018.
//  Copyright © 2018 Roger Molas. All rights reserved.
//

import Foundation

open class RMHttpBuilder {
    
    public func buil(request: URLRequest?,
                     parameter: [String:String]?,
                     method: RMHttpMethod) -> URLRequest {
        
        var mUrlRequest = request
        if encodeParametersInUlr(method: method) {
            mUrlRequest = buildQuery(request!, parameters: parameter!)
        } else {
            mUrlRequest = buildHttpBodyQuery(request!, parameters: parameter!)
        }
        return mUrlRequest!
    }
    
    // MARK: Build URL parameters
    private func build(_ parameters: [String: String]) -> String {
        var components: [String] = []
        for key in parameters.keys.sorted(by: <) {
            let value = parameters[key]!
            components += ["\(key)=\(encodeValue(fromString: value)!)"]
        }
        return components.joined(separator: "&")
    }
    
    // MARK: Encode parameter value
    private func encodeValue(fromString:String) -> String! {
        let escapedString = fromString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        return escapedString!
    }
    
    // GET, DELETE
    public func buildQuery(_ urlRequest: URLRequest, parameters: [String:String]) -> URLRequest? {
        var mUrlRequest = urlRequest
        let paramString = build(parameters)
        var component = URLComponents(url: mUrlRequest.url!, resolvingAgainstBaseURL: false)
        component?.percentEncodedQuery = paramString
        
        if mUrlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
            mUrlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        mUrlRequest.url = component?.url
        return mUrlRequest
    }
    
    // POST, PUT, PATCH
    public func buildHttpBodyQuery(_ urlRequest: URLRequest, parameters: [String:String]) -> URLRequest? {
        var mUrlRequest = urlRequest
        let paramString = build(parameters)
        if mUrlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
            mUrlRequest.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
        }
        mUrlRequest.httpBody = paramString.data(using: .utf8, allowLossyConversion: false)
        return mUrlRequest
    }
    
    // JSON Encoding
    public func buildJSONHttpBody(_ urlRequest: URLRequest, parameters: [String:String]) -> URLRequest? {
        var mUrlRequest = urlRequest
        do {
            let data = try JSONSerialization.data(withJSONObject: parameters, options: .sortedKeys)
            if mUrlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
                mUrlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }
            mUrlRequest.httpBody = data
        } catch {
            return nil
        }
        return urlRequest
    }
    
    // Encode value to RFC
    private func encodeParametersInUlr(method: RMHttpMethod) -> Bool {
        switch method {
        case .GET, .DELETE:
            return true
        default:
            return false
        }
    }
}