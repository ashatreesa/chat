

import UIKit
import CoreData
import Alamofire
import AlamofireImage
import RxSwift
import NotificationCenter

public class AuthPresenter : NSObject{
   
    var disposeBag = DisposeBag()
    var presenter: DataPresenter!
   // var myID: String? = ""
    var finalChanels: NSMutableArray = []
    var channelArray: NSArray = []
    var newGroupChanel: NSDictionary!
    var getLatPostMsgs: Int64 = 0
    var mentionC: Int64 = 0
    var utility :Utility!
    public override init(){
        super.init()
        self.presenter = DataPresenter()
        utility = Utility()
//        if let myID = UserDefaults.standard.string(forKey: "mattermost_user_id") {
//            self.myID = myID
//        }
    }
    
    
     func getUserImage(imageURL : String , userId : String, Completion : @escaping (Bool,UIImage?) -> ()){
         var userImage: UIImage?
         var imageFetchUrl: String = ""
         if let employeeImageUrl = imageURL as? String{
            imageFetchUrl = Global.ServiceUrls.baseURL+"users/"+userId+"/image"
            //print("employeeImageUrl\(employeeImageUrl)==\(imageFetchUrl)")
             var urlRequest = URLRequest(url: URL(string: imageFetchUrl)!)
            
            if let token =  UserDefaults.standard.string(forKey: "mattermost_token")
            {
                //print("tokensset\(token)")
            urlRequest.setValue("Bearer "+token, forHTTPHeaderField: "Authorization")
            }
            //print("urlRequesturlRequest\(urlRequest)==\(userId)==\(UserDefaults.standard.string(forKey: "mattermost_token"))")
             if !ReachabilityManager.isInternetAvailable(){
                 urlRequest.cachePolicy = .returnCacheDataDontLoad
              
             }else{
                 urlRequest.cachePolicy = .returnCacheDataElseLoad
             }
             let queue = DispatchQueue(label: "ghhh", qos: .background, attributes: .concurrent)
            
            
          
           // Alamofire.request(imageFetchUrl,headers:headers ).responseImage { response in
            Alamofire.request(urlRequest).responseImage(imageScale: 1.0, inflateResponseImage: true, queue: queue, completionHandler: { response in
               // print("response==\(response)")
                 guard let image = response.result.value else {
                     // Handle error
                     print("Error while fetching profile image")
                     return
                 }
                 userImage = image
                let data = image.pngData()
                self.presenter.getImageFromDirectory(userID: userId) { (success, savedImage) in
                    if let savedData = savedImage.pngData(){
                         if !(data?.elementsEqual(savedData))!{
                             // print("New Image of user")
                              self.writeProfileImageToDirectory(userID: userId, profileImage: userImage!, CompletionHandler: { (success) in
                                  if success{
                                     Completion(true,userImage)
                                  }else{
                                     print("Same image exists ")
                                     Completion(true,userImage)
                                  }
                              })
                          }else{
                             print("Same image exists")
                             Completion(true,userImage)
                          }
                     }
                 }
             })
         }
     }
     
