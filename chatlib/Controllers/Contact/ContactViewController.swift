//
//  ContactViewController.swift
//  Chat
//
//  Created by Asha Treesa Kurian on 26/09/20.
//  Copyright © 2020 fingent. All rights reserved.
//

import UIKit
import Foundation

protocol ContactView : class {
func displayTime(timer : Int64) -> String
func noDuplicates(_ arrayOfDicts: [[String: Any]]) -> [[String: Any]]
    
    
}
class ContactViewController: UIViewController {

    var userList = Array<Dictionary<String,Any>>()
    var searchstring = Array<Dictionary<String,Any>>()
    var Datapresenter: DataPresenter!
    var authpresenter: AuthPresenter!
    var userSearchedImageUrl :String = ""
    var searchActive: Bool = false
    var UNIQUEVAL = Array<Dictionary<String,Any>>()
    
    @IBOutlet var containerView: UIView!
    
    @IBOutlet weak var mainView: UIView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var contactTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.contactTableView.tableFooterView = UIView()

         self.contactTableView.separatorColor = UIColor.gray
        Datapresenter = DataPresenter()
        authpresenter = AuthPresenter()

        searchBar.delegate = self
        if let useList = AppDataManager.sharedInstance.fetchFromSharedPreference(key:Global.DatabaseKey.userlist)as? [Dictionary<String, Any>]
              {
                  userList = useList
                  contactTableView.reloadData()
              }
        if userList.count > 0
        {
           print("lessthan0")
            
        }
        else{
            print("greater than 0")

        }
        if #available(iOS 12.0, *) {
            if self.traitCollection.userInterfaceStyle == .dark {
                mainView.backgroundColor = UIColor.black
                containerView.backgroundColor = UIColor.black
            } else {
                mainView.backgroundColor = UIColor.white
                containerView.backgroundColor = UIColor.white
                
            }
        } else {
            // Fallback on earlier versions
        }
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        
        if let useList = AppDataManager.sharedInstance.fetchFromSharedPreference(key:Global.DatabaseKey.userlist) as? [Dictionary<String, Any>]
        {
            userList = useList
            contactTableView.reloadData()
        }
    }

}
extension ContactViewController :ContactView{
   
    func displayTime(timer : Int64) -> String
    {
        var date = Date(timeIntervalSince1970: (TimeInterval(timer/1000)))
        var dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d/MM/yy,hh:mm a"
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
}
extension ContactViewController : UISearchBarDelegate
{
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        searchstring = userList.filter({
            
            let string = $0["display_name"] as! String
            return string.hasPrefix(searchText)
            
        })
        searchActive = true
        self.searchBar.becomeFirstResponder()

        contactTableView.reloadData()

    }
}
extension ContactViewController : UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count :Int = 0
    
        if searchActive
              {
               self.searchBar.becomeFirstResponder()
               UNIQUEVAL =  noDuplicates(searchstring)
               count = UNIQUEVAL.count
              }
                  else
              {
               self.searchBar.resignFirstResponder()
                UNIQUEVAL =  noDuplicates(userList)

               count = UNIQUEVAL.count
               }
               return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let cell = tableView.dequeueReusableCell(withIdentifier: "MessageTableViewCell", for: indexPath)as?MessageTableViewCell
        cell?.lastMessage.isHidden = true
        cell?.dateLabel.isHidden = true
        
        if searchActive
        {

                 let userdetail = UNIQUEVAL[indexPath.row]
                
                 
               
                 if let profileName = userdetail["display_name"]as?String
                 {
                    cell?.profileName.text = profileName

                 }
                 

                           if  let userId = userdetail["userId"]as?String{
                            if let employeeImageUrl = Datapresenter.getUserImageUrl(mattermostID: userId) as? String{
                            self.userSearchedImageUrl = employeeImageUrl
                        authpresenter.getUserImage(imageURL: employeeImageUrl, userId: userId) { (success, image) in
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
                                                  Datapresenter.getImageFromDirectory(userID: userId) { (success, image) in
                                                      if success{
                                                        cell?.profileImage.image = image
                                                      }else{
                                                        cell?.profileImage.image = UIImage(named: "pro")
                                                      }
                                                  }
                 }
                
                
            }else{
            let userdet = UNIQUEVAL[indexPath.row]
       if let userId = userdet["userId"]as?String
         {
           
           
             if let employeeImageUrl = Datapresenter.getUserImageUrl(mattermostID: userId) as? String{
                                                                   self.userSearchedImageUrl = employeeImageUrl
                                                                   authpresenter.getUserImage(imageURL: employeeImageUrl, userId: userId) { (success, image) in
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
            }
            cell?.profileName.text = userdet["display_name"] as?String
            
            }
            return cell!
            
            
        }
       
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
           return 60
       }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
     {
         
        

         let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                     
         let nextViewController = storyBoard.instantiateViewController(withIdentifier: "chatViewcontroller") as! chatViewcontroller
         if searchActive {
             let userdetail = UNIQUEVAL[indexPath.row]
           // print("searchstring\(searchstring)==\(userdetail)")
             let profileNam = userdetail["display_name"]as!String
             if indexPath.row != nil
             {
                 nextViewController.profilename = profileNam
                if let userId = userdetail["userId"]as?String
                         {
                          nextViewController.userID = userId

                           }
                           if let channelIdId = userdetail["id"]as?String
                                    {
                                     nextViewController.channelID = channelIdId

                                      }
                           if let totalcount = userdetail["total_msg_count"]as?Int
                                               {
                                                nextViewController.msgCount = totalcount

                                                 }
                           if let type = userdetail["type"]as?String
                                                          {
                                                           nextViewController.channelType = type

                                                            }
                if let channeluserid = userdetail["name"]as?String
                
                {
                 nextViewController.channelStatusId = channeluserid
                }
                nextViewController.userProfileImage = self.userSearchedImageUrl
                 
             }
        
             self.searchBar.resignFirstResponder()

         }
         else{
             let userdetail = UNIQUEVAL[indexPath.row]

             let profileNam = userdetail["display_name"]as!String
             if indexPath.row != nil
             {
                 nextViewController.profilename = profileNam
             }
            
            
           
               if let userId = userdetail["userId"]as?String
                {
                 nextViewController.userID = userId

                  }
                  if let channelIdId = userdetail["id"]as?String
                           {
                            nextViewController.channelID = channelIdId

                             }
                  if let totalcount = userdetail["total_msg_count"]as?Int
                                      {
                                       nextViewController.msgCount = totalcount

                                        }
                  if let type = userdetail["type"]as?String
                                                 {
                                                  nextViewController.channelType = type

                                                   }
           if let channeluserid = userdetail["name"]as?String
            
            {
             nextViewController.channelStatusId = channeluserid
            }
            nextViewController.userProfileImage = self.userSearchedImageUrl

         }
              

     
        self.navigationController?.pushViewController(nextViewController, animated: true)

              
       
     }
     
    
}
