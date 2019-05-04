//
//  DataHandler.swift
//  Autism
//
//  Created by Pranav Karnani on 23/03/19.
//  Copyright © 2019 Pranav Karnani. All rights reserved.
//

import Foundation
import SocketIO
import SwiftyJSON

var lessonImages : [Description] = []

struct KeyWords : Codable {
    var text : String = "N/A"
}

struct Description : Decodable {
    var imageURL : String
    var desc : String
}

var details = KeyWords()

class DataHandler {

    static let manager = SocketManager(socketURL: URL(string: "https://protected-falls-97522.herokuapp.com/")!, config: [.log(false), .compress])
    let socket = manager.defaultSocket
    
    
    let keywordsURL = "http://api.cortical.io:80/rest/text/keywords?retina_name=en_associative"
    static let shared : DataHandler = DataHandler()
    
//    func getKeywords(text: String, completion : @escaping ([String]) -> ()) {
//
//        details.body = text
//
//        let jsonData = try? JSONEncoder().encode(details)
//        var request = URLRequest(url: URL(string: keywordsURL)!)
//
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.httpBody = jsonData
//
//        URLSession.shared.dataTask(with: request) { (data, response, error) in
//            if let error = error {
//                print("error:", error)
//                return
//            }
//            else {
//                do {
//                    let keywords = try JSONSerialization.jsonObject(with: data!, options: [.mutableContainers, .allowFragments]) as? [String]
//                    completion(keywords!)
//                }
//                catch {
//                    print(error)
//                }
//            }
//        }.resume()
//    }
    
    func getImages(completion : @escaping() -> ()) {
        socket.on("addImage") { data,ack in
            print(data)
        }
    }
    
    func connectSocket(completion : @escaping (Bool) -> ()) {
        socket.on(clientEvent: .connect) {data, ack in
            print("socket connected")
            completion(true)
        }
        establishConnection()
    }
    
    func sendMessage(text: String, completion : @escaping(Int) -> ()) {
        socket.emit("getText",text)
        
        socket.on("addImage") { data,ack in
            do {
                let clustered = data[0] as! String
                if let j = clustered.data(using: .utf8, allowLossyConversion: false) {
                    lessonImages = try JSONDecoder().decode([Description].self, from: j)
                    print(lessonImages)
                    completion(0)
                }
            }
            catch {
                completion(1)
                print("\(error.localizedDescription)")
            }
        }
    }
    
    func getMessageData(text: String, completion : @escaping(Int) -> ()) {
        details.text = text
        let jsonData = try? JSONEncoder().encode(details)
        var request = URLRequest(url: URL(string: "https://protected-falls-97522.herokuapp.com/fetchImages")!)
        
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("error:", error)
                return
            }
            else {
                guard let data = data else { return }
                do {
                    lessonImages = try JSONDecoder().decode([Description].self, from: data)
                    print(lessonImages)
                    completion(0)
                }
                catch {
                    print(error)
                    completion(1)
                }
            }
            }.resume()
    }
    
    func establishConnection() {
        socket.connect()
    }
    
    func closeConnection() {
        socket.disconnect()
    }
}
