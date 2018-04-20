//
//  RMBuilder.swift
//  RMHttp
//
//  Created by Roger Molas on 12/04/2018.
//  Copyright © 2018 Roger Molas. All rights reserved.
//

import Foundation

private enum HeaderField: String {
    case contentType = "Content-Type"
}

private enum HeaderValue: String {
    case JSON = "application/json"
    case urlEncoded = "application/x-www-form-urlencoded; charset=utf-8"
}

open class RMBuilder {
    
    public func build(request: URLRequest?,
                      parameter: [String:String]?,
                      method: RMHttpMethod<Encoding>) -> URLRequest {
        var mUrlRequest = request
        if method.encoding == .URLEncoding { // URL Default
            // Default Encoding
            if encodeParametersInUlr(method: method) {
                mUrlRequest = buildQuery(request!, parameters: parameter!)
            } else {
                mUrlRequest = buildHttpBodyQuery(request!, parameters: parameter!)
            }
        } else { // JSON Body
            mUrlRequest = buildJSONHttpBody(request!, parameters: parameter!)
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
    
    //MARK:- Parameters Encoding (GET, DELETE)
    private func buildQuery(_ urlRequest: URLRequest, parameters: [String:String]) -> URLRequest? {
        var mUrlRequest = urlRequest
        let paramString = build(parameters)
        var component = URLComponents(url: mUrlRequest.url!, resolvingAgainstBaseURL: false)
        component?.percentEncodedQuery = paramString
        if mUrlRequest.value(forHTTPHeaderField: HeaderField.contentType.rawValue) == nil {
            mUrlRequest.setValue(HeaderValue.JSON.rawValue, forHTTPHeaderField: HeaderField.contentType.rawValue)
        }
        mUrlRequest.url = component?.url
        return mUrlRequest
    }
    
    //MARK:- Parameters Encoding (POST, PUT, PATCH)
    private func buildHttpBodyQuery(_ urlRequest: URLRequest, parameters: [String:String]) -> URLRequest? {
        var mUrlRequest = urlRequest
        let paramString = build(parameters)
        if mUrlRequest.value(forHTTPHeaderField: HeaderField.contentType.rawValue) == nil {
            mUrlRequest.setValue(HeaderValue.urlEncoded.rawValue, forHTTPHeaderField: HeaderField.contentType.rawValue)
        }
        mUrlRequest.httpBody = paramString.data(using: .utf8, allowLossyConversion: false)
        return mUrlRequest
    }
    
    // JSON Data Encoding
    private func buildJSONHttpBody(_ urlRequest: URLRequest, parameters: [String:String]) -> URLRequest? {
        var mUrlRequest = urlRequest
        do {
            let data = try JSONSerialization.data(withJSONObject: parameters, options: .sortedKeys)
            if mUrlRequest.value(forHTTPHeaderField: HeaderField.contentType.rawValue) == nil {
                mUrlRequest.setValue(HeaderValue.JSON.rawValue, forHTTPHeaderField: HeaderField.contentType.rawValue)
            }
            mUrlRequest.httpBody = data
        } catch {
            return nil
        }
        return urlRequest
    }
    
    // Check if parameters encoded to HttpBody or within URL
    private func encodeParametersInUlr(method: RMHttpMethod<Encoding>) -> Bool {
        switch method.httpMethod {
        case "GET", "DELETE":
            return true
        default:
            return false
        }
    }
}
