//
//  DataPresenter.swift
//  Chat
//
//  Created by Asha Treesa Kurian on 10/09/20.
//  Copyright © 2020 fingent. All rights reserved.
//

import Foundation
import CoreData
import Alamofire
import RxSwift
class DataPresenter: NSObject {
    var lastMsg: String!
      var getLastPOstAt: Int64!
    var messageUserID : String = ""

    func saveUsersToDb(usersArray: NSArray)
    {
        let context = persistanceService.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserList")
        do {
            let objects  = try context.fetch(fetchRequest) as? [NSManagedObject]
            _ = objects.map{$0.map{context.delete($0)}}
          persistanceService.saveContext()
            saveInCoreDataWithUsers(array: usersArray as! [[String : AnyObject]])
        } catch let error {
        }
    }
    
    func saveInCoreDataWithUsers(array: [[String: AnyObject]]) {
        _ = array.map{self.createUserEntityFrom(dictionary: $0)}
        do {
            try persistanceService.persistentContainer.viewContext.save()
        } catch let error {
            print(error)
        }
    }
    
    func createUserEntityFrom(dictionary: [String: AnyObject]) -> NSManagedObject? {

        let context = persistanceService.persistentContainer.viewContext
        if dictionary["username"] != nil{
            var fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "UserList")
            fetchRequest.predicate = NSPredicate(format: "userName = %@", dictionary["username"] as! String)
            
            var results: [NSManagedObject] = []
            
            do {
                results = try context.fetch(fetchRequest)
                print("results..\(results)")
            }
            catch {
                print("error executing fetch request: \(error)")
            }
            
            
            if(results.count == 0)
            {
                 if let deletedTime = dictionary["delete_at"] as? Int64{
                   if deletedTime == 0{
                if let userEntity = NSEntityDescription.insertNewObject(forEntityName: "UserList", into: context)as?UserList{
                   userEntity.id = dictionary["id"] as? String
                    userEntity.userName = dictionary["username"] as? String
                    userEntity.email = dictionary["email"] as? String
                    userEntity.role = dictionary["roles"] as? String
                    userEntity.deletedAt = (dictionary["delete_at"] as? String)
                     userEntity.updatedAt = dictionary["update_at"] as? String
                    //  userEntity.lastActivityAt = dictionary["last_activity_at"] as! Int64
                            //  userEntity.lastActivityAt = dictionary["last_activity_at"] as! Int64
                            return userEntity
                        }
                    }
                    
                }
            }
        }
        return nil
    }
    public func fetchUserListInfo() -> [UserList]? {
            if let userProfileList = persistanceService.fetchEntities("UserList", withPredicate: [],
                sortkey: nil,
                order: nil, limit: nil) as? [UserList]{


                if userProfileList.count > 0 {
                    
                    return userProfileList
                    
                }

            }
            return nil
        }
    
    func saveChannelsToDb(channelsArray: Array<Dictionary<String, Any>>)
      {
          let context = persistanceService.persistentContainer.viewContext
          let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Channel")
          do {
              let objects  = try context.fetch(fetchRequest) as? [NSManagedObject]
              _ = objects.map{$0.map{context.delete($0)}}
             persistanceService.saveContext()
             // self.clearData()
            saveInCoreDataWith(array: channelsArray as [[String : AnyObject]])
          } catch let error {
              print("ERROR DELETING : \(error)")
          }
      }
    
    func saveInCoreDataWith(array: [[String: AnyObject]]) {
        _ = array.map{self.createChannelEntityFrom(dictionary: $0)}
        do {
            try persistanceService.persistentContainer.viewContext.save()
        } catch let error {
            print(error)
        }
    }
    
    
    
     func createChannelEntityFrom(dictionary: [String: AnyObject]) -> NSManagedObject? {
        
       
        if dictionary["display_name"] as? String == ""{
          
        }
        else{
            let context = persistanceService.persistentContainer.viewContext 
            var fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Channel")
            fetchRequest.predicate = NSPredicate(format: "id = %@", dictionary["id"] as! String)
            let currentTime = Int(Date().timeIntervalSince1970 * 1000)
            
           let emailid = (dictionary["email"] as? String)!

            let profileURL = "account/images/user/" + emailid + "/profile-image/250x250.jpg?t=" + String(currentTime)
            var results: [NSManagedObject] = []
            
            do {
                results = try context.fetch(fetchRequest)
                //print("RESULTSVAL\(results)")
            }
            catch {
                print("error while fetch request: \(error)")
            }
            
            if(results.count == 0)
            {
                if let channelEntity = NSEntityDescription.insertNewObject(forEntityName: "Channel", into: context) as? Channel {
                    channelEntity.id = dictionary["id"] as? String
                   if let channelId = dictionary["id"] as? String
                   {
                    Utility.MessageDetails.shared.channelID = channelId

                   // auth.goToMessagesVC(channelId: channelId)
                    
                    }
                    channelEntity.profileimage = (profileURL as? String)!
                    channelEntity.email = (dictionary["email"] as? String)!
                   channelEntity.createdAt = dictionary["create_at"] as! Int64
                    channelEntity.updatedAt = dictionary["update_at"] as! Int64
                    channelEntity.deletedAt = dictionary["delete_at"] as! Int64
                    channelEntity.teamId = dictionary["team_id"] as? String
                    channelEntity.type = dictionary["type"] as? String
                    channelEntity.displayName = dictionary["display_name"] as? String
                    channelEntity.mentioncount = dictionary["mention_count"] as! Int64
                      channelEntity.isChannelMember = dictionary["isChannelMember"] as! Bool
                    channelEntity.name = dictionary["name"] as? String
                    channelEntity.lastMessage = dictionary["message"] as? String

//channelEntity.purpose = dictionary["purpose"] as? String
                    if let userId = dictionary["userId"] as? String
                    {
                        channelEntity.userId = userId

                    }
                    if let lastpos = dictionary["last_post_at"] as? Int64
                    {
                        channelEntity.lastPost = lastpos

                    }
                    if let messageCount = dictionary["total_msg_count"] as? Int16
                    {
                        channelEntity.messageCount = messageCount

                    }
                    if let extraUpdate = dictionary["extra_update_at"] as? Int16
                    {
                        channelEntity.extraUpdate = extraUpdate


                    }
                    if let chanlsta = dictionary["message_stat"] as? Int16
                    {
                        channelEntity.chanelMesageStatus = chanlsta

                    }
                   
                    //persistanceService.saveContext()

                    return channelEntity
                }
            }
  }
        
       return nil
    }
    func getUserImage(imageURL : String , userId : String, Completion : @escaping (Bool,UIImage?) -> ()){
           var userImage: UIImage?
           var imageFetchUrl: String = ""
        if let employeeImageUrl = imageURL as? String , let accessToken = Global.Constants.Token as? String{
            imageFetchUrl = Global.ServiceUrls.baseURL+employeeImageUrl
               var urlRequest = URLRequest(url: URL(string: imageFetchUrl)!)
            urlRequest.setValue("Bearer "+Global.Constants.Token, forHTTPHeaderField: "Authorization")
               if !ReachabilityManager.isInternetAvailable(){
                   urlRequest.cachePolicy = .returnCacheDataDontLoad
               }else{
                   urlRequest.cachePolicy = .returnCacheDataElseLoad
               }
               let queue = DispatchQueue(label: "", qos: .background, attributes: .concurrent)
               Alamofire.request(urlRequest).responseImage(imageScale: 1.0, inflateResponseImage: true, queue: queue, completionHandler: { response in
                   guard let image = response.result.value else {
                       // Handle error
                       print("Error while fetching profile image")
                       return
                   }
                   userImage = image
                let data = image.pngData()
                   self.getImageFromDirectory(userID: userId) { (success, savedImage) in
                    if let savedData = savedImage.pngData(){
                           if !(data?.elementsEqual(savedData))!{
                                print("New Image of user")
//                                self.writeProfileImageToDirectory(userID: userId, profileImage: userImage!, CompletionHandler: { (success) in
//                                    if success{
//                                       Completion(true,userImage)
//                                    }else{
//                                       print("Same image exists for the user in directory")
//                                       Completion(false,savedImage)
//                                    }
//                                })
                            }else{
                               print("Same image exists for the user in directory")
                               Completion(false,savedImage)
                            }
                       }
                   }
               })
           }
       }
