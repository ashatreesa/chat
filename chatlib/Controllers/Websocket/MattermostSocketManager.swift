

import Foundation
import UIKit
import SocketIO
import Starscream
import CoreData


class MattermostSocketManager: NSObject {

    var socket: WebSocket!
    var isConnected: Bool  = false
    
  
    override init() {
        super.init()
        
        var request = URLRequest(url: URL(string: "wss://mattermost-mobile.fingent.net/api/v4/websocket")!)
               request.addValue("https://mattermost-mobile.fingent.net/api/v4/wss://mattermost-mobile.fingent.net/api/v4/websocket", forHTTPHeaderField: "Origin")
               socket = WebSocket(request: request)
               socket?.delegate = self
               socket.connect()
           

        
        print("MattermostSocketManager class init called")
//        if let socketURL = URL(string: Global.ServiceUrls.baseURL + Global.ServiceUrls.websocketURL) {
//            print("socketURL\(socketURL)")
//            var request = URLRequest(url: socketURL)
//            request.timeoutInterval = 5
//            socket = WebSocket(request: request)
//            if let socketObject = self.socket {
//                socketObject.delegate = self
//            }
//        }
    }
   
    
    //Shared instance
    public final  class var sharedInstance : MattermostSocketManager {
        struct Static {
            static var instance : MattermostSocketManager?
        }
        if !(Static.instance != nil) {
            Static.instance = MattermostSocketManager()
        }
        return Static.instance!
    }

    //Enable connection
    func establishConnection(){
        print("establishConnection")
        if !self.isConnected{
            self.socket.connect()
        }
    }

    //Disable connection
    func closeConnection(){
        if self.isConnected{
            self.socket.disconnect()
        }
    }
    
    //Write data to socket
    func writeToSocket(passedJSON : [String : Any])
    {
        let jsonData = try? JSONSerialization.data(withJSONObject: passedJSON, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        socket.write(string: jsonString!)
    }
}

//MARK:- Socket Delegates
extension MattermostSocketManager:WebSocketDelegate {
    func websocketDidConnect(socket: WebSocketClient) {
        print("websocket is connected")
    }
    func didReceive(event: WebSocketEvent, client: WebSocket) {
        switch event {
        case .connected(let headers):
            self.isConnected = true
            print("websocket is connected: \(headers)")
            self.websocketDidConnect()
        case .disconnected(let reason, let code):
            isConnected = false
            print("websocket is disconnected: \(reason) with code: \(code)")
            self.websocketDidDisconnect(reason: reason, code: code)
        case .text(let string):
            print("Received text: \(string)")
        self.receivedMsgAction(for: string)
        case .binary(let data):
            print("Received data: \(data.count)")
        case .ping(_):
            break
        case .pong(_):
            break
        case .viabilityChanged(_):
            break
        case .reconnectSuggested(_):
            break
        case .cancelled:
            isConnected = false
        case .error(let error):
            print("error===\(error)")
            isConnected = false
            print(error ?? "")
        }
    }
    
    func websocketDidConnect() {
        print("Socket Status - websocketDidConnect")
        let jsonDict =  ["seq": 1,"action":"authentication_challenge","data":["token": (Global.Constants.Token)]] as [String : Any]
        let jsonData = try? JSONSerialization.data(withJSONObject: jsonDict, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        socket.write(string: jsonString!)
    }
    
    func websocketDidDisconnect(reason: String, code: UInt16) {
        print("Socket Status : websocketDidDisconnect ")
//        if CheckingAppState.shared.state == StateIs.Active.rawValue && CheckingNetworkState.shared.state == NetworkState.netOn.rawValue{
//            print("Active")
//            let dispatchAt = DispatchTime.now() + 0.3
//            DispatchQueue.main.asyncAfter(deadline: dispatchAt, execute: {
               self.establishConnection()
//            })
//        }else{
            print("Background")
        //}
        print("reason")
    }
       
    //MARK:- Received Message From Socket
    func receivedMsgAction(for text: String)
    {
        guard let data = text.data(using: .utf16),
            let jsonData = try? JSONSerialization.jsonObject(with: data),
            let jsonDict = jsonData as? [String: Any],
            let event = jsonDict["event"] as? String else {
                return
        }

//        switch event {
//        //MARK:- Posted
//        case Event.posted.rawValue:
//            guard let data = jsonDict["data"] as? NSDictionary,
//                let post = data["post"] as? String,
//                let postData = post.data(using: .utf8) else { return }
//            do{
//                guard let value = try JSONSerialization.jsonObject(with: postData, options: []) as? [String: AnyObject],
//                    let messageType = value["type"] as? String, messageType != "system_purpose_change",
//                    let channelType = data["channel_type"] as? String, channelType == "P",
//                    let properties = value["props"] as? NSDictionary else { return }
//                    NotificationCenter.default.post(name: NSNotification.Name("MessageRecieved"), object: nil, userInfo : ["post": value as NSDictionary, "properties": properties])
//            }catch {
//                print(error.localizedDescription)
//            }
//
//        //MARK:- Typing
//        case Event.posted.rawValue:
//            print(jsonDict)
//
//        default:
//            print("Default")
//        }
    }
}
