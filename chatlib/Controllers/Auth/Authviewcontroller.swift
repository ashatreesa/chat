//
//  Authviewcontroller.swift
//  Chat
//
//  Created by Asha Treesa Kurian on 20/08/20.
//  Copyright © 2020 fingent. All rights reserved.
//

import UIKit
import Starscream
import SocketIO
import CoreData
import Alamofire
import RxSwift
protocol messageView : class
{
   func syncAllAPI(token:String)
   func startLoginAuthentication(_ username:String, password:String)
   func getUsers()
   func getUserStatus(userInfo: NSDictionary) -> Observable<Any>
   func getChats() -> Observable<Any>
   func getChannels()
   func itemsSortlastPost(p1:[String:Any], p2:[String:Any]) -> Bool
   func getDisplayName(with origin: NSDictionary) -> Observable<Any>
     func itemsSortDisplayName(p1:[String:Any], p2:[String:Any]) -> Bool
    func getMembers(with origin: NSDictionary) -> Observable<Any>
    func checkDBCount()
    func showNoChatsLabel(chatCount : Int)
    func scrollChatsTVTop()
    func chatTVScrollstoTop()
    func fetchChannelInfo()
    func createDirectChannel(userId: String , userName: String)
  
     func getUsername(with origin: NSDictionary) -> Observable<Any>
     func displayTime(timer : Int64) -> String
     func noDuplicates(_ arrayOfDicts: [[String: Any]]) -> [[String: Any]]
     func checkdataPresent()
     func initializationOfdarkAndLightModeUI()
    
    
}
public class Authviewcontroller: UIViewController, NSFetchedResultsControllerDelegate, UISearchResultsUpdating,UISearchBarDelegate{
    var userSearchedImageUrl: String = ""

    var userName: String = ""
    var searchActive: Bool = false
    var searchstring = Array<Dictionary<String,Any>>()
    var channelArray1 = Array<Dictionary<String,Any>>()
    var isgetChannelsSuccess : Bool = false
    var UserListdetail = Array<Dictionary<String,Any>>()
    var sortedarraydetail = Array<Dictionary<String,Any>>()
    var directChatDictionary: NSDictionary!
    var isMessaging: Bool = false
    var singleUserArray: NSMutableArray = []
    var userInfo = [Channel]()
    var token = ""
    var disposeBag = DisposeBag()
     var filteredChannels  = [NSManagedObject]()
     var channelArray      : NSArray = []
     var chanelPreferArray  : NSArray = []
     var finalChanels   : NSMutableArray = []
     var mentionC    : Int64 = 0
     var userDetails : NSArray = []
     var usersArray  : NSMutableArray = []
     var channeldetail = Array<Dictionary<String, Any>>()
     var Datapresenter: DataPresenter!
        var authpresenter : AuthPresenter!
        var service : Service!
        var listvalue = Array<Dictionary<String,Any>>()
        var userlist = UserList()
        var username  = String()
        var Time  = [Int64]()
        var channelList = [Channel]()
        var searchPredicate: NSPredicate?
        var userdetails = Array<Dictionary<String,Any>>()
        var uniquedetails = Array<Dictionary<String,Any>>()
    @IBOutlet weak var userListTableView: UITableView!
    
    @IBOutlet weak var searchBarfilter: UISearchBar!
  
    @IBOutlet weak var mainview: UIView!
    
    
    @IBOutlet var containerView: UIView!
    
    @IBOutlet weak var act: UIActivityIndicatorView!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
    
