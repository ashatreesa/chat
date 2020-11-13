//
//  Service.swift
//  Chat
//
//  Created by Asha Treesa Kurian on 08/09/20.
//  Copyright © 2020 fingent. All rights reserved.
//
import UIKit
import Foundation
import Alamofire
import RxSwift
import AlamofireImage
public class Service: NSObject
{
    var isgetChannelsSuccess : Bool = false
    var chanelPreferArray       : NSArray = []
    var listvalue = Array<Dictionary<String,Any>>()
    var messageList = Array<Dictionary<String,Any>>()
    var disposeBag = DisposeBag()
    var dict = Dictionary<String, Any>()
    var usersArray  : NSMutableArray = []
    var channelArray: NSArray = []
    var channelArray1: NSArray = []

    var finalChanels: NSMutableArray = []
    var mentionC: Int64 = 0
    var presenter : DataPresenter!
    var directChatDictionary: NSDictionary!
    var userDetails        : NSArray = []
    var userslist = Array<Dictionary<String,Any>>()
    var UserList = Array<Dictionary<String,Any>>()
    var sortedarray = Array<Dictionary<String,Any>>()
    var sortedarray1 = Array<Dictionary<String,Any>>()
    var channeldetail = Array<Dictionary<String, Any>>()
    override init() {
    super.init()
        presenter = DataPresenter()
        }
    
    
    open func startLoginAuthentication(_ username:String, password:String) {
        let username = "asha.treesa@fingent.com"
        let password = "Asha.treesa@#1234"
        let dic = ["login_id":username,"password":password]
        let url = Global.ServiceUrls.baseURL+Global.ServiceUrls.mattermostLoginAuthentication
        
        
        Alamofire.request(url, method: .post,  parameters: dic, encoding: JSONEncoding.default,headers: nil)
            .responseJSON {response in

                
                guard let newsResponse = response.result.value as?[String:Any] else{
                    return
                }
              
                if response.response!.statusCode == 200{
                    if let headers = response.response?.allHeaderFields as? [String: String]{
                        let tokenid = headers["token"]
                UserDefaults.standard.set(tokenid, forKey: "mattermost_token")                        //Global.Constants.Token = tokenid!
                        let userid = newsResponse["id"]as?String
                         UserDefaults.standard.set(userid, forKey: "mattermost_user_id")
                        let email = newsResponse["email"]as?String
                        let userName = newsResponse["username"]as?String
                       
                      //  self.userdet = User_Details(dict as [String : Any])
                        
                        self.createDirectChannel(userId: userid!, userName: userName!, email: email!)
                        let user = UserDetails(context:persistanceService.context)
                        user.userName = username
                        user.email = email
                        user.userId = userid
                        
                        persistanceService.saveContext()
                        AppDataManager.sharedInstance.saveInKeychain(value: tokenid!, key: Token.sessionToken)
                        
                        
                        
                    }
                    
                    
                }
                
        }
        
        
        
        
    }
    
