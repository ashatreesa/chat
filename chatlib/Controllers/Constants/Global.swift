//
//  Global.swift
//  Chat
//
//  Created by Asha Treesa Kurian on 27/08/20.
//  Copyright © 2020 fingent. All rights reserved.
//

import Foundation
import RxSwift
class Global: NSObject {
    
    
     static let sharedInstance = Global()

    enum ATTACHMENT_STATUS : String{
        case UPLOAD = "Upload"
        case UPLOADING = "Uploading"
        case UPLOADED = "Uploaded"
        case UPLOAD_ERROR = "UploadError"
        case DOWNLOAD = "Download"
        case DOWNLOADING = "Downloading"
        case DOWNLOADED = "Downloaded"
        case DOWNLOAD_ERROR = "DownloadError"
        case DELETED_MEDIA = "DeletedMedia"
    }

    struct Constants {
        static let Token :String = "ykbjgdgzaffi5mws9g5yo1hbaw"
        static let team_id :String = "1748cdhr9tdque9dw1inscorsy"
        static let TeamName :String = "mobile"
    }
    struct DatabaseKey {
        static let userid = "userid"
        static let token = "token"
        static let username = "username"
       static let appData = "appData"
      static let userlist = "userlist"
        static let userData = "userData"
        static let userdetails = "userdetails"
        static let messagelist = "messagelist"


    }
    struct ServiceUrls {
    
        
        
    static let baseURL: String = "https://mattermost-mobile.fingent.net/api/v4/"
    static let websocketURL: String = "wss://mattermost-mobile.fingent.net/api/v4/websocket"
        

    static let mattermostLoginAuthentication: String = "users/login"
    static let mattermostWedSocketAuthentication: String = "websocket"
    static let mattermostgetChannel: String = "teams/1748cdhr9tdque9dw1inscorsy/channels"
         static let mattermostchannelMsgs: String = "channels/"
         static let mattermostdirectchannel: String = "channels/direct"
         static let mattermostpostmessage: String = "posts"
                 static let mattermostmembers: String =  "channels/members/"
     
    static let mattermostLogoutAuthentication: String = "users/logout"
    static let mattermostGetUsers: String = "users/"
        static let mattermostGetUser: String = "users"

   static let mattermostGetteamMsg: String = "users/me/teams/"
    static let mattermostGetTeamUsers: String = "teams"
        
}
   
}