       self.userListTableView.tableFooterView = UIView()
        self.userListTableView.separatorColor = UIColor.gray
        searchBarfilter.resignFirstResponder()
        service = Service()
       Datapresenter = DataPresenter()
        authpresenter = AuthPresenter()
        searchBarfilter.delegate = self
        self.initializationOfdarkAndLightModeUI()
       
       

  

 }

    public override func viewDidAppear(_ animated: Bool) {
           super.viewDidAppear(animated)
        self.fetchedResultController.delegate = self
        

    }
    
    public override func viewWillAppear(_ animated: Bool) {
        
        self.checkdataPresent()
        }
   
    public var syncSuccess: Bool = false{
           didSet{
               if isgetChannelsSuccess{
                   self.act.stopAnimating()
                   UserDefaults.standard.set(true, forKey: "dbComplete")
                   if Utility.getmattermostUserId() != nil {
                    authpresenter.channelsUpdate()
                    
                   }
               }
           }
       }
  
    public override func viewWillDisappear(_ animated: Bool) {
             super.viewWillDisappear(true)
          //searchstring.removeAll()
          }

    public func updateSearchResults(for searchController: UISearchController) {
     if searchBarfilter.text != ""
          {
          do {
                         try self.fetchedResultController.performFetch()
                     } catch let error  {
                         print("ERROR: \(error)")
                     }
                     
                     self.searchActive = false
             userListTableView.reloadData()

                     self.filteredChannels = [NSManagedObject]()
                     if let count = fetchedResultController.sections?.first?.numberOfObjects {
                         self.showNoChatsLabel(chatCount: count)
                     }
          }
          
    }




    
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        searchstring = userdetails.filter({
            
            let string = $0["display_name"] as! String
            return string.hasPrefix(searchText)
            
        })
        searchActive = true
        self.searchBarfilter.becomeFirstResponder()

        userListTableView.reloadData()

    }
  
 
    

       lazy var fetchedResultController: NSFetchedResultsController<NSFetchRequestResult> = {
              let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: Channel.self))
             // fetchRequest.predicate = NSPredicate(format: "isShow == %@", NSNumber(booleanLiteral: true))
              fetchRequest.sortDescriptors = [NSSortDescriptor(key: "lastPost", ascending: false)]
              let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: persistanceService.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
              frc.delegate = self
              return frc
          }()

func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
    if searchBarfilter.text?.count == 0 {
        perform("hideKeyboardWithSearchBar:", with:searchBar, afterDelay:0)
       }
   }

   func hideKeyboardWithSearchBar(bar:UISearchBar) {
       searchBarfilter.resignFirstResponder()
   }
    

 
}
extension Authviewcontroller : messageView
{
    
