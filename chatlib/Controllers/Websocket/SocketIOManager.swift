//
//  SocketIOManager.swift
//  Chat
//
//  Created by Asha Treesa Kurian on 12/10/20.
//  Copyright © 2020 fingent. All rights reserved.
//

import Foundation
import SocketIO

class SocketIOManager: NSObject {
    static let sharedInstance = SocketIOManager()
    var socketClient: SocketIOClient!
    var socketmanager : SocketIOManager!
    //var socket: SocketIOClient = SocketIOClient(socketURL: NSURL(string: Global.ServiceUrls.baseURL+Global.ServiceUrls.websocketURL)! as URL)
    let manager: SocketIOClient = SocketIOClient(socketURL: URL(string:Global.ServiceUrls.baseURL+Global.ServiceUrls.websocketURL)!, config: [.log(true), .compress])



    override init() {
    super.init()
        
        
        
        
        
        
        
}
    
 func connectSocket(completion: @escaping(Bool) -> () ) {
        disconnectSocket()
        manager.on(clientEvent: .connect) {[weak self] (data, ack) in
            print("socket connected")
            self?.manager.removeAllHandlers()
            completion(true)
        }
        manager.connect()
    }

    func disconnectSocket() {
        manager.removeAllHandlers()
        manager.disconnect()
        print("socket Disconnected")
    }

    func checkConnection() -> Bool {
        if manager.status == .connected {
            return true
        }
        return false

    }

    

        

       
}
