//
//  chatViewcontroller.swift
//  Chat
//
//  Created by Asha Treesa Kurian on 16/09/20.
//  Copyright © 2020 fingent. All rights reserved.
//

import UIKit
import MobileCoreServices
import NotificationCenter
import Photos
import AVFoundation
import CoreData
import RxSwift
import Alamofire

protocol chatView : class
{
func noDuplicates(_ arrayOfDicts: [[String: Any]]) -> [[String: Any]]
func InitialisingUI()
func statuschecking()
func updateUserchatStatus()
func scrollTableViewToLastRow()
func getUserStatus(userId: String)
func getCurrentUserName()-> String
func currentTimeMillis() -> Int64
func displayTime(timer : Int64) -> String
func openCamera()
func openGallery()
func getdateofChat(updateDate : String) -> String
func openDocument()
func resetMentionCountinDB(channelId: String)
func getBeforeAfterMessages()
func getMessagesBefore(messageID : String, pageCount : Int)
}



class chatViewcontroller: UIViewController,UIDocumentPickerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate
{
    var authpresenter:AuthPresenter!
    var channelStatusId: String?
    var userProfileImage: String?
    var authview:Authviewcontroller!

    var disposeBag = DisposeBag()
    var timer = Timer()
    var statusTime: Int64 = 0
    var currentCellHeight: CGFloat = 0.0
    var isMessageTyping: Bool = false
    var test: Bool = false

    var currentUserId: String = ""
    var currentStatusText: String = ""
    var timeValue: TimeInterval = 5.0
    var userIdStatus: String = ""
       var msgBeforeLoading: Bool? = false
       var isTimerRunning: Bool = false
       var currentStatus: String = ""
       var myPickerController: UIImagePickerController!
       var profilename = ""
       var userID = ""
       var channelType = ""
       var Datapresenter: DataPresenter!
       var msgCount :Int = 0
       var channelID = ""
       var postDict : NSDictionary = [:]
       var service : Service!
       
     @IBOutlet weak var docAttach: UIButton!
     @IBOutlet weak var sndbtn: UIButton!
     @IBOutlet weak var activity: UIActivityIndicatorView!
    
    
    @IBOutlet weak var mainview: UIView!
    
    @IBOutlet weak var headerView: UIView!
    
     @IBOutlet weak var chatTableview: UITableView!
     @IBOutlet weak var profileName: UILabel!
     @IBOutlet weak var profilePicture: UIImageView!
     @IBOutlet weak var scrollButton: UIButton!
     @IBOutlet weak var chatTextfield: UITextView!
     @IBOutlet weak var bottomview: NSLayoutConstraint!
     @IBOutlet weak var msgtypingstatus: UILabel!
   
