//
//  ViewController.swift
//  RMHttp
//
//  Created by Roger Molas on 12/04/2018.
//  Copyright © 2018 Roger Molas. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    let list = ["GET",
                "GET with PARAMS",
                "POST",
                "POST with PARAMS",
                "POST JSON BODY",
                "DELETE",
                "STRING RESPONSE",
                "CODABLE REQUEST",
				"FORM-DATA REQUEST"]
    
    
    func decode<T:Decodable> (model: T.Type) {
        let data =
            """
            {
            "headers":
            {
                "accept" : "*/*",
                "connection" : "close",
                "host" : "httpbin.org",
            },
            "url" : "https:httpbin.org/get" }
            """.data(using: .utf8)
        
        let myStruct = try! JSONDecoder().decode(model, from: data!)
        print(myStruct)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        decode(model: TModel.self)
        
        tableView.tableFooterView = UIView()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? DestinationViewController {
            if let type = sender as? String {
                destination.type = type
            }
        }
    }
}

extension ViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = list[indexPath.row]
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let type = list[indexPath.row]
        self.performSegue(withIdentifier: "details segue", sender: type)
    }
}