        func writeProfileImageToDirectory(userID : String, profileImage : UIImage, CompletionHandler : (Bool)-> ()){
            let profileThumbURL = utility.createFolder(folderName: "ProfileThumb/")!.appendingPathComponent("/\(userID).jpg")
            let data = profileImage.pngData()
            do {
                try data!.write(to: profileThumbURL)
                CompletionHandler(true)
            }
            catch {
                print("Error \(error)")
                CompletionHandler(false)
            }
        }
    func channelsUpdate(){
        // self.myID  = UserDefaults.standard.string(forKey: "mattermost_user_id")
         self.finalChanels = []
         if ReachabilityManager.isInternetAvailable(){
             getChats()
                 .throttle(0.1, scheduler: MainScheduler.instance)
                 .map{ origin in
                     return origin
                 }
                 .filter{ originResp in
                     //print("originResppagr2\(originResp)")
                     var resp: Bool = true
                     if originResp as? String  == "empty"{
                         resp = false
                     }
                     else{
                         resp = true
                     }
                     return resp
                 }
                 .filter{ originResp in
                     var resp: Bool = true
                     if let orgResp = originResp as? NSDictionary{
                     if let statusCode = orgResp["status_code"]{
                         resp = false
                      }
                       else{
                          resp = true
                       }
                     }
                      return resp
                    }
                 .flatMap{ value -> Observable<Any> in
                     if let nsArr = value as? NSArray{
                         self.channelArray = nsArr.sortedArray(using: [NSSortDescriptor(key: "last_post_at", ascending: true)]) as NSArray
                         print(self.channelArray)
                     }
                     return Observable.from(self.channelArray)
                 }
                 .flatMap{ y -> Observable<Any> in
                     return Observable.just(y)
                 }
                 .filter{ itemFilter in
                     var change: Bool = true
                     let filterVal = itemFilter as? NSDictionary
                     let chanIDFilter = filterVal!["id"] as? String
                     let searchPredicate:NSPredicate = NSPredicate(format:"id == %@",chanIDFilter!)
                     let postList = persistanceService.fetchEntities("Channel", withPredicate: [searchPredicate], sortkey: nil, order: nil, limit: nil)
                     if postList.count != 0{
                         if let postInfo = postList[0] as? Channel{
                             if filterVal!["last_post_at"] as! Int64 == postInfo.lastPost{
                                 change = false
                             }
                             else{
                                 change = true
                             }
                         }
                     }
                     else{
                         change = true
                     }
                     return change
                 }
                 
                 .filter{ itemS in
                     var resp: Bool = true
                     let singleItem = itemS as? NSDictionary
                     if singleItem!["type"] as? String != "G" && singleItem!["type"] as? String != "O"{
                         resp = true
                     }
                     else{
                         resp = false
                     }
                     return resp
                 }
                 
                 .flatMap{ originval -> Observable<Any> in
                     let singItem = originval as? NSDictionary
                     let chanIDFilter = singItem!["id"] as? String
                     let searchPredicate:NSPredicate = NSPredicate(format:"channelId == %@",chanIDFilter!)
                     let postList = persistanceService.fetchEntities("Channel", withPredicate: [searchPredicate], sortkey: nil, order: nil, limit: nil)
                     if postList.count != 0{
                         return Observable.just(originval)
                     }
                     else{
                         if singItem!["type"] as? String == "D"{
                                 return self.getDisplayName(with: originval as! NSDictionary)
                             }
                             else{
                                 return Observable.just(originval)
                             }
                        // return self.getDisplayName(with: originval as! NSDictionary)
                     }
                 }
                 .flatMap{ valueResp -> Observable<Any> in
                     print(valueResp)
                     let value = valueResp as? NSDictionary
                     return self.getMessagesofChannel(with: valueResp as! NSDictionary)
                 }
                 .filter{ channelVal in
                     var resp: Bool = true
                     let singleItem = channelVal as? NSDictionary
                     if singleItem!["message"] as? String != ""{
                         resp = true
                     }
                     else{
                         resp = false
                     }
                     return resp
                 }
                 .flatMap{ orignVal -> Observable<Any> in
                     return self.getMembers(with: orignVal as! NSDictionary)
                 }
                 .flatMap{ pref -> Observable<Any> in
                     let prefItem = pref as! NSDictionary
                     let updatedDictVal = prefItem.mutableCopy() as! NSMutableDictionary
                     updatedDictVal["channelStatus"] = true
                     updatedDictVal["isChannelMember"] = true
                     return Observable.just(updatedDictVal)
                 }
                 .flatMap{ channelOutput -> Observable<Any> in
                     let chanelDict = channelOutput as! NSDictionary
                     if !self.finalChanels.contains(channelOutput){
                         self.finalChanels.add(channelOutput)
                     }
                     return Observable.just(self.finalChanels)
                 }
                 .observeOn(MainScheduler.instance)
                 .subscribe(onNext: { item in
                 },
                            onError: { error in
                             print(error)
                             self.channelsUpdate()
                 },
                onCompleted: {
                 for chanl in self.finalChanels{
                    print("finalChanels1\(self.finalChanels)")
                     let chanelObj = chanl as? NSDictionary
                     self.newGroupChanel = chanl as? NSDictionary
                     let chanIDFilter = chanelObj!["id"] as? String
                     let searchPredicate:NSPredicate = NSPredicate(format:"id == %@",chanIDFilter!)
                     let postList = persistanceService.fetchEntities("Channel", withPredicate: [searchPredicate], sortkey: nil, order: nil, limit: nil)
                     if postList.count != 0{
                         if let postInfo = postList[0] as? Channel{
                             postInfo.lastPost = chanelObj!["last_post_at"] as! Int64
                             let currCount = chanelObj!["mention_count"] as! Int64
                             
                             if postInfo.type == "P"{
                                 postInfo.displayName = chanelObj!["display_name"] as? String
                                 postInfo.messageCount += chanelObj!["mention_count"] as! Int16
                             }else{
                                 postInfo.messageCount = chanelObj!["mention_count"] as! Int16
                             }

                             postInfo.isShow = true
                             persistanceService.saveContext()
                         }
                     }
                     else{
                         if chanelObj!["type"] as? String == "P"{
                             let updatedDictVal = chanelObj?.mutableCopy() as! NSMutableDictionary
                             updatedDictVal.setValue(1, forKey: "mention_count")
                             self.newGroupChanel = updatedDictVal
                         }
                         self.presenter.createChannelEntityFrom(dictionary: self.newGroupChanel as! [String : AnyObject])
                     }
                     let finCount = chanelObj!["mention_count"] as! Int64
                    self.updateChatTabCount()
                 }
                 if PostManager.postInstance.mesageQueue.count > 0, !PostManager.postInstance.posting {
                     PostManager.postInstance.state = true
                 }else{
                     PostManager.postInstance.state = false
                 }
                 self.getUnpostMesages()
             }
                 ).disposed(by: disposeBag)
         }
         else{
             print("Network Error")
         }
     }
    func getUnpostMesages() {
           let searchPredicate = NSPredicate(format: "messageId contains[c] %@", "temp")
           let mesageData = persistanceService.fetchEntities("Messages", withPredicate: [searchPredicate], sortkey: nil, order: nil, limit: nil) as! [Messages]
           if mesageData.count > 0{
               for msg in mesageData{
                   if !PostManager.postInstance.mesageQueue.contains(msg){
                       PostManager.postInstance.addMessageToQueue(messageEntity: msg)
                   }
               }
           }
           /*if mesageData.count > 0{
               //PostManager.postInstance.mesageQueue.contains(mesageData[i])
               PostManager.postInstance.addMessagesToQueue(messagesEntity: mesageData)
           }*/
       }
    func getNameFromChannel(channelResponse : NSDictionary)->String{
        var userid : String?
        let dispName = channelResponse["display_name"] as! String
        let name = channelResponse["name"] as! String
        let fullNameArr = name.components(separatedBy: "__")
        if fullNameArr[0] == Utility.getmattermostUserId(){
            userid = fullNameArr[1]
        }
        else{
            userid = fullNameArr[0]
        }
//        if dispName == ""{
//            return getFullName(userid: userid!)
//        }
//        else{
            return dispName
       // }
    }
     func getMessagesofChannel(with channelVal: NSDictionary) -> Observable<Any>{
        var messageId : String?
        var lstPostMsgId : Int64!
        var channelDisplayName : String?
        
        let chanelId = channelVal["id"] as! String
        channelDisplayName = getNameFromChannel(channelResponse: channelVal)
        
        let searchPredicate:NSPredicate = NSPredicate(format:"id == %@",chanelId)
        let postList = persistanceService.fetchEntities("Channel", withPredicate: [searchPredicate], sortkey: nil, order: nil, limit: nil)
        if postList.count != 0, let postInfo = postList[0] as? Channel{
            lstPostMsgId = postInfo.lastPost
            let chanelPred = NSPredicate(format:"channelId == %@",chanelId)
            let msgPredicate = NSPredicate(format: "NOT messageId BEGINSWITH 'temp'")
            let fileMessagePredicate = NSPredicate(format: "NOT messageId BEGINSWITH 'attachment'")
            let msgPred = NSCompoundPredicate(type: .and, subpredicates: [chanelPred, msgPredicate, fileMessagePredicate])
            var serchPred     : NSPredicate?
            serchPred = msgPred
            let msgData = persistanceService.fetchEntities("Messages", withPredicate: [serchPred!], sortkey: nil, order: nil, limit: nil)
            if msgData.count != 0{
                let count = msgData.count
                if let msg = msgData[count - 1] as? Messages{
                    messageId = msg.messageId
                }
            }
        }
        
        let getMsgId : String?
        if messageId == nil{
            getMsgId = "/posts"
        }
        else{
            getMsgId = "/posts?after="+messageId!
        }
        let getMsg = Global.ServiceUrls.baseURL + Global.ServiceUrls.mattermostchannelMsgs
        let getAllMsgs = getMsg + chanelId + getMsgId!
        return Alamofire.request(getAllMsgs, method: .get, parameters: nil, encoding: URLEncoding.default, headers: Utility.getHeader()).rx.responseJSON()
            .map{ msg in
                return msg
            }
            .filter{ originResp in
                var resp: Bool = true
                if let orgResp = originResp as? NSDictionary{
                    if let statusCode = orgResp["status_code"]{
                        resp = false
                        if statusCode as! Int64 == 401{
print("401error")

                        }
                    }
                    else{
                        resp = true
                    }
                }
                return resp
            }
            .flatMap{ msgResponse -> Observable<Any> in
                let myDictionary = msgResponse as! NSDictionary
                let orders = (myDictionary["order"] as? [String]) ?? []
                let reversedOrders : [String] = Array(orders.reversed())
                var lastmsg : String = ""
                var typeMsg : Int16 = 0
                self.getLatPostMsgs = Int64(orders.count)
                if orders.count != 0{
                    let lastOrder = orders[0]
                    let posts = myDictionary["posts"] as? NSDictionary
                    if let lastPost = posts?.value(forKey: lastOrder) as? NSDictionary{
                        let type = lastPost["type"] as? String
                        if  type == "system_header_change"{
                            if let callUserID = lastPost.value(forKey: "user_id") as? String{
                                let myID = Utility.getmattermostUserId()
                                if !(channelDisplayName?.isEmpty)!{
                                    if myID == callUserID{
                                        lastmsg = "You initiated a call to " + channelDisplayName!
                                    }
                                    else{
                                        lastmsg = "Call from " + channelDisplayName!
                                    }
                                    typeMsg = 0
                                }
                            }
                        }
                        else if type != "system_purpose_change"{
                            self.presenter.saveSystemMessages(msgDict: lastPost as NSDictionary, Completion: { (success, msgDictionary) in
                                lastmsg = (msgDictionary["message"] as? String)!
                                if lastmsg.isEmpty{
                                    if let fileIDs = msgDictionary["file_ids"] as? NSArray{
                                        if fileIDs.count > 0{
                                            let isGif : String = msgDictionary["filenames"]!.object(at: 0) as! String
                                            if(isGif.suffix(4) == ".gif"){
                                                lastmsg = "GIF"
                                            }
                                            else{
                                                lastmsg = "Photo"
                                            }
                                        }
                                    }
                                }
                            })
                        }
                    }
                    self.presenter.parseMessageObject(messageResponse: myDictionary, orders: reversedOrders, channelDisplayName : channelDisplayName!)
                }
                else{
                    let searchPredicate:NSPredicate = NSPredicate(format:"id == %@",chanelId)
                    let postList = persistanceService.fetchEntities("Channel", withPredicate: [searchPredicate], sortkey: nil, order: nil, limit: nil)
                    if postList.count != 0{
                        if let postInfo = postList[0] as? Channel{
                            if let lastMsg = postInfo.lastMessage{
                                lastmsg = lastMsg
                                typeMsg = postInfo.chanelMesageStatus
                            }
                        }
                    }
                }
                let updatedDictVal = channelVal.mutableCopy() as! NSMutableDictionary
                if let userid = updatedDictVal["userId"] as? String, userid == Utility.getmattermostUserId(){
                    updatedDictVal["message_stat"] = 3
                }else{
                    updatedDictVal["message_stat"] = typeMsg
                }
                
                updatedDictVal["message"] = lastmsg
                updatedDictVal["mention_count"] = orders.count
                return Observable.just(updatedDictVal)
        }
    }
    func getDisplayName(with origin: NSDictionary) -> Observable<Any> {
           // Other api call using origin
           let name = origin["name"] as? String
           let fullNameArr = name?.components(separatedBy: "__")
           let userId: String!
           if fullNameArr![0] == Utility.getmattermostUserId() {
               userId = fullNameArr![1]
           }
           else{
               userId = fullNameArr![0]
           }
        let getuser = Global.ServiceUrls.baseURL+Global.ServiceUrls.mattermostGetUsers
          
           let getAllUsers = getuser + userId
           return Alamofire.request(getAllUsers,headers: Utility.getHeader()).rx.responseJSON()
               .map { secondResponse in
                   return secondResponse
               }
               .filter{ originResp in
                   var resp: Bool = true
                   if let orgResp = originResp as? NSDictionary{
                       if let statusCode = orgResp["status_code"]{
                           resp = false
                           if statusCode as! Int64 == 401{
print("401error")

                           }
                       }
                       else{
                           resp = true
                       }
                   }
                   return resp
               }
               .flatMap{ userResp -> Observable<Any> in
                   let userlist = userResp as! NSDictionary
                   let updateUSer = userlist.mutableCopy() as! NSMutableDictionary
                   updateUSer["userStatus"] = "offline"
                   if userlist["id"] as? String != Utility.getmattermostUserId(){
                       self.presenter.createUserEntityFrom(dictionary: updateUSer as! [String : AnyObject])
                       self.presenter.createEmployeeEntityFromMattermost(dictionary: updateUSer as! [String : AnyObject])
                   }
                   return Observable.just(userResp)
                   
               }
               .flatMap{ val -> Observable<Any> in
                   let json = val as? [String: Any] ?? [:]
                   let updatedDictVal = origin.mutableCopy() as! NSMutableDictionary
                   
                   
                   let fname = json["first_name"] as? String
                   let lname = json["last_name"] as? String
                   let emaill = json["email"] as? String
                   if fname != nil && lname != nil{
                       let finalName = fname!+" "+lname!
                       updatedDictVal["email"] = emaill
                       updatedDictVal.setValue(finalName, forKey: "display_name")
                   updatedDictVal["userId"] = userId
                   }
                   
                   return Observable.just(updatedDictVal)
           }
       }
    
    
    func updateChatTabCount(){
          var chatCount : Int16 = 0
          let searchPredicate1 = NSPredicate(format:"messageCount != %d" , 0)
          let searchPredicate2 = NSPredicate(format: "isShow == %@", NSNumber(booleanLiteral: true))
          let postList = persistanceService.fetchEntities("Channel", withPredicate: [searchPredicate1,searchPredicate2], sortkey: nil, order: nil, limit: nil)
          if postList.count != 0 {
              do{
                  postList.forEach(){ channel in
                      let  singChanel = channel as? Channel
                      chatCount = chatCount + (singChanel?.messageCount)!
                  }
                  print(chatCount)
                 // UnreadChatsCountManager.countInstance.unreadCount = chatCount
              }
              catch let error {
                  print("ERROR  : \(error)")
              }
          }else{
               //UnreadChatsCountManager.countInstance.unreadCount = 0
          }
      }
    func getChats() -> Observable<Any>{
        if let teamId = UserDefaults.standard.string(forKey: "mattermost_team_id"){
            let getAllChannels =  Global.ServiceUrls.baseURL+Global.ServiceUrls.mattermostGetteamMsg + teamId + "/channels"
           
            return Alamofire.request(getAllChannels, headers: Utility.getHeader()).rx.responseJSON()
        }
        return Observable.just("empty")
    
    
}
    