    @IBOutlet var containerView: UIView!
    
    
        override func viewDidLoad() {
              super.viewDidLoad()
           authpresenter = AuthPresenter()
           authview = Authviewcontroller()
            service = Service()
            Datapresenter = DataPresenter()
            self.chatTextfield.delegate = self
            chatTextfield.text = "Type a message"
            self.statuschecking()
             InitialisingUI()
          setNeedsStatusBarAppearanceUpdate()
            if #available(iOS 12.0, *) {
                if self.traitCollection.userInterfaceStyle == .dark {
                    containerView.backgroundColor = UIColor.black
                    mainview.backgroundColor = UIColor.black
                    headerView.backgroundColor = UIColor.black
                    
                    
                }
                else {
                    containerView.backgroundColor = UIColor.white
                    mainview.backgroundColor = UIColor.white
                    headerView.backgroundColor = UIColor.white
                    
                }
            } else {
                // Fallback on earlier versions
            }
          }
   
    override func viewWillAppear(_ animated: Bool) {
    
        self.fetchedResultController.delegate = self

       
        do {
                            try self.fetchedResultController.performFetch()
                            
                                } catch let error  {
                                }
                                   
                           self.getBeforeAfterMessages()
                            self.chatTableview.reloadData()
    

        

    }
    
     override func viewDidAppear(_ animated: Bool) {
     super.viewDidAppear(animated)
        self.fetchedResultController.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(self.messageTyping), name: Notification.Name.messageTyping, object: nil)
             
        
        NotificationCenter.default.addObserver(
              self,
              selector: #selector(self.keyboardWillShow(_:)),
              name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(
              self,
              selector: #selector(self.keyboardWillHide(_:)),
              name: UIResponder.keyboardWillHideNotification, object: nil)
        
             
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.fetchedResultController.delegate = nil
           self.msgBeforeLoading = false

          }
    
    override func viewWillDisappear(_ animated: Bool){
    super.viewWillDisappear(animated)
        self.msgBeforeLoading = false
        self.msgtypingstatus.text = ""
        self.view.endEditing(true)
        NotificationCenter.default.removeObserver(self, name:Notification.Name.messageTyping, object: nil)
       timer.invalidate()
    }
   
   
    @objc func messageTyping(notification: NSNotification) {
           self.isMessageTyping = true
           let userid = notification.userInfo!["user_id"] as! String
           let channelid = notification.userInfo!["channel_id"] as! String
        if channelid == self.channelID{
               let searchChannelType:NSPredicate = NSPredicate(format:"id == %@",channelid)
               let  channelDetails = persistanceService.fetchEntities("Channel", withPredicate: [searchChannelType], sortkey: nil, order: nil, limit: nil) as! [Channel]
               if channelDetails[0].type == "D"{
                   if currentUserId == userid{
                       self.currentStatusText = "typing..."
                       self.msgtypingstatus.text = self.currentStatusText
                       if isTimerRunning {
                           timer.invalidate()
                       }
                   }
                timer = Timer.scheduledTimer(timeInterval:self.timeValue, target: self,   selector: (#selector(self.updateTimerDirect)), userInfo: nil, repeats: false)
               }
           }
       }
    @objc func updateTimerDirect() {
          isTimerRunning  = true
          if self.currentStatus == "online"{
              self.currentStatusText = "online"
          }
          else{
              let lastSeen = self.displayTime(timer: (statusTime))
              self.currentStatusText = "last seen" + lastSeen
          }
    }
    
    
       
    @IBAction func docAction(_ sender: Any) {

        if chatTextfield.becomeFirstResponder(){
            
        }
        else{
            
        }
            let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
            let cameraImage = UIImage(named: "camera")
            let cameraImg = UIImageView()
            cameraImg.image = cameraImage
            cameraImg.frame =  CGRect(x: 25, y: 18, width: 24, height: 24)
            optionMenu.view.addSubview(cameraImg)
            
            let galleryImage = UIImage(named: "gallery")
            let galleryImg = UIImageView()
            galleryImg.image = galleryImage
            galleryImg.frame =  CGRect(x: 25, y: 75, width: 24, height: 24)
            optionMenu.view.addSubview(galleryImg)
            
        let documentImage = UIImage(named: "document")
             let documentImg = UIImageView()
             documentImg.image = documentImage
             documentImg.frame =  CGRect(x: 25, y: 132, width: 24, height: 24)
             optionMenu.view.addSubview(documentImg)
            
            let openCamera = UIAlertAction(title: "Camera", style: .default)   {
                action in
                self.openCamera()
            }
            let openGallery = UIAlertAction(title: "Photo Library", style: .default)   {
                action in
                self.openGallery()
            }
            let openDocument = UIAlertAction(title: "Document", style: .default)   {
                action in
                self.openDocument()
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
                (alert: UIAlertAction!) -> Void in
                //print("Cancelled")
            })
            optionMenu.addAction(openCamera)
            optionMenu.addAction(openGallery)
            optionMenu.addAction(openDocument)
            optionMenu.addAction(cancelAction)
            self.present(optionMenu, animated: true, completion: nil)
        }

       
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)

    }
      
    @IBAction func sendButtonAction(_ sender: Any) {
   
        
        scrollTableViewToLastRow()
        let text = self.chatTextfield.text!
             
    test = true

        
            let trimmed = text.trimmingCharacters(in: .whitespaces)
        let trimmedMsg = (trimmed as NSString).trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
              let time = self.currentTimeMillis()
              
              let uuid = UUID().uuidString
              
              let context = persistanceService.persistentContainer.viewContext
              let message = NSEntityDescription.insertNewObject(forEntityName: "Messages", into: context) as? Messages
              

              message?.channelId = self.channelID
              message?.messageId = "temp_"+uuid
              message?.message = trimmedMsg
              message?.updatedAt = time
              message?.createdAt = time
              message?.userId = Utility.getmattermostUserId()
              if ReachabilityManager.isInternetAvailable(){
                  message?.messageStatus = 1
              }
              else{
                  message?.messageStatus = 0
              }
              
        message?.updateDate = Datapresenter.displayTime(timer: time) as Date
              do{
                  try context.save()
                  self.chatTextfield.text = ""
                //  self.sndButton.isEnabled = false
                  PostManager.postInstance.state = false
                  PostManager.postInstance.addMessageToQueue(messageEntity: message!)
                   //if self.channelType == "D"{
                  
                let searchPredicate:NSPredicate = NSPredicate(format:"id == %@",self.channelID)
                  let chanelData = persistanceService.fetchEntities("Channel", withPredicate: [searchPredicate], sortkey: nil, order: nil, limit: nil)
                    
                  if chanelData.count != 0{
                      if let chanlVal = chanelData[0] as? Channel{
                          
                          if ReachabilityManager.isInternetAvailable(){
                              chanlVal.chanelMesageStatus = 2
                          }
                          else{
                              chanlVal.chanelMesageStatus = 1
                          }
                          chanlVal.isShow = true
                          chanlVal.lastMessage = trimmedMsg
                          chanlVal.lastPost = time
                          if self.channelType == "D"{
                              chanlVal.displayName = self.profilename
                          }
                          persistanceService.saveContext()
                          if let userIDNewChat = self.userID as? String{
                            ChatPresenter.chatPresenter.updateChannelPreferenceInDBandAPI(userId:userIDNewChat)
                            self.service.getChannels()

                          }
                          
                      }
                  }
              }catch{}
              
    }
    
    @IBAction func scrollbuttonAction(_ sender: Any) {
    self.scrollButton.isHidden = true
         var numberofRows = 0
         if let fetchedMsgs = self.fetchedResultController.fetchedObjects as? [Messages] {
             if fetchedMsgs.count != 0{
                 if let sectionInfo = self.fetchedResultController.sections?[0] {
                     numberofRows = sectionInfo.numberOfObjects
                 }
                 DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
                     if numberofRows > 0 {
                         let lastRowIndexPath = IndexPath(row: 0, section: 0)
                        self.chatTableview.scrollToRow(at: lastRowIndexPath as IndexPath, at: UITableView.ScrollPosition.top, animated: true)
                         //self.isLoadingMore = true
                     }
                 }
             }
         }
    
    
    
    
    }

      lazy var fetchedResultController: NSFetchedResultsController<NSFetchRequestResult> = {
          let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: Messages.self))
       // print("channelID123\(channelID)")
          fetchRequest.predicate = NSPredicate(format: "channelId == %@", self.channelID)
          let updateDate = NSSortDescriptor(key: "updateDate", ascending: false)
          let updateAtMilliSec = NSSortDescriptor(key: "createdAt", ascending: false)
          fetchRequest.sortDescriptors = [updateAtMilliSec]
          
          let frc = NSFetchedResultsController(
              fetchRequest: fetchRequest,
              managedObjectContext: persistanceService.persistentContainer.viewContext,
              sectionNameKeyPath: "updateDate",
              cacheName: nil)
          
          frc.delegate = self
          
          return frc
      }()
   
   
    @objc func keyboardWillHide(_ sender: Notification) {
           if let userInfo = (sender as NSNotification).userInfo {
            if let keyboardHeight = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size.height {
              
                //self.bottomview.constant = 0

                self.bottomview.constant =  0

                   UIView.animate(withDuration: 0.25, animations: { () -> Void in self.view.layoutIfNeeded() })
               }
           }
       }
       @objc func keyboardWillShow(_ sender: Notification) {
           if let userInfo = (sender as NSNotification).userInfo {
            if let keyboardHeight = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size.height {
              //  self.bottomview.constant = keyboardHeight - 75
                self.bottomview.constant = keyboardHeight

                   UIView.animate(withDuration: 0.25, animations: { () -> Void in
                       self.view.layoutIfNeeded()
                   })
               }
           }
       }
    
   
   
  
}
extension chatViewcontroller : chatView{
    
    
    
