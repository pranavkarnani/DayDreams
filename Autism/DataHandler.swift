//
//  DataHandler.swift
//  Autism
//
//  Created by Pranav Karnani on 23/03/19.
//  Copyright © 2019 Pranav Karnani. All rights reserved.
//

import Foundation

struct KeyWords : Codable {
    var body : String = "N/A"
}

var details = KeyWords()

class DataHandler {
    let keywordsURL = "http://api.cortical.io:80/rest/text/keywords?retina_name=en_associative"
    static let shared : DataHandler = DataHandler()
    func getKeywords(text: String, completion : @escaping ([String]) -> ()) {
        
        details.body = text
        
        let jsonData = try? JSONEncoder().encode(details)
        var request = URLRequest(url: URL(string: keywordsURL)!)
        
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("error:", error)
                return
            }
            else {
                do {
                    let keywords = try JSONSerialization.jsonObject(with: data!, options: [.mutableContainers, .allowFragments]) as? [String]
                    completion(keywords!)
                }
                catch {
                    print(error)
                }
            }
        }.resume()
    }
}