//    func writeProfileImageToDirectory(userID : String, profileImage : UIImage, CompletionHandler : (Bool)-> ()){
//        let profileThumbURL = ImageUploadManager.imageInstance.createFolder(folderName: "ProfileThumb/")!.appendingPathComponent("/\(userID).jpg")
//        let data = profileImage.pngData()
//        do {
//            print("Write image")
//            try data!.write(to: profileThumbURL)
//            CompletionHandler(true)
//        }
//        catch {
//            print("Error Writing Image: \(error)")
//            CompletionHandler(false)
//        }
//    }
    func getImageFromDirectory(userID : String, CompletionHandler : (Bool,UIImage)-> ()){
             let filePath = "ProfileThumb/" + userID + ".jpg"
        
           let nsDocumentDirectory = FileManager.SearchPathDirectory.documentDirectory
           let nsUserDomainMask = FileManager.SearchPathDomainMask.userDomainMask
           let paths = NSSearchPathForDirectoriesInDomains(nsDocumentDirectory, nsUserDomainMask, true)
           if let dirPath = paths.first{
               let imageURL = URL(fileURLWithPath: dirPath).appendingPathComponent(filePath)
         //   print("imageURL\(UIImage(contentsOfFile: imageURL.path))")
               if let image = UIImage(contentsOfFile: imageURL.path){
                   CompletionHandler(true,image)
               }else{
                   let userImage = UIImage(named : "pro")
                   CompletionHandler(false,userImage!)

               }
           }
       }
    
    
    
    func getUserImageUrl(mattermostID : String)->String{
      //  print("mattermostID\(mattermostID)")
          let searchPredicate = NSPredicate(format:"userId == %@",mattermostID)
          let predicate = NSCompoundPredicate(type: .or, subpredicates: [searchPredicate])
          let postList = persistanceService.fetchEntities("Channel", withPredicate: [predicate], sortkey: nil, order: nil, limit: nil)
          if postList.count != 0{
              if let postInfo = postList[0] as? Channel{
                  if let employeeImageUrl = postInfo.profileimage {
                      return employeeImageUrl
                  }
              }
          }
          return ""
      }
     func fetchChannelInfo() ->[Channel]? {
       
            if let channelinfo = persistanceService.fetchEntities("Channel", withPredicate: [],
                sortkey: nil,
                order: nil, limit: nil) as? [Channel]{

//print("channelinfo\(channelinfo)")
                return channelinfo
                        
                       
        
                }
        return nil

            }
    
    //MARK:- Create message entity
      func createMessageEntityFrom(dictionary: [String: AnyObject],isPushMessage: Bool,Completion : (Bool) -> ()) {
          let context = persistanceService.persistentContainer.viewContext
          let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Messages")
          fetchRequest.predicate = NSPredicate(format: "messageId = %@", dictionary["id"] as! String)
          var results: [NSManagedObject] = []
          do {
              results = try context.fetch(fetchRequest)
          }
          catch {
              print("error while fetch request: \(error)")
          }
          if(results.count == 0)
          {
              if let messageEntity = NSEntityDescription.insertNewObject(forEntityName: "Messages", into: context) as? Messages {
                 saveMessagesToDB(dictionary: dictionary,isPushMessage: isPushMessage, messageEntity: messageEntity)
              }
              do {
                  try context.save()
                  Completion(true)
              } catch let error {
                  print("Error : \(error)")
              }
          }else{
              if let msgObject = results[0] as? Messages, msgObject.pushmessage{
                  updateMessagesToDB(dictionary: dictionary, messageEntity: msgObject)
                  do {
                      try context.save()
                  }catch{
                      print("coredata saving error")
                  }
              }
              Completion(false)
          }
      }
      
      func saveMessagesToDB(dictionary: [String: AnyObject], isPushMessage : Bool, messageEntity : Messages){
          messageEntity.messageId = dictionary["id"] as? String
          messageEntity.createdAt = dictionary["create_at"] as! Int64
          messageEntity.updatedAt =  dictionary["update_at"] as! Int64
          if let edit_at = dictionary["edit_at"] as? Int64{
              messageEntity.editAt = edit_at
          }
          if let delete_at = dictionary["delete_at"] as? Int64{
              messageEntity.deleteAt = delete_at
          }
          if let is_pinned = dictionary["is_pinned"] as? Bool{
              messageEntity.ispinned = is_pinned
          }
          messageEntity.userId = dictionary["user_id"] as? String
          messageEntity.channelId = dictionary["channel_id"] as? String
          messageEntity.rootId = dictionary["root_id"] as? String
          messageEntity.parentId = dictionary["parent_id"] as? String
          messageEntity.originalId = dictionary["original_id"] as? String
          messageEntity.message = dictionary["message"] as? String
          messageEntity.messageType = dictionary["type"] as? String
          messageEntity.hashtag = dictionary["hashtags"] as? String
          messageEntity.pendingPostId = dictionary["pending_post_id"] as? String
        messageEntity.updateDate = dictionary["updateDate"] as? NSDate as Date?
          messageEntity.messageStatus = dictionary["message_status"] as! Int16
          messageEntity.pushmessage = isPushMessage
        //m//essageEntity.filepath = []
       // messageEntity.filethumbnails = []
          if let fileIDs = dictionary["file_ids"] as? [String]{
              if let fileNames = dictionary["filenames"] as? [String]{
                  if fileIDs.count != 0 {
                    messageEntity.file_ids = fileIDs
                    messageEntity.file_names = fileNames
                      if Utility.getmattermostUserId() != messageEntity.userId{
                        messageEntity.filestatus = Global.ATTACHMENT_STATUS.DOWNLOAD.rawValue
                      }else{
                        messageEntity.filestatus = Global.ATTACHMENT_STATUS.UPLOAD.rawValue
                      }
                  }else{
                    messageEntity.file_ids = []
                    messageEntity.file_names = []
                      messageEntity.filestatus = ""
                  }
              }
          }else{
            messageEntity.file_ids = []
            messageEntity.file_names = []
          }
      }
      
      func updateMessagesToDB(dictionary: [String: AnyObject], messageEntity : Messages){
          if let create_at = dictionary["create_at"] as? Int64{
              messageEntity.createdAt = create_at
          }
          if let update_at = dictionary["update_at"] as? Int64{
              messageEntity.updatedAt = update_at
          }
          if let edit_at = dictionary["edit_at"] as? Int64{
              messageEntity.editAt = edit_at
          }
          if let delete_at = dictionary["delete_at"] as? Int64{
              messageEntity.deleteAt = delete_at
          }
          if let is_pinned = dictionary["is_pinned"] as? Bool{
              messageEntity.ispinned = is_pinned
          }
          messageEntity.rootId = dictionary["root_id"] as? String
          messageEntity.parentId = dictionary["parent_id"] as? String
          messageEntity.originalId = dictionary["original_id"] as? String
          messageEntity.messageType = dictionary["type"] as? String
          messageEntity.hashtag = dictionary["hashtags"] as? String
          messageEntity.pendingPostId = dictionary["pending_post_id"] as? String
        messageEntity.updateDate = dictionary["updateDate"] as? NSDate as Date?
          if let fileIDs = dictionary["file_ids"] as? [String]{
              if let fileNames = dictionary["filenames"] as? [String]{
                  if fileIDs.count != 0 {
                    messageEntity.file_ids = fileIDs
                    messageEntity.file_names = fileNames
                      if messageEntity.filestatus == nil{
                          if Utility.getmattermostUserId() != messageEntity.userId{
                            messageEntity.filestatus = Global.ATTACHMENT_STATUS.DOWNLOAD.rawValue
                          }else{
                            messageEntity.filestatus = Global.ATTACHMENT_STATUS.UPLOAD.rawValue
                          }
                        messageEntity.filepath = []
                        messageEntity.filethumbnails = []
                      }
                  }else{
                    messageEntity.file_ids = []
                    messageEntity.file_names = []
                      messageEntity.filestatus = ""
                  }
              }
          }else{
            messageEntity.file_ids = []
            messageEntity.file_names = []
          }
      }
    
    
    func parseMessageObject(messageResponse : NSDictionary,orders : [String],channelDisplayName : String){
        for order in orders{
            let posts = messageResponse["posts"] as? NSDictionary

            if let lastPost = posts?.value(forKey: order) as? NSDictionary,
                let props = lastPost.value(forKey: "props") as? NSDictionary{

                let type = lastPost["type"] as? String
                if  type == "system_header_change"{
                    if let callEnded = props.value(forKey: "new_header") as? String,
                        (callEnded != "__callended__")  || (callEnded.isEmpty),
                        props.count != 0,
                        let updatedDictVal = lastPost.mutableCopy() as? NSMutableDictionary,
                        let callUserID = lastPost.value(forKey: "user_id") as? String,
                        let myID = Utility.getmattermostUserId() as? String{
                        if myID == callUserID{
                            if !channelDisplayName.isEmpty{
                                updatedDictVal["message"] = "You initiated a call to " + channelDisplayName
                            }
                        }
                        else{
                            if !channelDisplayName.isEmpty{
                                updatedDictVal["message"] = "Call from " + channelDisplayName
                            }
                        }
                        saveMessageToDB(lastPost: updatedDictVal as NSDictionary)
                    }
                }
                else if type != "system_purpose_change"{
                    parseMessageDictionary(props: props, lastPost: lastPost)
                }
            }
        }
    }
    
    func parseMessageDictionary(props : NSDictionary,lastPost : NSDictionary ){
          if props.count > 0{
              if let id = props["id"] as? String{
                  if id.contains("attachment"){
                      ChatPresenter.chatPresenter.checkUnpostAttachments(id: id, message: lastPost, Completion: { (success) in
                          if !success{
                              saveMessageToDB(lastPost: lastPost)
                          }
                      })
                  }else if id.contains("temp"){
                      ChatPresenter.chatPresenter.checkUnpostTextMsgs(id: id, message: lastPost, Completion: { (success) in
                          if !success{
                              saveMessageToDB(lastPost: lastPost)
                          }
                      })
                  }
              }else{
                  saveMessageToDB(lastPost: lastPost)
              }
          }else{
              saveMessageToDB(lastPost: lastPost)
          }
      }
     
      func saveMessageToDB(lastPost : NSDictionary){
          self.saveSystemMessages(msgDict: lastPost as NSDictionary, Completion: { (success, msgDictionary) in
              self.createMessageEntityFrom(dictionary: msgDictionary, isPushMessage: false, Completion: { (success) in
                  if success{
                      saveLastMessageToChannel(channelId: msgDictionary["channel_id"] as! String, msgCreateAt: msgDictionary["create_at"] as! Int64)
                  }
              })
              self.saveRecievedMsg(msgDict: msgDictionary as NSDictionary)
          })
      }
    
      func displayTime(timer : Int64) -> Date
      {
          let date1 = Date(timeIntervalSince1970: (TimeInterval(timer/1000)))
          let inputDateFormatter = DateFormatter()
          inputDateFormatter.dateFormat = "dd-MM-yyyy hh:mm:ss Z"
          inputDateFormatter.timeZone = TimeZone(abbreviation: "UTC")
          let theDate1 = inputDateFormatter.string(from: date1)
          
          let inputDate = inputDateFormatter.date(from: theDate1)
          let outPutDateFormatter = DateFormatter()
          outPutDateFormatter.dateFormat = "dd-MM-yyyy 00:00:00 +0000"
          outPutDateFormatter.timeZone = TimeZone(abbreviation: "UTC")
          let noTimeString = outPutDateFormatter.string(from: inputDate!)
          let noTimeDate = outPutDateFormatter.date(from: noTimeString)
          return noTimeDate!
      }
      func saveSystemMessages(msgDict : NSDictionary ,Completion : (Bool,[String: AnyObject]) -> ()){
          let updatedDictVal = msgDict.mutableCopy() as! NSMutableDictionary
          
          updatedDictVal["message_status"] = 0

          if let msgUserID = msgDict["user_id"] as? String{
              self.messageUserID = msgUserID
          }
          if let updateDate = msgDict["update_at"] as? Int64{
              updatedDictVal.setValue(displayTime(timer :updateDate), forKey: "updateDate")
          }
          if let msgType  = msgDict["type"] as? String{
              if let msg = msgDict["message"] as? String{
                  let newChangedMessage = msg.replacingOccurrences(of: "channel", with: "group")
                  if msgType == "system_displayname_change"{
                      let editedNewMessage = newChangedMessage.replacingOccurrences(of: "team", with: "group")
                      updatedDictVal.setValue(getFirstNameUser(firstNameEdit : editedNewMessage), forKey: "message")
                  }
                  else if msgType == "system_add_to_channel"{
                      updatedDictVal.setValue(getNameSecUser(msgToEdit : newChangedMessage), forKey: "message")
                  }
                  else if msgType == "system_remove_from_channel"{
                      let editedNewMessage = newChangedMessage.replacingOccurrences(of: "team", with: "group")
                      updatedDictVal.setValue(getFirstNameUser(firstNameEdit : editedNewMessage), forKey: "message")
                  }
                  else if msgType == "system_join_channel"{
                      let editedMessage = newChangedMessage.replacingOccurrences(of: "joined", with: "created")
                      updatedDictVal.setValue(getFirstNameUser(firstNameEdit : editedMessage), forKey: "message")
                  }
                  else if msgType == "system_leave_channel"{
                      updatedDictVal.setValue(getFirstNameUser(firstNameEdit : newChangedMessage), forKey: "message")
                  }
                  else if msgType == ""{
                      let msgUserId = msgDict["user_id"] as? String
                      if Utility.getmattermostUserId() != nil{
                          if msgUserId! == Utility.getmattermostUserId() {
                              updatedDictVal["message_status"] = 2
                          }
                          else{
                              updatedDictVal["message_status"] = 0
                          }
                      }
                  }
                  else{
                      updatedDictVal["message_status"] = 0
                  }
              }
          }
          Completion(true,updatedDictVal as! [String : AnyObject])
      }
       
       func getFirstNameUser(firstNameEdit : String) -> String{
           if let editedName = firstNameEdit.components(separatedBy: " ") as? NSArray{
               let username = editedName[0] as? String
               let fullName = getFullName(username : username!)
               let newmessage = firstNameEdit.replacingOccurrences(of: String(describing: editedName[0]), with: fullName.0 + " " + fullName.1)
               return newmessage
           }
       }
       //MARK:- Get full name of a user
       func getFullName(username : String) -> (String, String){
          // let myID = UserDefaults.standard.string(forKey: "mattermost_user_id")
           let searchPredicate:NSPredicate = NSPredicate(format:"username == %@",username)
           let postList = persistanceService.fetchEntities("Employee", withPredicate: [searchPredicate], sortkey: nil, order: nil, limit: nil)
           if postList.count != 0{
               if let postValue = postList[0] as? Employee{
               // self.firstName = postValue.firstname!
               // self.lastName = postValue.lastname!
               }
           }
           else{
               if let myUsername = UserDefaults.standard.string(forKey: "userName") as? String{
//                   if myUsername != username {
//                       self.firstName =  username
//                       self.lastName  =  ""
//                   }else{
//                       self.firstName =  UserDefaults.standard.string(forKey: "first_name")!
//                       self.lastName  =  UserDefaults.standard.string(forKey: "last_name")!
//                   }
               }
           }
           return ("", "")//( self.firstName ,  self.lastName)
       }
       func getNameSecUser(msgToEdit : String) -> String{
           if let editedName = msgToEdit.components(separatedBy: " ") as? NSArray{
               let username1 = editedName[0] as? String
               let fullName1 = getFullName(username : username1!)
               let newmessage1 = msgToEdit.replacingOccurrences(of: String(describing: editedName[0]), with: fullName1.0 + " " + fullName1.1)
               let username2 = editedName[editedName.count - 1] as? String
               let fullName2 = getFullName(username : username2!)
               let newmessage2 = newmessage1.replacingOccurrences(of: String(describing: editedName[editedName.count - 1]), with: fullName2.0 + " " + fullName2.1)
               return newmessage2
           }
    }
      func saveRecievedMsg(msgDict: NSDictionary){
        //  let time = currentTimeMillis()
         //  let updatedDictVal = msgDict.mutableCopy() as! NSMutableDictionary
         // updatedDictVal.setValue(time, forKey: "create_at")
         // updatedDictVal["message_status"] = 0
          createMessageEntityFrom(dictionary: msgDict as! [String : AnyObject], isPushMessage: false, Completion: { (success) in
              if success{
                  saveLastMessageToChannel(channelId: msgDict["channel_id"] as! String, msgCreateAt: msgDict["create_at"] as! Int64)
              }
          })
      }
      
    
    func saveLastMessageToChannel(channelId : String, msgCreateAt : Int64){
        let searchPredicate:NSPredicate = NSPredicate(format:"id == %@",channelId)
        let postList = persistanceService.fetchEntities("Channel", withPredicate: [searchPredicate], sortkey: nil, order: nil, limit: nil)
        if postList.count != 0 , let postInfo = postList[0] as? Channel{
            insertLastMessageToChannel(channelID: channelId, postInfo: postInfo)
        }
    }
    
    func insertLastMessageToChannel(channelID : String, postInfo : Channel){
        var myMattermostID : String = ""
        var userName : String = ""
        let searchPredicate:NSPredicate = NSPredicate(format:"channelId == %@",channelID)
        let msgList = persistanceService.fetchEntities("Messages", withPredicate: [searchPredicate], sortkey: nil, order: nil, limit: nil)
        if msgList.count != 0 {
            if let msgInfo = msgList[msgList.count - 1] as? Messages{
                let channelupdatedDate = Date(timeIntervalSince1970: (TimeInterval(postInfo.lastPost/1000)))
                let messagecreatedDate = Date(timeIntervalSince1970: (TimeInterval(msgInfo.createdAt/1000)))
                if channelupdatedDate <= messagecreatedDate{
                   
                    if postInfo.type != "D", msgInfo.messageType == ""{
                        if msgInfo.userId == Utility.getmattermostUserId(){
                            userName = ""
                        }else{
                            //userName = ChatViewPresenter.chatPresenter.getFullName(userid: msgInfo.userId!) + ": "
                        }
                        if (msgInfo.message?.isEmpty)!{
                            if((msgInfo.file_names?.count)! > 0){
                                if(msgInfo.file_names![0].suffix(4) == ".gif"){
                                    postInfo.lastMessage = userName + "GIF"
                                }
                                else{
                                    postInfo.lastMessage = userName + "Photo"
                                }
                            }
                            else if((msgInfo.filepath?.count)! > 0){
                                if(msgInfo.filepath![0].suffix(4) == ".gif"){
                                    postInfo.lastMessage = userName + "GIF"
                                }
                                else{
                                    postInfo.lastMessage = userName + "Photo"
                                }
                            }
                        }
                        else{
                            postInfo.lastMessage = userName + msgInfo.message!
                        }
                    }else{
                        if (msgInfo.message?.isEmpty)!{
                            if((msgInfo.file_names?.count)! > 0){
                                if(msgInfo.file_names![0].suffix(4) == ".gif"){
                                    postInfo.lastMessage = "GIF"
                                }
                                else{
                                    postInfo.lastMessage = "Photo"
                                }
                            }
                            else if((msgInfo.filepath?.count)! > 0){
                                if(msgInfo.filepath![0].suffix(4) == ".gif"){
                                    postInfo.lastMessage = "GIF"
                                }
                                else{
                                    postInfo.lastMessage = "Photo"
                                }
                            }
                        }else{
                            postInfo.lastMessage = msgInfo.message
                        }
                    }
                    postInfo.lastPost = msgInfo.createdAt
                    //print("inserted last msg", msgInfo.message)
                    if  Utility.getmattermostUserId() != nil{
                        if msgInfo.userId == Utility.getmattermostUserId(), msgInfo.messageType == ""{
                            postInfo.chanelMesageStatus = msgInfo.messageStatus + 1 //For Message Entity (Status as 0,1,2 - clock,single, double tick) For Channel Entity (Status as 0,1,2,3 - received chat,clock,single, double tick)
                        }
                        else{
                            postInfo.chanelMesageStatus = 0
                        }
                    }
                    persistanceService.saveContext()
                }
            }
        }
    }
        //MARK:- Create Employee entity from Mattermost Users List
           func createEmployeeEntityFromMattermost(dictionary: [String: AnyObject]) -> NSManagedObject? {
            _ = persistanceService.persistentContainer.viewContext
            
               var fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Employee")
               // empId = dictionary["id"] as! String
               //fetchRequest.predicate = NSPredicate(format: "mattermost_id = %@", empId)
              // fetchRequest.sortDescriptors = [NSSortDescriptor(key: "email", ascending: true)]
              // var results: [NSManagedObject] = []
              // let emailid = dictionary["email"] as? String
               ///let currentTime = Int(Date().timeIntervalSince1970 * 1000)
               //let profileURL = "account/images/user/" + emailid! + "/profile-image/250x250.jpg?t=" + String(currentTime)
               do {
                  // results = try context.fetch(fetchRequest)
               }
               catch {
                   print("error executing fetch request: \(error)")
               }
              // if(results.count == 0)
//               {
//                   if let employeeEntity = NSEntityDescription.insertNewObject(forEntityName: "Employee", into: context) as? Employee {
//                       employeeEntity.id = 0
//                       employeeEntity.address_1 = ""
//                       employeeEntity.address_2 = ""
//                       employeeEntity.city = ""
//                       employeeEntity.country = ""
//                       employeeEntity.department = ""
//                       employeeEntity.designation = dictionary["position"] as? String
//                       employeeEntity.email = dictionary["email"] as? String
//                       employeeEntity.employee_id = ""
//                       employeeEntity.firstname = dictionary["first_name"] as? String
//                       employeeEntity.lastname = dictionary["last_name"] as? String
//                       employeeEntity.mattermost_id = dictionary["id"] as? String
//                       employeeEntity.phone_number = ""
//                       employeeEntity.profile_image = profileURL as? String
//                       employeeEntity.state = ""
//                       employeeEntity.username = dictionary["username"] as? String
//                       employeeEntity.zip = ""
//                       employeeEntity.status = "offline"
//                       if let firstname = dictionary["first_name"] as? String, let lastname = dictionary["last_name"] as? String{
//                           employeeEntity.fullname = firstname  + " " + lastname
//                       }
//                       employeeEntity.contact = []
//                       do {
//                           try context.save()
//                       } catch let error {
//                           print("Error : \(error)")
//                       }
//                       return employeeEntity
//                   }
//               }
               return nil
           }
 
        func updateLastMsgStatus(channelid: String, msgDict : NSDictionary){
            do{
                let searchPredicate:NSPredicate = NSPredicate(format:"id == %@",channelid)
                let postList = persistanceService.fetchEntities("Channel", withPredicate: [searchPredicate], sortkey: nil, order: nil, limit: nil)
                if postList.count != 0 {
                    do{
                        if let postInfo = postList[0] as? Channel{
                            if let msgUserid = msgDict["user_id"] as? String{
                                if  Utility.getmattermostUserId() != nil{
                                    if msgUserid == Utility.getmattermostUserId(){
                                        postInfo.chanelMesageStatus = 3
                                    }
                                    else{
                                        postInfo.chanelMesageStatus = 0
                                    }
                                }
                            }
                            persistanceService.saveContext()
                        }
                    }
                    catch let error {
                        print("ERROR DELETING : \(error)")
                    }
                }
                else{
                    
                }
            }
        }
           
      }
