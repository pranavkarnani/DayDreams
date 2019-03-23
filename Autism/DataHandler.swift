//
//  DataHandler.swift
//  Autism
//
//  Created by Pranav Karnani on 23/03/19.
//  Copyright © 2019 Pranav Karnani. All rights reserved.
//

import Foundation
import SocketIO

var lessonImages = Images(data: [])
struct KeyWords : Codable {
    var body : String = "N/A"
}

struct Images : Decodable {
    var data : [Description]
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
            guard let dataImages = data.last as? Data else { return }
            do {
                lessonImages = try JSONDecoder().decode(Images.self, from: dataImages)
                completion(0)
            }
                
            catch {
                completion(1)
                print("\(error.localizedDescription)")
            }
        }
    }
    
    func establishConnection() {
        socket.connect()
    }
    
    func closeConnection() {
        socket.disconnect()
    }
}
