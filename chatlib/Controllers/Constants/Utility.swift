//
//  Utility.swift
//  Chat
//
//  Created by Asha Treesa Kurian on 10/09/20.
//  Copyright © 2020 fingent. All rights reserved.
//

import Foundation
import Alamofire
import SystemConfiguration
import MobileCoreServices


class Utility: NSObject {

class func getHeader() -> HTTPHeaders {
    var headers : HTTPHeaders = [:]
    if  UserDefaults.standard.string(forKey: "mattermost_token") != nil
    {
       headers = [
            "Authorization": "Bearer \(UserDefaults.standard.string(forKey: "mattermost_token")!)",
            "Content-Type": "application/json"
        ]
    }
    return headers
}
    
    class func getmattermostUserId() -> String {
           var userId : String = ""
           if UserDefaults.standard.string(forKey: "mattermost_user_id") != nil
           {
               userId = UserDefaults.standard.string(forKey: "mattermost_user_id")!
           }
           return userId
       }
       class MessageDetails {
        var chatDetails     : NSDictionary?

          var channelInfo     : Channel?
          static var shared   = MessageDetails()
           var channelID       : String?
           var goToMessage     : Bool = false
           var lastMsg         : String?
           var navigatingFromNotification : Bool = false
           var navigateFromPush : Bool = false
           var messageID       : String?
       }
    func createFolder(folderName: String) -> URL? {
           let fileManager = FileManager.default
           // Get document directory for device, this should succeed
           if let documentDirectory = fileManager.urls(for: .documentDirectory,
                                                       in: .userDomainMask).first {
               // Construct a URL with desired folder name
               let folderURL = documentDirectory.appendingPathComponent(folderName)
               // If folder URL does not exist, create it
               if !fileManager.fileExists(atPath: folderURL.path) {
                   do {
                       // Attempt to create folder
                       try fileManager.createDirectory(atPath: folderURL.path,
                                                       withIntermediateDirectories: true,
                                                       attributes: nil)
                   } catch {
                       // Creation failed. Print error & return nil
                       print(error.localizedDescription)
                       return nil
                   }
               }
               // Folder either exists, or was created. Return URL
               return folderURL
           }
           // Will only be called if document directory not found
           return nil
       }
}
