//
//  PostManager.swift
//  Chat
//
//  Created by Asha Treesa Kurian on 30/09/20.
//  Copyright © 2020 fingent. All rights reserved.
//

import Foundation
import CoreData
import Alamofire
import AlamofireImage
import RxSwift
import NotificationCenter

class PostManager  {
    
    static let postInstance = PostManager()
    var disposeBag = DisposeBag()
    var presenter: DataPresenter?
    var mesageQueue: [Messages] = []
    var msgDictionary: NSDictionary = [:]
    var posting: Bool = false
    
    init() {
        presenter = DataPresenter()
        print("succes")
        
      //  try Reachability.startNotifier(self)
       // NotificationCenter.default.addObserver(self, selector: #selector(self.networkChanged), name: Notification.Name.networkChanged, object: nil)

    }
    func networkChanged(){
         print("killed called tested")
       //  state = true
       /*  let reachability = notification.userInfo!["connection"] as! Reachability
         if reachability.connection != .none{
             state = true
         }  */
     }
     
     //MARK:- add message to queue
     func addMessageToQueue(messageEntity: Messages) {
         mesageQueue.append(messageEntity)
         if state == false && !posting{
             state = true
         }
     }
     
     func addMessagesToQueue(messagesEntity: [Messages])  {
         mesageQueue = messagesEntity
         if state == false && !posting{
             state = true
         }
     }
     
     public var state : Bool = false{
         didSet{
             print(oldValue)
             if state{
                 if mesageQueue.count > 0{
                     postMessage()
                 }
             }
         }
     }
     
     public var postSuccess: Bool = false{
         didSet{
             print(postSuccess)
             if postSuccess{
                 mesageQueue.remove(at: 0)
                 if mesageQueue.count > 0, !posting{
                     state = true
                 }
             }
         }
     }
     
     func postMessage() {
         if let message = mesageQueue[0] as? Messages{
             guard let channelID = message.channelId,
                 let chatMsg = message.message,
                 let messageId = message.messageId else{
                     return
             }
             let params = [
                 "channel_id": channelID,
                 "message": chatMsg,
                  "props": [ "id": messageId]
                 ] as [String : Any]
             
            let getMentionCount = Global.ServiceUrls.baseURL + Global.ServiceUrls.mattermostpostmessage
             if(ReachabilityManager.isInternetAvailable()){
                 self.posting = true
               /// let headers: HTTPHeaders = ["Authorization": "Bearer \(Global.Constants.Token)"]

                // let headers: HTTPHeaders = ["Authorization": "Bearer \(Global.Constants.Token)"]
                
              let headers = [
                    "Authorization": "Bearer \(Global.Constants.Token)!)",
                    "Content-Type": "application/json"
                ]
                
                Alamofire.request(getMentionCount, method: .post, parameters: params, encoding: JSONEncoding.default, headers: Utility.getHeader()).rx.responseJSON()
                     .map{ channelMembers in
                         return channelMembers
                     }
                     .filter{ originResp in
                         let orgResp = originResp as! NSDictionary
                       // self.presenter?.saveMessageToDB(lastPost: orgResp)
                         var resp: Bool = true
                         if let status_code = orgResp["status_code"]{
                             resp = false
                             if status_code as! Int64 == 401{
print("401error")

                             }
                         }
                         else{
                             resp = true
                         }
                         return resp
                     }
                     .flatMap{ membersResp -> Observable<Any> in
                         if let msgDictionary = membersResp as? NSDictionary{
                             self.msgDictionary = msgDictionary
                         }
                         return Observable.just(self.msgDictionary )
                     }
                     .subscribe(onNext: { item in
                     },
                                onError: { error in
                                 self.posting = false
                                 self.state = true
                     },
                                onCompleted: {
                                 self.posting = false
                                 if self.msgDictionary.count != 0{
                                    
                                 //   print("msgDictionary\(self.msgDictionary)")
                                     self.updateMessageEntity(messageId: messageId, msgDictionary: self.msgDictionary, Completion: { (success) in
                                         if success{
                                             self.updateChannelEntity(channelId: channelID, Completion: { (success) in
                                                 if success{
                                                     if self.mesageQueue.count > 0{
                                                         if self.mesageQueue.contains(message){
                                                             self.state = false
                                                             self.postSuccess = true
                                                         }else{
                                                             self.state = true
                                                         }
                                                     }
                                                 }
                                             })
                                         }else{
                                             if self.mesageQueue.count > 0{
                                                 self.state = true
                                             }
                                         }
                                     })
                                 }
                     }).disposed(by: self.disposeBag)
             }
             else{
                 state = false
             }
         }
     }
     
     func updateMessageEntity(messageId : String, msgDictionary : NSDictionary , Completion : (Bool) ->()){
         let searchPredicate:NSPredicate = NSPredicate(format:"messageId == %@",messageId)
         let mData = persistanceService.fetchEntities("Messages", withPredicate: [searchPredicate], sortkey: nil, order: nil, limit: nil)
         if mData.count != 0, let msgVal = mData[0] as? Messages{
             msgVal.messageId = msgDictionary["id"] as? String
             msgVal.messageStatus = 2
             persistanceService.saveContext()
             Completion(true)
         }else{
             Completion(false)
         }
     }
     
     func  updateChannelEntity(channelId : String, Completion : (Bool) ->()){
         let chanlPredicate:NSPredicate = NSPredicate(format:"id == %@",channelId)
         let cData = persistanceService.fetchEntities("Channel", withPredicate: [chanlPredicate], sortkey: nil, order: nil, limit: nil)
         if cData.count != 0, let cnlVal = cData[0] as? Channel{
             cnlVal.chanelMesageStatus = 3
             persistanceService.saveContext()
             Completion(true)
         }else{
             Completion(false)
         }
     }

     deinit {
         //NotificationCenter.default.removeObserver(self, name: Notification.Name.networkChanged, object: nil)

     }
}