      func syncAllAPI(token:String){
          let tkn = token
        if userdetails.count == 0
                                {
            act.startAnimating()
        }
          if ReachabilityManager.isInternetAvailable(){
               
              getChannels()
            getUsers()
               
     
            }
            else{
              let alert = UIAlertController(title: "Network Error", message: "Please check your Internet", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Retry", style: .default, handler: { (action: UIAlertAction!) in
                    self.syncSuccess = false
                  self.syncAllAPI(token: tkn)
                }))
                self.present(alert, animated: true, completion: nil)
            }
        }
    
    
     func startLoginAuthentication(_ username:String, password:String) {
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
                        if let tokenid = headers["token"]as?String
                        {
                            UserDefaults.standard.set(tokenid, forKey: "mattermost_token")
                            self.syncAllAPI(token:tokenid)

                            self.token = tokenid

                        }
                        //Global.Constants.Token = tokenid!
                        let userid = newsResponse["id"]as?String
                         UserDefaults.standard.set(userid, forKey: "mattermost_user_id")
                        let email = newsResponse["email"]as?String
                        let userName = newsResponse["username"]as?String
                       
                       
                        
                        
                      //  self.userdet = User_Details(dict as [String : Any])
                        
                       // self.createDirectChannel(userId: userid!, userName: userName!, email: email!)
                        let user = UserDetails(context:persistanceService.context)
                        user.userName = username
                        user.email = email
                        user.userId = userid
                        
                        persistanceService.saveContext()
                        //  self.vc.apiRequest()
                        //self.getUsers()
                        //self.getChannels()//MattermostSocketManager.sharedInstance.establishConnection()
                        AppDataManager.sharedInstance.saveInKeychain(value: self.token, key: Token.sessionToken)
                        
                        
                        
                    }
                    
                    
                }
                
        }
        
        
        
        
    }
    
    
    func getUsers()  {
              if let teamId =  Global.Constants.team_id as? String{
                  let getAllusers = Global.ServiceUrls.baseURL + Global.ServiceUrls.mattermostGetUser + "?in_team="+teamId
                 
                  
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
                        self.userListTableView.reloadData()
//print("userDetails\(self.userDetails)")

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
                                 // print("Completed users",self.usersArray)
                                  self.Datapresenter.saveUsersToDb(usersArray: self.usersArray)
                      }).disposed(by: disposeBag)
              }
      }
    
    
    func getUserStatus(userInfo: NSDictionary) -> Observable<Any>{
        print(userInfo)
        let userId = userInfo["id"] as! String
        let getAllusers = Global.ServiceUrls.baseURL + Global.ServiceUrls.mattermostGetUsers + userId + "/status"
      
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
    
    
      func getChats() -> Observable<Any>{
          //   myGroup.enter()
    //print("channels123-==\( UserDefaults.standard.string(forKey: "mattermost_token"))")
          let teamId = Global.Constants.team_id
          let getAllChannels =  Global.ServiceUrls.baseURL+Global.ServiceUrls.mattermostGetteamMsg + teamId + "/channels"
          if UserDefaults.standard.string(forKey: "mattermost_token") == nil
          {
              let headers: HTTPHeaders = ["Authorization": "Bearer \(UserDefaults.standard.string(forKey: "mattermost_token"))"]
              
              return Alamofire.request(getAllChannels, headers: headers).rx.responseJSON()
          }else{

              return Alamofire.request(getAllChannels, headers: Utility.getHeader()).rx.responseJSON()
          }
          
         

              // .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
          
          return Observable.just("empty")
      }
    
      func getChannels()  {
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
                     // print("finalChanelstested3\(originResp)")

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
                     //   print(value, "value123")
                        self.channelArray = value as! NSArray
                     // print("finalChanelstested5\(self.channelArray)")

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
                            return self.getDisplayName(with: originval as! NSDictionary)
                          
                        }
                        else{
                            return Observable.just(originval)
                        }
                    }
                    .flatMap{ valueResp -> Observable<Any> in
                        let value = valueResp as? NSDictionary
                        print("value11\(value)")
                     // print("finalChanelstested6\(valueResp)")

                        return self.authpresenter.getMessagesofChannel(with: (value!))
                    }
                    .filter{ channelVal in
                        var resp: Bool = true
                        let singleItem = channelVal as? NSDictionary
                     // print("finalChanelstested7\(channelVal)")

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
                              //  SVProgressHUD.dismiss()
                                  let alert = UIAlertController(title: "", message: "Network Error", preferredStyle: UIAlertController.Style.alert)
                                alert.addAction(UIAlertAction(title: "Retry", style: .default, handler: { (action: UIAlertAction!) in
                                    print("FAILURE : Get Channels API")
                                    self.isgetChannelsSuccess = false
                                    self.getChannels()
                                }))
                                self.present(alert, animated: true, completion: nil)
                                
                    },
                               onCompleted: {
                                print(self.chanelPreferArray)
                                print(self.finalChanels)
                              self.finalChanels as! Array<Dictionary<String, Any>>
                                self.channeldetail = self.finalChanels as! [Dictionary<String, Any>]
                               
                                 // print("finalChanelstested=\(self.finalChanels)==\(self.chanelPreferArray)")
                                  
                          let sortedItemsArray = self.channeldetail.sorted { self.itemsSortlastPost(p1:$0, p2:$1) }
                                 // print("fL\(sortedItemsArray)")

                                   
                                   AppDataManager.sharedInstance.saveInSharedPreference(key: Global.DatabaseKey.userdetails, value:sortedItemsArray)
                                  self.userdetails = sortedItemsArray
                                  self.userListTableView.reloadData()
                                  
                                self.Datapresenter.saveInCoreDataWith(array: self.finalChanels as! [[String : AnyObject]])
                                self.act.stopAnimating()
                              //  self.setPreferencesofChannel()
                                self.isgetChannelsSuccess = true
                                self.syncSuccess = true
                    }
                    ).disposed(by: disposeBag)
        }
    func itemsSortlastPost(p1:[String:Any], p2:[String:Any]) -> Bool {
             
             guard let s1 = p1["last_post_at"] as? Int64, let s2 = p2["last_post_at"] as? Int64 else {
                 return false
             }
             return s1 > s2
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
                       self.Datapresenter.createUserEntityFrom(dictionary: updateUSer as! [String : AnyObject])
                   }
                   return Observable.just(userResp)
                   
               }
               .flatMap{ val -> Observable<Any> in
                  let json = val as? [String: Any] ?? [:]

                           let updatedDictVal = origin.mutableCopy() as! NSMutableDictionary
                           //print("jsonjson\(json)")
                           var fname = ""
                         if  let fstname = json["first_name"] as? String
                         {
                           fname = fstname
                           }
                           
                           let username  = json["username"] as? String
                           let lname = json["last_name"] as? String
                           let emaill = json["email"] as? String
                           var finalName = ""
                          // print("jsonjson1\(fname)")

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
                               self.UserListdetail.append(updatedDictVal as! Dictionary<String, Any>)
                       //let descriptor: NSSortDescriptor = NSSortDescriptor(key: "display_name", ascending: true)
                                 //  print("updatedDictVal\(updatedDictVal)")
                               let sortedItemsArray = self.UserListdetail.sorted { self.itemsSortDisplayName(p1:$0, p2:$1) }
                               self.sortedarraydetail = sortedItemsArray
                              
                          //  print("sortedarraydetail\(self.sortedarraydetail)")
                                         
                       AppDataManager.sharedInstance.saveInSharedPreference(key: Global.DatabaseKey.userlist, value: self.sortedarraydetail)
                           }


                         
                              // self.presenter.saveChannelsToDb(channelsArray: [updatedDictVal])
                               //self.listvalue.append(updatedDictVal as! Dictionary<String, Any>)
                               

                                      
                                      
                                     
                           
                           
                           return Observable.just(updatedDictVal)
                   
           }
       }
    func itemsSortDisplayName(p1:[String:Any], p2:[String:Any]) -> Bool {
                guard let s1 = p1["display_name"] as? String, let s2 = p2["display_name"] as? String else {
                    return false
                }
                return s1 < s2
            }
    
    
     func getMembers(with origin: NSDictionary) -> Observable<Any> {
         let name = origin["name"] as? String
         let channelId = origin["id"] as? String
         let getMembrs = Global.ServiceUrls.baseURL + Global.ServiceUrls.mattermostchannelMsgs
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
                     updatedDictVal["mention_count"] = self.mentionC
                     // updatedDictVal["channelStatus"] = true
                     return Observable.just(updatedDictVal)
                 }
                 else{
                     
                     let db_bool = UserDefaults.standard.bool(forKey: "dbComplete")
                     if db_bool{
                         if let mentnCount = origin["mention_count"] as? Int64{
                             let searchPredicate:NSPredicate = NSPredicate(format:"id == %@",channelId!)
                             let postList = persistanceService.fetchEntities("Channel", withPredicate: [searchPredicate], sortkey: nil, order: nil, limit: nil) as! NSArray
                             if postList.count != 0{
                                 if let postInfo = postList[0] as? Channel{
                                     self.mentionC = 0
                                     //postInfo.mentionCount + mentnCount
                                     
                                 }
                             }
                             else{
                                 self.mentionC = 0
                             }
                         }
                     }
                     else{
                         let searchPredicate:NSPredicate = NSPredicate(format:"channelId == %@",channelId!)
                         let postList = persistanceService.fetchEntities("Channel", withPredicate: [searchPredicate], sortkey: nil, order: nil, limit: nil) as! NSArray
                         if postList.count != 0{
                             if let postInfo = postList[0] as? Channel{
                                 self.mentionC = 0
                                 //postInfo.mentionCount
                                 
                             }
                         }
                         else{
                             self.mentionC = 0
                         }
                     }
                     
                     let updatedDictVal = origin.mutableCopy() as! NSMutableDictionary
                     updatedDictVal["mention_count"] = self.mentionC
                     // updatedDictVal["channelStatus"] = true
                     return Observable.just(updatedDictVal)
                 }
         }
     }
    
    
    func checkDBCount(){
        //let chatsDbcount = userdetails
          let chatsDbcount = persistanceService.fetchEntities("Channel", withPredicate: [], sortkey: nil, order: nil, limit: nil) as! [Channel]
        //print("chatsDbcount\(chatsDbcount.count)")
        userInfo = chatsDbcount
       // print("chatsDbcount\(userInfo)")

        if chatsDbcount.count == 0{
            self.showNoChatsLabel(chatCount: 0)
        }
        else{
            self.showNoChatsLabel(chatCount: 1)
        }
    }
    func showNoChatsLabel(chatCount : Int){
          let noChatLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.userListTableView.bounds.size.width, height: self.userListTableView.bounds.size.height))
          noChatLabel.textColor = UIColor.black
          noChatLabel.textAlignment = .center
          self.userListTableView.backgroundView = noChatLabel
          if chatCount == 0{
              noChatLabel.text = "No Chats"
          }
          else{
              noChatLabel.text = ""
          }
      }
    func scrollChatsTVTop(){
              //self.searchFilter.isActive = false
              chatTVScrollstoTop()
          }
    
    
    
        func chatTVScrollstoTop(){
               var numberofRows = 0
               if let sectionInfo = self.fetchedResultController.sections?[0] {
                   numberofRows = sectionInfo.numberOfObjects
               }
               DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
                   if numberofRows > 0 {
                       let lastRowIndexPath = IndexPath(row: 0, section: 0)
                 //self.tableView.scrollToRow(at: lastRowIndexPath as IndexPath, at: UITableView.ScrollPosition.bottom, animated: true)
                   }
               }
           }
    
    
    func fetchChannelInfo()
    {
        channelList = Datapresenter.fetchChannelInfo()!
        for dic in channelList{
            Time.append(dic.lastPost)
               // print("TimeTime\(Time)")
        }
                
    }
     
     func createDirectChannel(userId: String , userName: String) {
       // Utility.showLoader()
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
               //  return Alamofire.request(urlString, headers: header).rx.responseJSON()
                .map{ channelCreated in
                    return channelCreated
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
                    updatedDictVal["mention_count"] = 0
                    updatedDictVal["message_stat"] = 0
                 return self.service.getUserDetailss(with: updatedDictVal, with: userId)
                }
                .flatMap{ resp -> Observable<Any> in
                    self.directChatDictionary = resp as! NSDictionary
                 //print("directChatDictionary\(self.directChatDictionary)")
                    //self.Datapresenter.createChannelEntityFrom(dictionary: self.directChatDictionary as! [String : AnyObject])
                    return Observable.just(self.directChatDictionary)
                }
                .subscribe(onNext: { item in
                    print(item)
                },
                           onCompleted: {
                           // SVProgressHUD.dismiss()
                          
                            self.dismiss(animated: false, completion: {
                                
                            })
                            if self.isMessaging{
                             
                            }
                            else{
                              
                            }
                           
                            
                }).disposed(by: self.disposeBag)
        }
        else{
           // SVProgressHUD.dismiss()
           // showErrorMessage(errorTitle: "Network Error", errorMessage: "Please check your internet connection")
        }
    }
        
             

            
          
            func getUsername(with origin: NSDictionary) -> Observable<Any> {
                
               // print("original originval",origin)
                let name = origin["name"] as? String
                let userId = origin["id"] as? String
                let fullNameArr = name?.components(separatedBy: "__")
                let id1: String?
                let id2: String!
                if fullNameArr![0] == Utility.getmattermostUserId() {
                    id2 = fullNameArr![1]
                }
                else{
                    id2 = fullNameArr![0]
                }
             let getuser = Global.ServiceUrls.baseURL + Global.ServiceUrls.mattermostGetUsers
                let getAllUsers = getuser + id2
            // print("getAllUsers?\(getAllUsers)")
            var headers: HTTPHeaders = ["Authorization": "Bearer \(Global.Constants.Token)"]

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
                    .flatMap{ val -> Observable<Any> in
                        let json = val as? [String: Any] ?? [:]
                      //  print("jsonval",json)
                        self.singleUserArray.add(json)
                     self.Datapresenter.saveInCoreDataWith(array: self.singleUserArray as! [[String : AnyObject]])
                        self.userName = json["username"] as? String ?? "unknown"
                        let updatedDictVal = origin.mutableCopy() as! NSMutableDictionary
                        updatedDictVal.setValue(self.userName, forKey: "display_name")
                        updatedDictVal.setValue(id2, forKey: "userId")
                  //   print("updatedDictVal2\(updatedDictVal)")
                  //   print("updatedDictVal3\(self.singleUserArray)")

                        return Observable.just(updatedDictVal)
                }
            }
             
             
            





         func displayTime(timer : Int64) -> String
         {
             var date = Date(timeIntervalSince1970: (TimeInterval(timer/1000)))
             var dateFormatter = DateFormatter()
             dateFormatter.dateFormat = "d/MM,hh:mm"
             var splitDate = (dateFormatter.string(from: date)).components(separatedBy: ",")
             var theDate = dateFormatter.string(from: date)
             let today = NSDate()
             let updateDate = dateFormatter.date(from: theDate)!
             var formatteddate = dateFormatter.string(from: updateDate)

             return formatteddate
         }
          func noDuplicates(_ arrayOfDicts: [[String: Any]]) -> [[String: Any]] {
                 var noDuplicates = [[String: Any]]()
                 var usedNames = [String]()
                 for dict in arrayOfDicts {
                     if let name = dict["userId"], !usedNames.contains(name as! String) {
                         noDuplicates.append(dict)
                         usedNames.append(name as! String)
                     }
                 }
                 return noDuplicates
             }
    
    func checkdataPresent()
       {
           if let userdetaqls = AppDataManager.sharedInstance.fetchFromSharedPreference(key:Global.DatabaseKey.userdetails) as? [Dictionary<String, Any>]
                     {
                        act.stopAnimating()
                         startLoginAuthentication("asha.treesa@fingent.com", password: "Asha.treesa@#1234")
                      // userdetails = noDuplicates(userdetaqls)
                        //print("userdetails22\(userdetails)")
                         //print("userdetails=\(userdetails)")
                       //  self.userListTableView.reloadData()
                         }
                 //
                         if userdetails.count == 0
                         {
                           
                         
                         startLoginAuthentication("asha.treesa@fingent.com", password: "Asha.treesa@#1234")

                     }
                         else{
                            act.stopAnimating()
        }
                          
                        
                        self.navigationController?.navigationBar.isTranslucent = false
                       self.fetchedResultController.delegate = self
                 
           
                 
                 self.userListTableView.reloadData()
                 print("userdetaqls\(userdetails)")

//act.stopAnimating()
              
       }
    func initializationOfdarkAndLightModeUI()
           {
            if #available(iOS 12.0, *) {
                if self.traitCollection.userInterfaceStyle == .dark {
                    mainview.backgroundColor = UIColor.black
                    containerView.backgroundColor = UIColor.black
                } else {
                    mainview.backgroundColor = UIColor.white
                    containerView.backgroundColor = UIColor.white
                    
                }
            } else {
                // Fallback on earlier versions
            }
           }
}

