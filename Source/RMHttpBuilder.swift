//
//  RMHttpBuilder.swift
//  RMHttp
//
//  Created by Roger Molas on 12/04/2018.
//  Copyright © 2018 Roger Molas. All rights reserved.
//

import Foundation

class RMHttpBuilder {
    
    func buil(request: URLRequest?,
              parameter: [String:String]?,
              method: RMHttpMethod) -> URLRequest {
        
        var mUrlRequest = request
        if encodeParametersInUlr(method: method) {
//            mUrlRequest = self.build(parameter!)
        } else {
             mUrlRequest = buildHttpBody(request!, parameters: parameter!)
        }
        return mUrlRequest!
    }
    
    // MARK: Build URL parameters
    func build(_ parameters: [String: String]) -> String {
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
    
    public func buildQuery(_ urlRequest: URLRequest, parameters: [String:String]) -> URLRequest? {
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
    
    // POST, PUT, PATCH
    public func buildHttpBody(_ urlRequest: URLRequest, parameters: [String:String]) -> URLRequest? {
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
    
    func encodeParametersInUlr(method: RMHttpMethod) -> Bool {
        switch method {
        case .GET, .DELETE:
            return true
        default:
            return false
        }
    }
}
