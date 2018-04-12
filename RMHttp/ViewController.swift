//
//  ViewController.swift
//  RMHttp
//
//  Created by Greatfeat on 12/04/2018.
//  Copyright © 2018 Roger Molas. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        RMRequestManager.sharedManager.generalGET(completionHandler: { (response) in
            print(response?.JSONResponse(result: HTTPObject.value(Dictionary<String,Any>())) ?? "")
        
        }, errorHandler: { (error) in
            
        }, params: nil, urlString: "http://35.201.183.109:1341/api/lobby", tag: 0)
        
//        let parser = RMParser()
//        let request = RMRequest(urlString: "http://35.201.183.109:1341/api/lobby", method: .GET, hearder: nil)
//        parser.parseWith(request: request, completionHandler: { (response) in
//            print(response?.JSONResponse(result: HTTPObject.value(Dictionary<String,Any>())) ?? "")
//        }) { (error) in
//
//        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