extension Authviewcontroller : UITableViewDelegate,UITableViewDataSource{
    
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count :Int = 0
     
 if searchActive
       {
        self.searchBarfilter.becomeFirstResponder()
        uniquedetails = noDuplicates(searchstring)

        count = uniquedetails.count
       }
    else
       {
//        if let count = fetchedResultController.sections?.first?.numberOfObjects {
//            print("countcount\(count)")
//        }
        uniquedetails = noDuplicates(userdetails)
        //print("uniqueVals\(userdetails)")
        print("uniquedetails\(uniquedetails)\(userdetails)")

        self.searchBarfilter.resignFirstResponder()
     return uniquedetails.count
        }
        return count
       
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let cell = tableView.dequeueReusableCell(withIdentifier: "MessageTableViewCell", for: indexPath)as?MessageTableViewCell
        
        
        
     

        if searchActive
        {
          
            
             let userdetail = uniquedetails[indexPath.row]
            
            if let date = userdetail["last_post_at"]as?Int64
            {
                cell?.dateLabel.text = self.displayTime(timer:date)

             }
             
            if let lastMessage = userdetail["message"]as?String
            {
                cell?.lastMessage.text = lastMessage

             }
             if let profileName = userdetail["display_name"]as?String
             {
                cell?.profileName.text = profileName

             }
             

                       if  let userID = userdetail["userId"]as?String{
                        
                        if let employeeImageUrl = Datapresenter.getUserImageUrl(mattermostID: userID) as? String{
                                                   authpresenter.getUserImage(imageURL: employeeImageUrl, userId: userID) { (success, image) in
                                                       if success{
                                                           DispatchQueue.main.async {
                                                               cell?.profileImage.image = image
                                                           }
                                                       }else{
                                                           DispatchQueue.main.async {
                                                               cell?.profileImage.image = UIImage(named: "pro")
                                                           }
                                                       }
                                                   }
                                               }
                        else{
                        
                        
                                              Datapresenter.getImageFromDirectory(userID: userID) { (success, image) in
                                                  if success{
                                                    cell?.profileImage.image = image
                                                  }else{
                                                    cell?.profileImage.image = UIImage(named: "pro")
                                                  }
                                              }
                        }
                      
            }
            
            
        }
        else{
         self.configureChatCell(cell: cell!, atIndexPath: indexPath as IndexPath)
        }
        return cell!
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                    
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "chatViewcontroller") as! chatViewcontroller
        if searchActive {
            let userdetail = uniquedetails[indexPath.row]
           // print("userdetail1\(userdetail)")
            let channelId = userdetail["id"]as!String
            let type = userdetail["type"]as!String

            let profileNam = userdetail["display_name"]as!String
             let profileid = userdetail["userId"]as!String
            let msgCount = userdetail["total_msg_count"]as!Int
            let channeluserid = userdetail["name"]as?String
            
         
            if indexPath.row != nil
            {
                nextViewController.channelID = channelId
                nextViewController.channelStatusId = channeluserid

                nextViewController.profilename = profileNam
                nextViewController.userID = profileid
                nextViewController.msgCount = msgCount
                nextViewController.channelType = type
                 nextViewController.userProfileImage = userSearchedImageUrl
            }
            self.searchBarfilter.resignFirstResponder()
            userListTableView.reloadData()

        }
        else{
            let uservalue = channelArray1[indexPath.row]
           // print("userdetail12-\(uservalue)")
            let channelId = uservalue["id"] as? String
            let profileNam = uservalue["display_name"] as? String
            let profileid = uservalue["userId"] as? String
            let msgCount = uservalue["total_msg_count"] as? Int
            let type = uservalue["type"] as? String

            if indexPath.row != nil
            {
                if let profileNam = uservalue["display_name"] as? String
                           {
                               nextViewController.profilename = profileNam

                           }
                if let channelid = uservalue["id"] as? String
                           {
                    nextViewController.channelID = channelid

                           }
               if let channeluserid = uservalue["name"]as?String
               {
                nextViewController.channelStatusId = channeluserid
                }
                if let type = uservalue["type"] as? String
                                          {
            nextViewController.channelType = type

                                          }
                nextViewController.userID = profileid!
                nextViewController.msgCount = msgCount!
                nextViewController.userProfileImage = userSearchedImageUrl
            }
           // userListTableView.reloadData()

        }
             

    
       self.navigationController?.pushViewController(nextViewController, animated: true)

             
      
    }
    
    func configureChatCell(cell: MessageTableViewCell, atIndexPath indexPath: IndexPath) {
       
        
        if let nsArr = self.uniquedetails as? NSArray{
           //print("nsArrnsArr\(nsArr)")
           
            self.channelArray1 = (nsArr.sortedArray(using: [NSSortDescriptor(key: "last_post_at", ascending: false)]) as? Array<Dictionary<String,Any>>)!
                                                     }
       
        print("userdetail===\(channelArray1)0000\(userdetails)")

        
        let userdetail = channelArray1[indexPath.row]
        
        print("userdetail=\(userdetail)==\(channelArray1)")
       
        if let lastpost  = userdetail["last_post_at"]as? Int
        {
            cell.dateLabel.text = self.displayTime(timer:Int64((lastpost)))
           

        }
        
        if let lastMessage = userdetail["message"] as?String
       {
        cell.lastMessage.text = lastMessage

        }
        if let profileName = userdetail["display_name"] as? String
        {
            cell.profileName.text = profileName

        }
        
        

         if let userID = userdetail["userId"]as? String
         {

            Datapresenter.getImageFromDirectory(userID: userID) { (success, image) in
                                                           if success{
                                                             cell.profileImage.image = image
                                                           }else{
                                                             cell.profileImage.image = UIImage(named: "pro")
                                                           }
                                                       }
            
                        
                        if let employeeImageUrl = Datapresenter.getUserImageUrl(mattermostID: userID) as? String{
                            self.userSearchedImageUrl = employeeImageUrl
                            authpresenter.getUserImage(imageURL: employeeImageUrl, userId: userID) { (success, image) in
                           // print("success\(success)\(image)")
                                    if success{
                                    DispatchQueue.main.async {
                                        cell.profileImage.image = image
                                                        }
                                    }else{
                                        DispatchQueue.main.async {
                            cell.profileImage.image = UIImage(named: "pro")
                                                           }
                                                       }
                                                   }
                                               }
                        
                        
                        
                     
                      
            
            
        }
        
              
    }
   

}

