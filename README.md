![RMHttp Lightweight RESTful library for iOS and watchOS](https://raw.githubusercontent.com/rogermolas/RMHttp/master/RMHttp/Assets.xcassets/RMHttp.imageset/RMHttp.png)

[![Build Status](https://travis-ci.org/rogermolas/RMHttp.svg?branch=master)](https://travis-ci.org/rogermolas/RMHttp)
![Status](https://img.shields.io/badge/status-active-brightgreen.svg?style=flat)
[![license](https://img.shields.io/github/license/mashape/apistatus.svg?maxAge=2592000)](https://github.com/rogermolas/RMHttp/blob/master/LICENSE)
[![Twitter](https://img.shields.io/badge/twitter-roger__molas-yellowgreen.svg)](https://www.twitter.com/roger_molas)


RMHttp is a Lightweight REST library for iOS and watchOS.

## Features

- [x]  Chainable Request
- [x]  URL / JSON  Parameter Encoding
- [x]  HTTP Methods GET/POST/DELETE/PATCH/PUT based in  [RFC2616](https://tools.ietf.org/html/rfc2616#section-5.1.1)
- [x]  Custom Request Builder / HEADERS / PARAMETERS
- [x]  Dynamic Response Handler (JSONObject, JSONArray, String)
##### TODO:
- [-] Codable Support
- [-] Support Upload/Download resource


## Installation
```ruby
pod "RMHttp"
```

Run the following command in your Terminal
```bash
$ pod install
```

## Usage

##### HTPP Methods
HTTP Methods are declared in public enum `RMHttpMethod`.

`GET`, `POST` , `DELETE` , `PUT` , `PATCH`

##### Parameter Encoding
Encoding are declared in public enum `Encoding`

`URLEncoding`
`JSONEncoding`

##### Serialization
`JSONObject` - a representation of `Dictionary<String, Any>`
```swift
{
    "data" : "value",
    "isBoolean" : true,
    "list": [
        "object1",
        "object2"
        ]
}
```

`JSONArray` - a representation of `[Dictionary<String, Any>]`

```swift
[
    { "data1" : "value1"},
    { "data2" : "value2"},
    { "data3" : "value3"},
]
```

`String`
Any String respresentation (e.g HTML String, XML String, Plain Text)

##### Building Request

```swift
let request = RMRequest(urlString: urlString,
method:RMHttpMethod.GET(Encoding.URLEncoding),
parameters: nil,
hearders: nil)
```

##### Chained Response Handlers

###### Expecting Array object Response
```swift
RMHttp.request(completionHandler: { (response: JSONArray?) in
    if let data = response {
        self.textView.text = "\(data)"
    }
}, errorHandler: { (error) in
    if let err = error {
        self.textView.text = "\(err)"
    }
}, request: request)
```

###### Expecting JSON object Response
```swift
RMHttp.request(completionHandler: { (response: JSONObject?) in
    if let data = response {
        self.textView.text = "\(data)"
    }
}, errorHandler: { (error) in
    if let err = error {
        self.textView.text = "\(err)"
    }
}, request: request)
```

Generic method that return HTTP response has parameter  `data`  that comply to `RMHttpProtocol` (e.g JSONObject, JSONArray,  String, )
```swift
func request<T>(completionHandler: @escaping (_ data: T?) -> Swift.Void,
                errorHandler: @escaping (_ error: RMError?) -> Swift.Void,
                request: RMRequest)
```



