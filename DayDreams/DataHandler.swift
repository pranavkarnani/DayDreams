//
//  DataHandler.swift
//  DayDreams
//
//  Created by Pranav Karnani on 01/11/19.
//  Copyright © 2019 Pranav Karnani. All rights reserved.
//

import Foundation
import SocketIO
import NotificationCenter

class DataHandler {
    static let shared : DataHandler = DataHandler()
    
    var manager: SocketManager!
    var socket: SocketIOClient!
    
    func connectSocket(completion : @escaping (Bool) -> ()) {
        manager = SocketManager(socketURL: URL(string: "http://172.17.22.112:8080/")!, config: [.log(true), .compress])
             socket = manager.defaultSocket
        
             self.socket.connect()
             self.socket.on("connect") { ( dataArray, ack) -> Void in
                print("connected to external server")
                completion(true)
             }
    }
    
    func streamSocketData(text: String, completion: @escaping([Description]) -> ()) {
        self.socket.emit("getImages", text)
        
        socket.on("fetchedImages") { data,ack in
            do {
                let clustered = data[0] as! String
                if let j = clustered.data(using: .utf8, allowLossyConversion: false) {
                    let lessonImages = try JSONDecoder().decode([Description].self, from: j)
                    print(lessonImages)
                    completion(lessonImages)
                }
            }
            catch {
                completion([])
                print("\(error.localizedDescription)")
            }
        }
    }
    
}

struct Description : Decodable {
    var imageURL : String
}
