//
//  ViewController.swift
//  RMHttp
//
//  Created by Roger Molas on 12/04/2018.
//  Copyright © 2018 Roger Molas. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let header = ["X-AUTH-TOKEN": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhcHAiOnsidmVyc2lvbiI6IjEuMiIsImRldmljZUlkIjoiQjY3NkYxNUItRDk2OS00NDY4LUFBMkEtNkUxRTJCNzQ5ODE2IiwicGxhdGZvcm0iOiJpT1MiLCJzeXN0ZW1WZXJzaW9uIjoiMTEuMiIsImRldmljZU1vZGVsIjoiaVBob25lIn0sInRva2VuIjoiN2I4ZTE4YTM4NWFiZmVkOTIzMDI5ZmQ2ODQ0ZTI5NzA0MmI1MzM2ZSIsImxvZ2luTmFtZSI6IjAwMDAwdGVzdCJ9.kqiFkqfTazoSsU-FQuEI6UZYvDoIn6ujU7RPf2Qpspc"]
//
//        let request = RMRequest(urlString: "http://mobile.tridentinternational.co/api/m/deposit/gateway/send?category=30&amount=12&id=NTM=", method: .GET, hearder: header)
////        request.restrictStatusCodes = [404, 500]
//
//        RMHttp.stringRequest(completionHandler: { (string) in
//            print(string!)
//        }, errorHandler: { (error) in
//
//        }, request: request)
        
        
        let request = RMRequest(urlString: "http://35.201.183.109:1341/api/gameNav", method: .GET, hearder: header)
        RMHttp.jsonRequest(completionHandler: { (s) in
            
        }, errorHandler: { (error) in
            
        }, request: request)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

