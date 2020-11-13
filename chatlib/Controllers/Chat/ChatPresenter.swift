//
//  ChatPresenter.swift
//  Chat
//
//  Created by Asha Treesa Kurian on 30/09/20.
//  Copyright © 2020 fingent. All rights reserved.
//

import UIKit
import CoreData
import Alamofire
import AlamofireImage
import RxSwift
import NotificationCenter

class ChatPresenter : NSObject{
     var disposeBag = DisposeBag()
        var presenter: DataPresenter!
       // var myID: String? = ""
        var finalChanels: NSMutableArray = []
        var channelArray: NSArray = []
        var newGroupChanel: NSDictionary!
        var getLatPostMsgs: Int64 = 0
        var mentionC: Int64 = 0
        
        override init(){
            super.init()
            self.presenter = DataPresenter()
    //        if let myID = UserDefaults.standard.string(forKey: "mattermost_user_id") {
    //            self.myID = myID
    //        }
        }
        
        public final  class var chatPresenter : ChatPresenter {
            struct Static {
                static var instance : ChatPresenter?
            }
            if !(Static.instance != nil) {
                Static.instance = ChatPresenter()
            }
            return Static.instance!
        }
        func clearMentionCountAPI(with channelId: String){
            let params = [
                "channel_id": channelId
            ]
            let getMentionCount = Global.ServiceUrls.baseURL + Global.ServiceUrls.mattermostmembers
            let clearMentionC = getMentionCount+Utility.getmattermostUserId()+"/view"
            
            Alamofire.request(clearMentionC, method: .post, parameters: params, encoding: JSONEncoding.default, headers: Utility.getHeader()).rx.responseJSON()
                .map{ result in
                    return result
            }
        }
     func getFullName(userid : String)-> String{
           let searchPredicate:NSPredicate = NSPredicate(format:"userId == %@",userid)
           let postList = persistanceService.fetchEntities("Channel", withPredicate: [searchPredicate], sortkey: nil, order: nil, limit: nil)
           
           if postList.count != 0{
               if let postInfo = postList[0] as? Channel{
                   if let fName = postInfo.displayName{
                      return fName
                   }
                   
               }
           }
           return ""
       }
   func updateChannelPreferenceInDBandAPI(userId: String){
             let params =
                 [
                     "user_id":Utility.getmattermostUserId(),
                     "category":"direct_channel_show",
                     "name":userId,
                     "value":"true"
                     ] as! [String : String]
            // print("paramsparams\(params)")
          let headers: HTTPHeaders = ["Authorization": "Bearer \(Global.Constants.Token)"]

          let getPref = Global.ServiceUrls.baseURL + Global.ServiceUrls.mattermostGetUsers
             let getAllPref = getPref+Utility.getmattermostUserId()+"/preferences"
            // print("getAllPref\(getAllPref)")
          
             Alamofire.request(getAllPref, method: .get, parameters: params, encoding: JSONEncoding.default, headers: Utility.getHeader()).rx.responseJSON()
          
         }
    func updateChatTabCount(){
        var chatCount : Int64 = 0
        let searchPredicate1 = NSPredicate(format:"mentioncount != %d" , 0)
        //let searchPredicate2 = NSPredicate(format: "isShow == %@", NSNumber(booleanLiteral: true))
        let postList = persistanceService.fetchEntities("Channel", withPredicate: [searchPredicate1], sortkey: nil, order: nil, limit: nil)
        if postList.count != 0 {
            do{
                postList.forEach(){ channel in
                    let  singChanel = channel as? Channel
                    chatCount = chatCount + (singChanel?.mentioncount)!
                }
                print(chatCount)
               // UnreadChatsCountManager.countInstance.unreadCount = chatCount
            }
            catch let error {
                print("ERROR DELETING : \(error)")
            }
        }else{
             //UnreadChatsCountManager.countInstance.unreadCount = 0
        }
    }
    func getMessagesBefore(messageID : String, pageCount : Int, displayName : String, channelid : String){
            let queue = DispatchQueue(label: "", qos: .background, attributes: .concurrent)
            queue.async {
                
            
                self.getMessagesofChannelBefore(with: channelid, with: messageID, with: pageCount)
                .map{ messageDetail in
                    return messageDetail
                }
                .filter{ memResp in
                    var resp: Bool = true
                    let orgResp = memResp as! NSDictionary
                   // print("orgRespval\(orgResp)\(memResp)")

                    if let statusCode = orgResp["status_code"]{
                        resp = false
                        if statusCode as! Int64 == 401{
                            print("401error")
                        }
                    }
                    else{
                        resp = true
                    }
                    return resp
                }
                .flatMap{ messageResponse -> Observable<Any> in
                    if let myDictionary = messageResponse as? NSDictionary{
                        if let orders = myDictionary["order"] as? [String]{
                            //appDelegate.onBeforeMsgCall = true
                            if orders.count == 0{
                            }
                            self.presenter.parseMessageObject(messageResponse: myDictionary, orders: orders, channelDisplayName: displayName)
                        }
                    }
                    return Observable.just(messageResponse)
                }
                .subscribe(onNext: { item in
                },
                           onError: { error in
                            print(error)
                            //appDelegate.onBeforeMsgCall = false
                            
                },
                           onCompleted: {
                            //appDelegate.onBeforeMsgCall = false
                            DispatchQueue.main.async {
                                print("Before Messages API end")
                            }
                            
                }).disposed(by: self.disposeBag)
        }
        }
    
