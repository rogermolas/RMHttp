/*
MIT License

RMFormDataFile.swift
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
/**
	RMFormDataFile is the object contains media data for Form-Data request
	
	- Note:
		- Media can be added directly to `RMRequest` instance
		- For adding file in request  use `RMRequest.addFile(...)`
*/
public struct RMFormDataFile {
	/// The parameter field name
	public var fieldName: String
	
	/// The parameter field value
	public var file: Data
	
	/// The media file name
	public var fileName: String
	
	/// MimeType or media type (see https://en.wikipedia.org/wiki/Media_type)  for supported media types
	public var mimeType: String
	
	/**
		Initialization
		
		- Parameters:
			- fieldName: The parameter field name, must be String type
			- file: The parameter field value, must be in Data type
			- fileName: The media file name, must be String type
			- mimeType: Media type, must be String (e.g  image/jpeg, application/pdf)
	*/
	public init(_ fieldName:String, _ file:Data, _ fileName: String, _ mimeType:String) {
		self.fieldName = fieldName
		self.file = file
		self.fileName = fileName
		self.mimeType = mimeType
	}
}