    func noDuplicates(_ arrayOfDicts: [[String: Any]]) -> [[String: Any]] {
                var noDuplicates = [[String: Any]]()
                var usedNames = [String]()
                for dict in arrayOfDicts {
                    if let name = dict[""], !usedNames.contains(name as! String) {
                        noDuplicates.append(dict)
                        usedNames.append(name as! String)
                    }
                }
                return noDuplicates
            }
    func InitialisingUI()
      {
        if userProfileImage != nil{
                      authpresenter.getUserImage(imageURL: self.userProfileImage!,userId: userID) { (success, image) in
                           if success{
                               DispatchQueue.main.async {
                                self.profilePicture.image = image
                               }
                           }
                       }
                   }
        chatTextfield.layer.cornerRadius = chatTextfield.frame.size.height/2
         chatTableview.transform = CGAffineTransform(rotationAngle: (-.pi))
          sndbtn.layer.cornerRadius = sndbtn.frame.size.height/2
          self.scrollButton.layer.cornerRadius = 20
          self.scrollButton.layer.masksToBounds = true
          self.scrollButton.isHidden = true
                
         profilePicture.layer.cornerRadius = 26
         
          
      self.profileName.text = profilename
          
      }
    
    func statuschecking()
    {
     if !isMessageTyping{
        // print("isMessageTyping\(isMessageTyping)")
         self.updateUserchatStatus()
     }
     }
    func updateUserchatStatus()  {
             if channelType == "D"{

                 if let statusId = channelStatusId?.components(separatedBy: "__"){
                     if statusId[0] == Utility.getmattermostUserId(){
                      // print("statusId[0]\(statusId[0])")

                         userIdStatus = statusId[1]
                         self.currentUserId = userIdStatus
                     }
                     else{
                      // print("statusId[0]\(currentUserId)")

                         userIdStatus = statusId[0]
                         self.currentUserId = userIdStatus
                     }
                 }
            getUserStatus(userId: self.currentUserId)
             }
         }
    