    func getMembers(with origin: NSDictionary) -> Observable<Any> {
        let name = origin["name"] as? String
        let channelId = origin["id"] as? String
        let getMembrs = Global.ServiceUrls.baseURL +  Global.ServiceUrls.mattermostchannelMsgs
        let getAllMembers = getMembrs+channelId!+"/members"
        return Alamofire.request(getAllMembers,headers: Utility.getHeader()).rx.responseJSON()
            .map { secondResponse in
                return secondResponse
            }
            .filter{ originResp in
                var resp: Bool = true
                if let orgResp = originResp as? NSDictionary{
                    if let statusCode = orgResp["status_code"]{
                        resp = false
                        if statusCode as! Int64 == 401{
                       print("401error")

                        }
                    }
                    else{
                        resp = true
                    }
                }
                return resp
            }
            .flatMap{ val -> Observable<Any> in
                let membersArr = val as! NSArray
                return Observable.from(membersArr)
            }
            .filter{ itemS in
                var resp: Bool = true
                let singleItem = itemS as? NSDictionary
                if singleItem!["user_id"] as? String == Utility.getmattermostUserId(){
                    resp = true
                }
                else{
                    resp = false
                }
                return resp
            }
            .flatMap{ filterItem -> Observable<Any> in
                print(filterItem)
                let item = filterItem as? NSDictionary
                
                let channelItem = origin as NSDictionary
                let typ = channelItem["type"] as! String
                
                if typ == "D"{
                    var stat: Bool?
                    let searchPredicate:NSPredicate = NSPredicate(format:"id == %@",channelId!)
                    let postList = persistanceService.fetchEntities("Channel", withPredicate: [searchPredicate], sortkey: nil, order: nil, limit: nil) as! NSArray
                    if postList.count != 0{
                        if let postInfo = postList[0] as? Channel{
                            stat =  postInfo.isShow
                            
                        }
                    }
                    self.mentionC = item!["mention_count"] as! Int64
                    let updatedDictVal = origin.mutableCopy() as! NSMutableDictionary
                    //updatedDictVal["mention_count"] = self.mentionC
                    updatedDictVal.setValue(self.mentionC, forKey: "mention_count")
                    // updatedDictVal["channelStatus"] = true
                    return Observable.just(updatedDictVal)
                    
                }
                
               else{
                   let mentnCount = origin["mention_count"] as? Int64
                        let updatedDictVal = origin.mutableCopy() as! NSMutableDictionary
                        updatedDictVal.setValue(mentnCount!, forKey: "mention_count")
                        return Observable.just(updatedDictVal)
                }
        }
    }
}
