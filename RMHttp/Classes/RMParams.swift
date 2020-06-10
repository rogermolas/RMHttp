/*
MIT License

RMParams.swift
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

/// Is a container for url request query 
public struct RMParams {
	
	/// Key must be string
	public var key: String
	
	/// Value must be any type
	public var value: Any
	
	/**
		Initialization
		- Parameters:
			- key: The parameter field name, must be String type
			- value: The parameter field value, must be in Any type
	*/
	public init(key:String, value: Any) {
		self.key = key
		self.value = value
	}
	
	/// Dictionary representation of params
	public var dictionary: [String: Any] {
		return [ "\(key)": "\(value)" ]
	}
}

/// A textual representation of this instance, suitable for debugging.
///     let params = RMParams(...)
///     let s = String(describing: params)
///     print(s)
///
///   	print:
///			[ key1 : value1, key2 : value2, key3 : value3 ]
///
extension RMParams: CustomStringConvertible {
	public var description: String {
		var desc: [String] = []
		desc.append("\(key):\(value)")
		return desc.joined(separator: " , ")
	}
}