    func scrollTableViewToLastRow()
    {
        var numberofRows = 0
        if let fetchedMsgs = self.fetchedResultController.fetchedObjects as? [Messages] {
            //print("fetchedMsgs.count\(fetchedMsgs.count)")
            if fetchedMsgs.count != 0{
                if let sectionInfo = self.fetchedResultController.sections?[0] {
                    numberofRows = sectionInfo.numberOfObjects
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
                    if numberofRows > 0 {
                        //let lastRowIndexPath = IndexPath(row: numberofRows - 1, section: 0)
                        let lastRowIndexPath = IndexPath(row: 0, section: 0)
                        self.chatTableview.scrollToRow(at: lastRowIndexPath as IndexPath, at: UITableView.ScrollPosition.bottom, animated: true)
                        //self.isLoadingMore = true
                    }
                }
            }
        }
        
    }
    func getUserStatus(userId: String) {
             if ReachabilityManager.isInternetAvailable(){
                 let getUserStatus = Global.ServiceUrls.baseURL + Global.ServiceUrls.mattermostGetUsers
                 let getStatus = getUserStatus+userId+"/status"
                 return Alamofire.request(getStatus, headers: Utility.getHeader()).rx.responseJSON()
                     .map{ statusResp in
                         return statusResp
                     }
                     .filter{ originResp in
                         let orgResp = originResp as! NSDictionary
                         //print("orgResporgResp\(orgResp)")
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
                     .flatMap{ statusItem -> Observable<Any> in
                         let item = statusItem as? NSDictionary
                         let status = item!["status"] as? String
                         self.currentStatus = status!
                         let last_activity_at = item!["last_activity_at"] as! Int64
                         self.statusTime = last_activity_at
                         if status == "online"{
                             self.currentStatusText = "online"
                         self.msgtypingstatus.text = self.currentStatusText
                         }
                         else{
                             let lastSeen = self.displayTime(timer: (last_activity_at))
                             self.currentStatusText = "last seen " + lastSeen
                         self.msgtypingstatus.text = self.currentStatusText
                         }
                         return Observable.just(item)
                     }
                     .subscribe(onNext: { item in
                     },
                                onError: { error in
                     },
                                
                                onCompleted: {
                     }).disposed(by: disposeBag)
             }
             else{
                 print("Network Error")
             }
         }
    func getCurrentUserName()-> String{
         if let firstname = UserDefaults.standard.string(forKey: "first_name") as? String{
             if let lastname = UserDefaults.standard.string(forKey: "last_name")  as? String{
                 let fullName = firstname + " " + lastname
                 return fullName
             }
             return firstname
         }
         return "You"
     }
    
         func currentTimeMillis() -> Int64{
             let nowDouble = NSDate().timeIntervalSince1970
             return Int64(nowDouble*1000)
         }
      //MARK:- Display time in different formats
       func displayTime(timer : Int64) -> String
       {
           var date = Date(timeIntervalSince1970: (TimeInterval(timer/1000)))
           var dateFormatter = DateFormatter()
           dateFormatter.dateFormat = "EE,d/MM/yyyy,hh:mm a"
           var splitDate = (dateFormatter.string(from: date)).components(separatedBy: ",")
           var theDate = dateFormatter.string(from: date)
           let today = NSDate()
           let updateDate = dateFormatter.date(from: theDate)!
           let calendar = NSCalendar.current
           let flags = NSCalendar.Unit.day
           let components = calendar.dateComponents([.day], from: updateDate, to: today as Date)
           if calendar.isDateInYesterday(updateDate)
           {
               theDate = splitDate[2]
           }
           else if calendar.isDateInToday(updateDate)
           {
               theDate = splitDate[2]
           }
           else
           {
               var dateFormatter1 = DateFormatter()
               dateFormatter1.dateFormat = "EE,MMM d,hh:mm a"
               
               print(dateFormatter1.string(from: date))
               var splitDate1 = (dateFormatter1.string(from: date)).components(separatedBy: ",")
               if (components.day! != 0 )
               {
                   theDate = splitDate1[1] + " ," + splitDate1[2]
               }
           }
           return theDate
       }

      func openCamera(){
             
             let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
             
             switch cameraAuthorizationStatus {
             case .notDetermined:
                 AVCaptureDevice.requestAccess(for: .video, completionHandler: {accessGranted in
                     guard accessGranted == true else { return }
                     if UIImagePickerController.isSourceTypeAvailable(.camera){
                         self.myPickerController = UIImagePickerController()
                         self.myPickerController.allowsEditing = false
                         self.myPickerController.delegate = self
                         self.myPickerController.sourceType = .camera
                      self.myPickerController.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext

                         self.present(self.myPickerController, animated: true, completion: nil)
                     }
                 })
             case .authorized:
                 if UIImagePickerController.isSourceTypeAvailable(.camera){
                     myPickerController = UIImagePickerController()
                     myPickerController.allowsEditing = false
                     myPickerController.delegate = self
                     myPickerController.sourceType = .camera
                  self.myPickerController.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
                     present(myPickerController, animated: true, completion: nil)
                 }
             case .restricted, .denied:
              let settingsAppURL = URL(string: UIApplication.openSettingsURLString)!
                 
                 let alert = UIAlertController(
                     title: "App does not have access to your camera. To enable access, tap Settings and turn on Camera",
                     message: "",
                     preferredStyle: UIAlertController.Style.alert
                 )
                 
                 
                 alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { (alert) -> Void in
                     UIApplication.shared.open(settingsAppURL, options: [:], completionHandler: nil)
                 }))
                 alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
              myPickerController.view.backgroundColor = .clear

              self.myPickerController.modalPresentationStyle = .overFullScreen
                 present(alert, animated: true, completion: nil)
             }
             
             
         }
    
         func openGallery(){
             let photos = PHPhotoLibrary.authorizationStatus()
             switch photos {
             case .authorized:
                 if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
                     myPickerController = UIImagePickerController()
                     myPickerController.delegate = self
                     myPickerController.allowsEditing = false
                     myPickerController.sourceType = .photoLibrary
                  
                  myPickerController.view.backgroundColor = .clear
                  self.myPickerController.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
                     present(myPickerController, animated: true, completion: nil)
                 }
                 else{
                     
                 }
             case .denied, .restricted:
              let settingsAppURL = URL(string: UIApplication.openSettingsURLString)!
                 
                 let alert = UIAlertController(
                     title: "",
                     message: "",
                     preferredStyle: UIAlertController.Style.alert
                 )
                 
                 alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { (alert) -> Void in
                     UIApplication.shared.open(settingsAppURL, options: [:], completionHandler: nil)
                 }))
                 alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                 
                 present(alert, animated: true, completion: nil)
             case .notDetermined:
                 PHPhotoLibrary.requestAuthorization({ (newStatus) in
                     
                     if (newStatus == PHAuthorizationStatus.authorized) {
                         if UIImagePickerController.isSourceTypeAvailable(.camera){
                             self.myPickerController = UIImagePickerController()
                             self.myPickerController.allowsEditing = false
                             self.myPickerController.delegate = self
                             self.myPickerController.sourceType = .camera
                          self.myPickerController.view.backgroundColor = .clear

                          self.myPickerController.modalPresentationStyle = .overFullScreen
                          
                             self.present(self.myPickerController, animated: true, completion: nil)
                         }
                     }
                         
                     else {
                         
                     }
                 })
                 
                 
             }
         }
      
      func getdateofChat(updateDate : String) -> String
      {
          let dateFormatter = DateFormatter()
          let splitDate = updateDate.components(separatedBy: " ")
          dateFormatter.dateFormat = "yyyy-MM-dd"
          dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
          let yourDate = dateFormatter.date(from: splitDate[0])
          let dateFormatter1 = DateFormatter()
          dateFormatter1.dateFormat = "dd/MM/yy"
          dateFormatter1.timeZone = TimeZone(abbreviation: "UTC")
          let theDate = dateFormatter1.string(from:yourDate!)
          let calendar = NSCalendar.current
          if calendar.isDateInYesterday(yourDate!)
          {
              let yesterday = "Yesterday"
              return (yesterday)
          }
          else if calendar.isDateInToday(yourDate!)
          {
              let today = "Today"
              return (today)
          }
          else {
              return (theDate)
          }
      }
      
         func openDocument(){
             let controller = UIDocumentPickerViewController(documentTypes: ["public.text","public.data","public.content"],in: .import)
             controller.delegate = self
            if #available(iOS 11.0, *) {
                controller.allowsMultipleSelection = false
            } else {
                // Fallback on earlier versions
            }
          controller.modalPresentationStyle = .overFullScreen
             present(controller,animated: true,completion: nil)
         }
    func resetMentionCountinDB(channelId: String){
           do{
               let searchPredicate:NSPredicate = NSPredicate(format:"id == %@",channelId)
            
               let postList = persistanceService.fetchEntities("Channel", withPredicate: [searchPredicate], sortkey: nil, order: nil, limit: nil) as! NSArray
               do{
                   if postList.count != 0, let postInfo = postList[0] as? Channel{
                       postInfo.mentioncount = 0;                    persistanceService.saveContext()
                       ChatPresenter.chatPresenter.updateChatTabCount()
                   }
               }
               catch let error {
                   print("ERROR DELETING : \(error)")
               }
           }
       }
    func getBeforeAfterMessages() {
              let chanelPred = NSPredicate(format:"channelId == %@",self.channelID)
              let msgPredicate = NSPredicate(format: "NOT messageId BEGINSWITH 'temp'")
              let fileMessagePredicate = NSPredicate(format: "NOT messageId BEGINSWITH 'attachment'")
              let msgPred = NSCompoundPredicate(type: .and, subpredicates: [chanelPred, msgPredicate, fileMessagePredicate])
              let msgData = persistanceService.fetchEntities("Messages", withPredicate: [msgPred], sortkey: nil, order: nil, limit: nil)
           //print("lastPostID1\(msgData)")

              if msgData.count != 0, let lastPost = msgData[msgData.count - 1] as? Messages{
                  if let lastPostID = lastPost.messageId {
                     // print(lastPost.message, "Before & After Call from this Message")
                   //print("lastPostID\(lastPostID)")
                   ChatPresenter.chatPresenter.getMessagesBefore(messageID: lastPostID, pageCount: 60, displayName: self.profilename, channelid: self.channelID)
                      
                    ChatPresenter.chatPresenter.getMessagesAfter(messageID: lastPostID, pageCount: 60, displayName: self.profilename, channelid :self.channelID)
                  // self.chatTableview.reloadData()
                  }
              }else{
                  
              }
          }
      
      
      func getMessagesBefore(messageID : String, pageCount : Int){
       ChatPresenter.chatPresenter.getMessagesofChannelBefore(with: (channelID as? String)!, with: messageID, with: pageCount)
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
                          if orders.count == 0{
                              self.msgBeforeLoading = true
                          }
                          self.Datapresenter.parseMessageObject(messageResponse: myDictionary, orders: orders, channelDisplayName: self.profilename)
                      }
                  }
                  return Observable.just(messageResponse)
              }
              .subscribe(onNext: { item in
              },
                         onError: { error in
                          print(error)
                         // self.loadingView.isHidden =  true
                          //self.loadingLabel.isHidden = true
                          
              },
                         onCompleted: {
                         // self.loadingView.isHidden =  true
                         // self.loadingLabel.isHidden = true
              }).disposed(by: disposeBag)
      }
}
extension chatViewcontroller:UIScrollViewDelegate
{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
           let scrollOffset = chatTableview.contentOffset.y;
           if (scrollOffset == 0)
           {
               self.scrollButton.isHidden = true
           }
           else  if (scrollOffset > self.currentCellHeight){
           self.scrollButton.isHidden = false
           }
           else{
              self.scrollButton.isHidden = true
           }
       }

       
       func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
           
           //--> UITableView only moves in one direction, y axis
           let currentOffset = chatTableview.contentOffset.y
           let maximumOffset = chatTableview.contentSize.height - chatTableview.frame.size.height
           // Change 10.0 to adjust the distance from bottom
           if maximumOffset - currentOffset <= 10.0 {
            
               if let fetchedMsgs = self.fetchedResultController.fetchedObjects as? [Messages] {
                   if fetchedMsgs.count > 10{
                       if let lastPost = fetchedMsgs[fetchedMsgs.count - 1] as? Messages{
                           if let lastPostID = lastPost.messageId {
                               if !self.msgBeforeLoading!{
                                   //loadingView.isHidden =  false
                                   //loadingLabel.isHidden = false
                                   self.chatTableview.tableFooterView?.tintColor = UIColor.black
                       self.getMessagesBefore(messageID: lastPostID, pageCount: 50)
                               }
                           }
                       }
                   }
               }
           }
       }
}
extension chatViewcontroller: UITableViewDelegate,UITableViewDataSource
{
func numberOfSections(in tableView: UITableView) -> Int {
       if let sections = fetchedResultController.sections {
       // print("sections\(sections)")
           return sections.count
       }
       return 0
   }

    
      func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
          if let sections = fetchedResultController.sections {
              let currentSection = sections[section]
           // print("currentSection.numberOfObjects\(currentSection.numberOfObjects)")
              return currentSection.numberOfObjects
          }
          return 0
          
      }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let customView = UIView(frame: CGRect(x: 0, y: 0, width: self.chatTableview.bounds.width, height: 50))
        customView.backgroundColor = UIColor.clear
        let label1 = UILabel()
        label1.frame.size.height = 28
        label1.frame.size.width  = self.chatTableview.frame.width * 0.35
        label1.textAlignment = .center
        label1.center = customView.center
        label1.font = UIFont.systemFont(ofSize: 12.0, weight: .semibold)
        label1.backgroundColor = UIColor(red: 200/255, green: 230/255, blue: 259/255, alpha: 1.0)
        label1.textColor = UIColor.darkGray
        label1.clipsToBounds = true
        label1.layer.cornerRadius = 15
        if let sections = fetchedResultController.sections {
            let currentSection = sections[section]
            if let myDate =  currentSection.name as? String{
                if !myDate.isEmpty{
                    label1.text = getdateofChat(updateDate : myDate)
                }
            }
        }
        customView.addSubview(label1)
        customView.transform = CGAffineTransform(rotationAngle: 3.14285)
        return customView
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
           return 50
       }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           var fileIDs : [String] = []
                var fileNames: [String] = []
                  let message = fetchedResultController.object(at: indexPath) as? Messages
                if let file_ids = message?.file_ids{
                 // print("file_ids12123\(file_ids)")
                  fileIDs = file_ids
                  let fileName = message?.file_names
                  fileNames = fileName!
              }
        if message?.userId == Utility.getmattermostUserId()
               {
                if fileIDs.count > 0{
              
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "senderImgcell") as! senderImgcell
               // self.configureSenderImageCell(cell: cell, atIndexPath: indexPath as NSIndexPath)
                cell.backgroundColor = UIColor.clear
                cell.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI));
                
                cell.senderAttachmentView.frame.size.width = cell.senderTime2.frame.width
                Datapresenter.getImageFromDirectory(userID: (message?.userId)!) { (success, image) in
                if success{
                    cell.senderImageView.image = image
                }else{
                cell.senderImageView.image = UIImage(named: "user_default")
                }
                }
                    return cell
               
        }
                else
                {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "chatCell") as! chatCell
                    cell.time.text = displayTime(timer: (message?.createdAt )!)
                   // print("cell.time.text\(cell.time.text)")
                    if cell.time.text != ""
                   {
                  self.configureSystemCell(cell: cell, atIndexPath: indexPath as NSIndexPath)
                    }
                    cell.transform = CGAffineTransform(rotationAngle: (-.pi))
                   return cell
                }
        
        
        
    }
        else
        {
               if fileIDs.count > 0{
                                       let cell = tableView.dequeueReusableCell(withIdentifier: "receiverImgCell") as! receiverImgCell
                                    self.configureReceiverImageCell(cell: cell, atIndexPath: indexPath as NSIndexPath)
                                        cell.backgroundColor = UIColor.clear
                                       cell.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI))
          
        }
            else
               {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "receiverCell") as! receiverCell
            self.configureReceiverCell(cell: cell, atIndexPath: indexPath as NSIndexPath)
                                         cell.backgroundColor = UIColor.clear
               // print("message?.message\(message?.message)===\(message?.message)")
                   cell.receivermsg.text = message?.message
                 cell.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI))
              cell.receiverTime.text = displayTime(timer: (message?.createdAt)!)
                return cell
              
            }
            return UITableViewCell()

        }
    }
 func configureSystemCell(cell: chatCell, atIndexPath indexPath: NSIndexPath)
       {
       // print("(cellcell")

           let entity = self.fetchedResultController.object(at: indexPath as IndexPath) as! Messages
      
           if entity.message != nil{
           // print("entity.message1\(entity.message)")
                     let messageWidth =  getWidth(text: entity.message!)
            
            if UIDevice.current.userInterfaceIdiom == .pad
            {
                if messageWidth >= 400
                           {
                               cell.containerviewWidthconstrain.constant = CGFloat(550)

                           }
                           else if messageWidth <= 90{
                               //print("entity.message1\(entity.message)")

                               cell.containerviewWidthconstrain.constant = CGFloat(100)

                            
                              
                               
                           } else{
                                   cell.containerviewWidthconstrain.constant = messageWidth + 30
                                               }

            }else
            {
                if messageWidth >= 300
                           {
                               cell.containerviewWidthconstrain.constant = CGFloat(300)

                           }
                           else if messageWidth <= 90{
                               print("entity.message1\(entity.message)")

                               cell.containerviewWidthconstrain.constant = CGFloat(100)

                             
                               
                           } else{
                                   cell.containerviewWidthconstrain.constant = messageWidth + 30
                                               }

            }
           

            cell.chatLabel?.text = entity.message!
          
      
          
           
           }
       }
       
    
    
    
    
    func configureReceiverCell(cell: receiverCell, atIndexPath indexPath: NSIndexPath)
       {
           let entity = self.fetchedResultController.object(at: indexPath as IndexPath) as! Messages
       // print("entity.message\(entity.messageStatus)==\(entity.message)")

           if entity.message != ""{
            let messagewidth =  getWidth(text: entity.message!)
                 
                      if UIDevice.current.userInterfaceIdiom == .pad
                      {
                          if messagewidth >= 500
                                     {
                                         cell.containerviewWidthconstrain.constant = CGFloat(550)

                                     }
                                     else if messagewidth <= 90{
                                       
                                         cell.containerviewWidthconstrain.constant = CGFloat(120)

                                      
                                         
                                     } else{
                                             cell.containerviewWidthconstrain.constant = messagewidth + 30
                                                         }

                      }else
                      {
                          if messagewidth >= 300
                                     {
                                         cell.containerviewWidthconstrain.constant = CGFloat(300)

                                     }
                                     else if messagewidth <= 90{
                                         //print("entity.message1\(entity.message)")

                                         cell.containerviewWidthconstrain.constant = CGFloat(100)

                                     
                                     } else{
                                             cell.containerviewWidthconstrain.constant = messagewidth + 30
                                                         }

                      }
               cell.receivermsg.text = entity.message
              // cell.receivermsg?.text = self
               //  tapping.cancelsTouchesInView = false
              // cell.receivrMsgView.sizeToFit()
             //  let labelWidth = cell.receivermsg.frame.width
             
           // cell.receivermsg.sizeToFit()
          //     if indexPath.row == 0{
                 //  let maxLabelWidth: CGFloat = self.chatTableview.frame.width
                   //let neededSize = cell.receivermsg.sizeThatFits(CGSize(width: maxLabelWidth, height: CGFloat.greatestFiniteMagnitude))
                   //self.currentCellHeight = neededSize.height
                 
                              // }
           }
       }
     func getWidth(text: String) -> CGFloat
    {
        let txtField = UITextField(frame: .zero)
        txtField.text = text
        txtField.sizeToFit()
        //print("txtField.frame.size.width\(txtField.frame.size.width)")
        return txtField.frame.size.width
    }
       
       func configureReceiverImageCell(cell: receiverImgCell, atIndexPath indexPath: NSIndexPath)
       {
        
    }
 

         
}
extension chatViewcontroller :UITextViewDelegate
{
    func textViewDidBeginEditing(_ textView: UITextView) {
       
            chatTextfield.text = nil
            chatTextfield.textColor = UIColor.black
        
    }
    func textViewDidChange(_ textView: UITextView) {
           if self.chatTextfield.text == ""{
               self.sndbtn.isEnabled = false
               self.sndbtn.isUserInteractionEnabled = false
           }
           else{
               let str = self.chatTextfield.text
               let trimmedString = str?.trimmingCharacters(in: .whitespaces)
               let trimStr = trimmedString?.trimmingCharacters(in: .newlines)
               if trimStr != ""{
                   self.sndbtn.isEnabled = true
                   self.sndbtn.isUserInteractionEnabled = true
               }
             let jsonDict =  ["action": "user_typing","seq": 2,"data": ["channel_id": self.channelID,"parent_id": ""]] as [String : Any]
               MattermostSocketManager.sharedInstance.writeToSocket(passedJSON: jsonDict)
               
           }
       }
     