    //MARK:- Get messages of channel
    func getMessagesofChannel(with channelVal: NSDictionary) -> Observable<Any>{
        let channeld = channelVal["id"] as! String
        
        let getAllMsgs = Global.ServiceUrls.baseURL+Global.ServiceUrls.mattermostchannelMsgs + channeld + "/posts"

        let headers: HTTPHeaders = ["Authorization": "Bearer \(Global.Constants.Token)"]

        return Alamofire.request(getAllMsgs, method: .get, parameters: nil, encoding: URLEncoding.default, headers:Utility.getHeader()).rx.responseJSON()
            .map{ msg in
                return msg
            }
            .filter{ originResp in

                var resp: Bool = true
                let orgResp = originResp as! NSDictionary
                
                self.messageList.append(orgResp as! Dictionary<String, Any>)
                   AppDataManager.sharedInstance.saveInSharedPreference(key: Global.DatabaseKey.messagelist, value: self.messageList)
                
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
            .flatMap{ msgResponse -> Observable<Any> in
                let myDictionary = msgResponse as! NSDictionary

                let orders = (myDictionary["order"] as? [String]) ?? []
                var lastmsg : String = ""
                
                if orders.count != 0{
                    let lastOrder = orders[0]
                    let posts = myDictionary["posts"] as? NSDictionary
                    
                    
                  
                    if let lastPost = posts?.value(forKey: lastOrder) as? NSDictionary{
                        
                        let message = lastPost["message"] as? String
                        
                        let type = lastPost["type"] as? String
                        lastmsg = message!

                  
                    }
                }
                let updatedDictVal = channelVal.mutableCopy() as! NSMutableDictionary
                updatedDictVal["message"] = lastmsg
                updatedDictVal["message_stat"] = 0

                if  updatedDictVal["type"]as?String == "D"
                {
                    if updatedDictVal["message"]as?String != ""
                        {
                 
                     
                }
                }

               
                
                return Observable.just(updatedDictVal)
        }
    }
    
    func createDirectChannel(userId: String , userName: String , email: String) {
        
        if(ReachabilityManager.isInternetAvailable()){
            let createDirectChannel = Global.ServiceUrls.baseURL + Global.ServiceUrls.mattermostdirectchannel
            var request = URLRequest(url: try! createDirectChannel.asURL())
            
            //some header examples
            
            request.httpMethod = "POST"
            //let token = UserDefaults.standard.string(forKey: "mattermost_token")
            request.setValue("Bearer "+Global.Constants.Token,
                forHTTPHeaderField: "Authorization")
            
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            
            //parameter array
            
            let values = [ Utility.getmattermostUserId(), userId]
            
            request.httpBody = try! JSONSerialization.data(withJSONObject: values)
            
            //now just use the request with Alamofire
            
            return Alamofire.request(request).rx.responseJSON()
                
                .map{ channelCreated in
                    return channelCreated
                }
                .filter{ originResp in
                    let orgResp = originResp as! NSDictionary
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
                .flatMap{ channelResp -> Observable<Any> in
                    let channelDict = channelResp as! NSDictionary
                    
                    let name = channelDict["name"] as? String
                    let fullNameArr = name?.components(separatedBy: "__")
                    let userId: String!
                    if fullNameArr![0] == Utility.getmattermostUserId() {
                        userId = fullNameArr![1]
                    }
                    else{
                        userId = fullNameArr![0]
                    }
                    let updatedDictVal = channelDict.mutableCopy() as! NSMutableDictionary
                    updatedDictVal.setValue(userName, forKey: "display_name")
                    updatedDictVal["channelStatus"] = false
                    updatedDictVal["isChannelMember"] = true
                    updatedDictVal["userId"] = userId
                    return Observable.just(updatedDictVal)
                }
                .flatMap{ resp -> Observable<Any> in
                    self.directChatDictionary = resp as! NSDictionary
                    return Observable.just(self.directChatDictionary)
                }
                .subscribe(onNext: { item in
                    print(item)
                },
                           onCompleted: {
                         
                            if self.directChatDictionary != nil{
                            
                            }
                            else{
                                //SVProgressHUD.dismiss()
                            }
                            
                }).disposed(by: self.disposeBag)
        }
        else{
            
            let alert = UIAlertController(title: "", message: "Network error", preferredStyle: UIAlertController.Style.alert)
//            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
//                self.dismiss(animated: true)
//            }))
            //self.present(alert, animated: true, completion: nil)
        }
    }

    
    func getChats()-> Observable<Any> {
        if  let teamId = Global.Constants.team_id as?String{
         
           let getAllChannels =  Global.ServiceUrls.baseURL+Global.ServiceUrls.mattermostGetteamMsg + teamId + "/channels"
             var headers: HTTPHeaders = ["Authorization": "Bearer \(Global.Constants.Token)"]
           return Alamofire.request(getAllChannels, headers:Utility.getHeader()).rx.responseJSON()
           //print("Utility.getHeader()\(Utility.getHeader())")
           // .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
       }
       return Observable.just("empty")
  
        
    }
    func getChannels() -> Array<Dictionary<String, Any>> {
            getChats()
                .throttle(0.1, scheduler: MainScheduler.instance)
                .map{ origin in
                 

                    return origin
                }
                .filter{ originResp in
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
                .flatMap{ value -> Observable<Any> in
                    self.channelArray = value as! NSArray
                    return Observable.from(self.channelArray)
                }
                .flatMap{ y -> Observable<Any> in
                    let singItem = y as? NSDictionary
                    if let type = singItem!["type"] as? String {
                        if type == "O"{
                            if let name = singItem!["name"] as? String{
                                if name == "town-square"{
                                    if let townSquareID = singItem!["id"] as? String{
                                        UserDefaults.standard.set(townSquareID, forKey: "TownSquareID")
                                    }
                                }
                            }
                        }
                    }
                    return Observable.just(y)
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
                    if singItem!["type"] as? String == "D"{
                        
                        self.userslist.insert(singItem as! Dictionary<String, Any>, at: 0)
                        
                      
                        
                        
                        return self.getDisplayName(with: originval as! NSDictionary)
                    }
                    else{
                        return Observable.just(originval)
                    }
                }
                .flatMap{ valueResp -> Observable<Any> in
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
                           // SVProgressHUD.dismiss()
                            let alert = UIAlertController(title: "", message: "Network Error", preferredStyle: UIAlertController.Style.alert)
                            alert.addAction(UIAlertAction(title: "Retry", style: .default, handler: { (action: UIAlertAction!) in
                                self.isgetChannelsSuccess = false
                                self.getChannels()
                            }))
                            //self.present(alert, animated: true, completion: nil)
                            
                },
                           onCompleted: {
                           // self.showNoChatsLabel(chatCount : self.finalChanels.count)
                            self.presenter.saveChannelsToDb(channelsArray: self.finalChanels as! Array<Dictionary<String, Any>>)
                            self.channeldetail = self.finalChanels as! [Dictionary<String, Any>]
                            if let nsArr = self.channeldetail as? NSArray{
                                        self.channelArray1 = nsArr.sortedArray(using: [NSSortDescriptor(key: "last_post_at", ascending: false)]) as NSArray
                                               }
                           let sortedItemsArray = self.channeldetail.sorted { self.itemsSort1(p1:$0, p2:$1) }
                           
                            
                            //print("channelArray1\(self.channelArray1)==\(sortedItemsArray)")
                            self.sortedarray1 = self.finalChanels as! [Dictionary<String, Any>]
                            
                                                    AppDataManager.sharedInstance.saveInSharedPreference(key: Global.DatabaseKey.userdetails, value:self.sortedarray1)
                                                    
                              // print("sortedarray1\(self.channelArray1)==\(sortedItemsArray)")
                          
                            self.setPreferencesofChannel()
                            self.isgetChannelsSuccess = true
                            //self.syncSuccess = true
                }
                ).disposed(by: disposeBag)
        return finalChanels as! Array<Dictionary<String, Any>>
    }

    
    //MARK:- get username of type D users
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
        let heades: HTTPHeaders = ["Authorization": "Bearer \(Global.Constants.Token)"]
        return Alamofire.request(getAllUsers,headers:Utility.getHeader()).rx.responseJSON()
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
                   
               
                    //self.presenter.createUserEntityFrom(dictionary: updateUSer as! [String : AnyObject])
                   self.presenter.saveChannelsToDb(channelsArray: self.listvalue)
                    //persistanceService.saveContext()
                     self.presenter.createEmployeeEntityFromMattermost(dictionary: updateUSer as! [String : AnyObject])
                }
                return Observable.just(userResp)
                
            }
            .flatMap{ val -> Observable<Any> in
                let json = val as? [String: Any] ?? [:]

                let updatedDictVal = origin.mutableCopy() as! NSMutableDictionary
                var fname = ""
              if  let fstname = json["first_name"] as? String
              {
                fname = fstname
                }
                
                let username  = json["username"] as? String
                let lname = json["last_name"] as? String
                let emaill = json["email"] as? String
                var finalName = ""

                if fname != "" && fname != nil {
                    finalName = fname + " " + lname!
                    
                }
                else
                {
                    //print("username\(username)")
                    finalName = username!

                }
                    updatedDictVal["email"] = emaill
                updatedDictVal.setValue(finalName.capitalized, forKey: "display_name")
             
                updatedDictVal["userId"] = userId
                
                if  updatedDictVal["userId"]as?String != Utility.getmattermostUserId()
                {
                    self.UserList.append(updatedDictVal as! Dictionary<String, Any>)
            //let descriptor: NSSortDescriptor = NSSortDescriptor(key: "display_name", ascending: true)
                        //print("updatedDictVal\(updatedDictVal)")
                    let sortedItemsArray = self.UserList.sorted { self.itemsSort(p1:$0, p2:$1) }
                    self.sortedarray = sortedItemsArray
           
            AppDataManager.sharedInstance.saveInSharedPreference(key: Global.DatabaseKey.userlist, value: self.sortedarray)
                }


              
                
                return Observable.just(updatedDictVal)
        
    }
    }
    func itemsSort1(p1:[String:Any], p2:[String:Any]) -> Bool {
        
        guard let s1 = p1["last_post_at"] as? Int64, let s2 = p2["last_post_at"] as? Int64 else {
            return false
        }
        return s1 > s2
    }

   
    
     func setPreferencesofChannel(){
         self.chanelPreferArray.forEach(){ prefDict in
            
            // print("prefDict\(prefDict)")
             let dict = prefDict as! NSDictionary
             let userId = dict["name"] as? String
             let valueVal = dict["value"] as? String
             let searchPredicate:NSPredicate = NSPredicate(format:"userId == %@",userId!)
             let postList = persistanceService.fetchEntities("Channel", withPredicate: [searchPredicate], sortkey: nil, order: nil, limit: nil)

             if postList.count != 0{
                 if let postInfo = postList[0] as? Channel{
                     if valueVal == "true"{
                         postInfo.isShow = true
                         persistanceService.saveContext()
                     }
                     else{
                        postInfo.isShow = false
                         persistanceService.saveContext()
                     }
                    Utility.MessageDetails.shared.channelInfo = postInfo
                   Utility.MessageDetails.shared.channelID = postInfo.id
                    Utility.MessageDetails.shared.goToMessage = true                 }
             }
         }
         
     }
    //MARK:- get all members and mention count
     func getMembers(with origin: NSDictionary) -> Observable<Any> {
         let name = origin["name"] as? String
         let channelId = origin["id"] as? String
        Utility.MessageDetails.shared.channelID = channelId
          AppDataManager.sharedInstance.saveInSharedPreference(key: "channelId", value: channelId)
        // let getMembrs = appDelegate.configObject.base_url! + serviceUrl.GET_MEMBERS.rawValue
        let getAllMembers =  Global.ServiceUrls.baseURL+Global.ServiceUrls.mattermostchannelMsgs+channelId!+"/members"
          var headers: HTTPHeaders = ["Authorization": "Bearer \(Global.Constants.Token)"]
         return Alamofire.request(getAllMembers,headers:Utility.getHeader()).rx.responseJSON()
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
                 let item = filterItem as? NSDictionary
                 
                 let channelItem = origin as NSDictionary
                 let typ = channelItem["type"] as! String
                 
                 if typ == "D"{
//                     var stat: Bool?
//                     let searchPredicate:NSPredicate = NSPredicate(format:"channelId == %@",channelId!)
//                     let postList = persistanceService.fetchEntities("Channel", withPredicate: [searchPredicate], sortkey: nil, order: nil, limit: nil) as! NSArray
//                     if postList.count != 0{
//                         if let postInfo = postList[0] as? Channel{
//                             stat =  postInfo.isShow
//
//                         }
//                     }
                     self.mentionC = item!["mention_count"] as! Int64
                    let updatedDictVal = origin.mutableCopy() as! NSMutableDictionary
                 updatedDictVal["mention_count"] = self.mentionC
                 updatedDictVal.setValue(self.mentionC, forKey: "mention_count")
                  updatedDictVal["channelStatus"] = true
                   return Observable.just(updatedDictVal)
//
                 }
                 
                else{
                    let mentnCount = origin["mention_count"] as? Int64
                         let updatedDictVal = origin.mutableCopy() as! NSMutableDictionary
                         updatedDictVal.setValue(mentnCount!, forKey: "mention_count")
                         return Observable.just(updatedDictVal)
                 }
         }
     }
    
    func getUsers()  {
        if let teamId = Global.Constants.team_id as? String{
                  
                 
                  let getAllusers = Global.ServiceUrls.baseURL + Global.ServiceUrls.mattermostGetUser + "?in_team="+teamId
            let headers: HTTPHeaders = ["Authorization": "Bearer \(Global.Constants.Token)"]
                  return Alamofire.request(getAllusers, headers: Utility.getHeader()).rx.responseJSON()
                      .map{ userResponse in
                          return userResponse
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
                      .flatMap{ usersList -> Observable<Any> in
                          self.userDetails = usersList as! NSArray
                          return Observable.from(self.userDetails)
                      }
                      .flatMap{ y -> Observable<Any> in
                          return Observable.just(y)
                      }
                      .flatMap{ singleUser -> Observable<Any> in
                          return self.getUserStatus(userInfo: singleUser as! NSDictionary)
                      }
                      .filter{ itemS in
                          var resp: Bool = true
                          let singleItem = itemS as? NSDictionary
                          
                          if singleItem!["id"]! as? String != Utility.getmattermostUserId() {
                              resp = true
                          }
                          else{
                              resp = false
                          }
                          return resp
                      }
                      
                      .flatMap{ finalDic -> Observable<NSMutableArray> in
                          self.usersArray.add(finalDic)
                        

                          return Observable.just(self.usersArray)
                      }
                      
                      .subscribe(onNext: { item in
                      },
                                 onError: { error in
                                  print(error)
                                  self.getUsers()
                      },
                                 onCompleted: {
                            AppDataManager.sharedInstance.saveInSharedPreference(key: Global.DatabaseKey.userData, value: self.usersArray)
                            self.presenter.saveUsersToDb(usersArray: self.usersArray)
                      }).disposed(by: disposeBag)
              }
      }
    //MARK:-get userstatus
    func getUserStatus(userInfo: NSDictionary) -> Observable<Any>{
        print(userInfo)
        let userId = userInfo["id"] as! String
        let getAllusers = Global.ServiceUrls.baseURL + Global.ServiceUrls.mattermostGetUsers + userId + "/status"
         var headers: HTTPHeaders = ["Authorization": "Bearer \(Global.Constants.Token)"]
        return Alamofire.request(getAllusers, headers:Utility.getHeader()).rx.responseJSON()
            .map{ statusResp in
                return statusResp
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
            .flatMap{ statusItem -> Observable<Any> in
                let item = statusItem as? NSDictionary
                let status = item!["status"] as? String
                
                let  updatedDictVal = userInfo.mutableCopy() as! NSMutableDictionary
                updatedDictVal.setValue(status, forKey: "userStatus")
                return Observable.just(updatedDictVal)
        }
    }
    
//    func getListOfUsers() {
//        //"seq": 1,
//        let url: String = Global.ServiceUrls.baseURL+Global.ServiceUrls.mattermostGetUsers
//     print("resultVal\(url)")
//       // var dic = ["page" : 1,"per_page" : 3,"include_total_count" : true] as [String : Any]
//
//        var headers: HTTPHeaders = ["Authorization": "Bearer \(Global.Constants.Token)"]
//
//        Alamofire.request(url,method: .get,headers: headers).validate().responseJSON() {
//            (response) in
//
//            switch response.result {
//
//
//            case .success:
//                if let JSON = response.result.value as?Array<Dictionary<String,Any>> {
//                    var resultVal = Dictionary<String,Any>()
//                    print("resultVal..1\(JSON)")
//
//                    self.presenter.saveUsersToDb(usersArray: JSON as NSArray)
//                    for json in JSON
//                    {
//                        resultVal = json as! Dictionary<String,Any>
//
////presenter.saveUsersToDb(usersArray: resultVal)
//                        print("resultVal...2\(resultVal)")
//                        self.userList = User_list(resultVal as [String : Any])
//                        print("self.userList\( self.userList)")
//                        var userLIST = UserList(context:persistanceService.context)
//                        userLIST.insertIntoDB(userList: self.userList)
//                        userLIST.deletedAt = String(self.userList.deletedAt)
//                        userLIST.id = self.userList.id
//                        userLIST.role = self.userList.roll
//                        userLIST.updatedAt = self.userList.updatedAt
//                        userLIST.userName = self.userList.userName
//                        print("userLIST\(userLIST.userName )")
//                        persistanceService.saveContext()
//                        self.getChannels()
//
//                    }
//                }
//            case .failure(let error): break
//                // error handling
//            }
//        }
//
//
//
//
//
//
//
//    }
    
     func itemsSort(p1:[String:Any], p2:[String:Any]) -> Bool {
           guard let s1 = p1["display_name"] as? String, let s2 = p2["display_name"] as? String else {
               return false
           }
           return s1 < s2
       }
    
    //MARK:- create direct channel 
    //MARK:- get username of type D users
    func getUserDetailss(with origin: NSDictionary, with userId: String) -> Observable<Any> {
        
        let getuser = Global.ServiceUrls.baseURL+Global.ServiceUrls.mattermostGetUsers
        let getAllUsers = getuser + userId
        let headers: HTTPHeaders = ["Authorization": "Bearer \(Global.Constants.Token)"]
        
        return Alamofire.request(getAllUsers,headers: Utility.getHeader()).rx.responseJSON()
            .map { secondResponse in
                return secondResponse
            }
            .filter{ originResp in
                var resp: Bool = true
                 let orgResp = originResp as! NSDictionary
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
            .flatMap{ userResp -> Observable<Any> in
                let userlist = userResp as! NSDictionary
                let updateUSer = userlist.mutableCopy() as! NSMutableDictionary
                updateUSer["userStatus"] = "offline"
                if userlist["id"] as? String != Utility.getmattermostUserId(){
                    //self.presenter.createUserEntityFrom(dictionary: updateUSer as! [String : AnyObject])
                    self.presenter.createEmployeeEntityFromMattermost(dictionary: updateUSer as! [String : AnyObject])
                }
                return Observable.just(userResp)
                
            }
            .flatMap{ val -> Observable<Any> in
                let json = val as? [String: Any] ?? [:]
                let updatedDictVal = origin.mutableCopy() as! NSMutableDictionary
               
                let emaill = json["email"] as? String
              
                    updatedDictVal["email"] = emaill
                return Observable.just(updatedDictVal)
        }
    }
   
}