     func getMessagesofChannelBefore(with channelid: String, with messageId: String , with pageCount : Int) -> Observable<Any>{
           let getMsg = Global.ServiceUrls.baseURL + Global.ServiceUrls.mattermostchannelMsgs
        let headers: HTTPHeaders = ["Authorization": "Bearer \(Global.Constants.Token)"]
             let getAllMsgs = getMsg + channelid + "/posts?before="+messageId+"&per_page="+String(pageCount)
             return Alamofire.request(getAllMsgs, headers: Utility.getHeader()).rx.responseJSON()
         }
    func getMessagesAfter(messageID : String, pageCount : Int, displayName : String, channelid : String){
        self.getMessagesofChannelAfter(with: channelid , with: messageID, with: pageCount)
                .map{ messageDetail in
                    return messageDetail
                }
                .filter{ memResp in
                    var resp: Bool = true
                    let orgResp = memResp as! NSDictionary
                    if let statusCode = orgResp["status_code"]{
                        resp = false
                        if statusCode as! Int64 == 401{
    print("401error")

                        }
                    }
                    else{
                        resp = true
                    }
                    return resp
                }
                .flatMap{ messageResponse -> Observable<Any> in
                    if let myDictionary = messageResponse as? NSDictionary{
                        if let orders = myDictionary["order"] as? [String]{
                            //appDelegate.onAfterMsgCall = true
                            self.presenter.parseMessageObject(messageResponse: myDictionary, orders: orders, channelDisplayName: displayName)
                        }
                    }
                    return Observable.just(messageResponse)
                }
                .subscribe(onNext: { item in
                },
                           onError: { error in
                            print(error)
                          //  appDelegate.onAfterMsgCall = false
                },
                           onCompleted: {
                           // appDelegate.onAfterMsgCall = false
                            print("After Messages API end")
                }).disposed(by: disposeBag)
        }
        //MARK:- Get Messages of channel after last messageid
          func getMessagesofChannelAfter(with channelId: String, with messageId: String , with pageCount : Int) -> Observable<Any>{
              let chanelId = channelId as String
            let getMsg = Global.ServiceUrls.baseURL + Global.ServiceUrls.mattermostchannelMsgs
             let headers: HTTPHeaders = ["Authorization": "Bearer \(Global.Constants.Token)"]
              let getAllMsgs = getMsg + chanelId + "/posts?after="+messageId+"&per_page="+String(pageCount)
              return Alamofire.request(getAllMsgs, headers: Utility.getHeader()).rx.responseJSON()
          }
    
    //MARK:-check unpost attachmentmsgs
       func checkUnpostAttachments(id : String , message : NSDictionary, Completion : (Bool)-> ()) {
            let searchPredicate = NSPredicate(format:"messageId == %@",id)
            let mesageData = persistanceService.fetchEntities("Messages", withPredicate: [searchPredicate], sortkey: nil, order: nil, limit: nil) as! [Messages]
            if mesageData.count != 0{
                if let msgVal = mesageData[0] as? Messages{
                //Check whether message is posted in server or not
                   msgVal.messageId = message.value(forKey: "id") as? String
                    msgVal.file_ids = message.value(forKey: "file_ids") as? [String]
                    msgVal.file_names =  message.value(forKey: "filenames") as? [String]
                    msgVal.filestatus = Global.ATTACHMENT_STATUS.UPLOADED.rawValue
                   var fileURL : String? = nil
                   if msgVal.file_names?[0].suffix(4) == ".jpg"{
                       fileURL = "\(msgVal.channelId!)/Upload/\(msgVal.file_ids![0]).jpg"
                   }
                   else if msgVal.file_names?[0].suffix(4) == ".gif"{
                    fileURL = "\(msgVal.channelId)/Upload/\(msgVal.file_ids?[0]).gif"
                   }
                   msgVal.filepath = [fileURL] as? [String]
                   msgVal.messageStatus = 2
                   persistanceService.saveContext()
                   self.presenter.updateLastMsgStatus(channelid: (message.value(forKey: "channel_id") as? String)!, msgDict: message)
//                   if ImageUploadManager.imageInstance.imageUploadQueue.contains(msgVal){
//                       if let index = ImageUploadManager.imageInstance.imageUploadQueue.index(of: msgVal) {
//                           ImageUploadManager.imageInstance.imageUploadQueue.remove(at: index)
//                       }
//                   }
                   Completion(true)
               }
            }else{
               Completion(false)
           }
        }
       
       //MARK:-check unpost text msgs
       func checkUnpostTextMsgs(id : String , message : NSDictionary, Completion : (Bool)-> ()) {
           let searchPredicate = NSPredicate(format:"messageId == %@",id)
           let mesageData = persistanceService.fetchEntities("Messages", withPredicate: [searchPredicate], sortkey: nil, order: nil, limit: nil) as! [Messages]
           if mesageData.count != 0{
               if let msgVal = mesageData[0] as? Messages{
                  // let msg = Message(context: CoreDataStack.sharedInstance.persistentContainer.viewContext)
                   
                   //Check whether message is posted in server or not
                   msgVal.messageId = message.value(forKey: "id") as? String
                   msgVal.messageStatus = 2
                   persistanceService.saveContext()
                   self.presenter.updateLastMsgStatus(channelid: (message.value(forKey: "channel_id") as? String)!, msgDict: message)
//                   if PostManager.postInstance.mesageQueue.contains(msgVal){
//                       if let index = PostManager.postInstance.mesageQueue.index(of: msgVal) {
//                           PostManager.postInstance.mesageQueue.remove(at: index)
//                       }
//                   }
                   Completion(true)
               }
           }else{
               Completion(false)
           }
       }
       
}