     func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
         if text.contains(UIPasteboard.general.string ?? "") {
             let fixedWidth = chatTextfield.frame.size.width
             let newSize = chatTextfield.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
             if newSize.height < 40 && newSize.height < 120{
                // self.txtviewHeight.constant = newSize.height + 40
                 //self.bottomViewHeight.constant = newSize.height + 60
                 self.view.layoutIfNeeded()
             }
             
         }else{
             let fixedWidth = chatTextfield.frame.size.width
             let newSize = chatTextfield.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
             if newSize.height > 40 && newSize.height < 120{
                // self.txtviewHeight.constant = newSize.height
                // self.bottomViewHeight.constant = newSize.height + 20
                 self.view.layoutIfNeeded()
             }
         }
         return true
     }

}
extension chatViewcontroller :NSFetchedResultsControllerDelegate
{


         func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
             switch type {
             case .insert:
                 chatTableview.insertSections(IndexSet(integer: sectionIndex), with: .fade)
             case .delete:
                 chatTableview.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
             case .move:
                 break
             case .update:
                 break
             }
         }
       func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {

           switch type {
           case .insert:
               self.chatTableview.insertRows(at: [newIndexPath!], with: .none)

           case .update:
               let cell = self.chatTableview.cellForRow(at: indexPath!)
               if let chatCell = cell as? chatCell {

                   self.configureSystemCell(cell: chatCell , atIndexPath: indexPath! as NSIndexPath)
               }
               else if let senderImgCell = cell as? senderImgcell {
                   self.chatTableview.reloadRows(at: [indexPath!], with: .none)
                  // self.configureSenderImageCell(cell: senderImgCell, atIndexPath: indexPath as! NSIndexPath)
               }
           else if let senderCell = cell as? receiverCell {
                   self.chatTableview.reloadRows(at: [indexPath!], with: .none)
               }else if let receiverImgCell = cell as? receiverImgCell {
                   self.configureReceiverImageCell(cell: receiverImgCell , atIndexPath: indexPath! as NSIndexPath)
               }

               /*case .delete:
                self.messagesTV.deleteRows(at: [indexPath!], with: .none)*/
           default:
               break

           }
       }
       
     func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.chatTableview.beginUpdates()
     }
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
       self.chatTableview.endUpdates()
    }
}
extension chatViewcontroller : UITextFieldDelegate{
    
     func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        chatTextfield.resignFirstResponder()
        bottomview.constant = 0
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        chatTextfield.resignFirstResponder()
        bottomview.constant = 0
       self.view.endEditing(true)
    }
    
    
    
}
    

    
    
    
    
    
    

extension Date {
    
    static func getCurrentDate() -> String {
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "dd-MM HH:mm"
        
        return dateFormatter.string(from: Date())
        
    }
}
extension Notification.Name {
    public static let messageTyping = Notification.Name("messageTyping")
   
}
