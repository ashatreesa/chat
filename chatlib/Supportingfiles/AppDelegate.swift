//
//  AppDelegate.swift
//  Chat
//
//  Created by Asha Treesa Kurian on 19/08/20.
//  Copyright © 2020 fingent. All rights reserved.
//

import UIKit
import CoreData
import Alamofire
import Starscream
import RxSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    let service = Service()
      var window   : UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
   //service.startLoginAuthentication("asha.treesa@fingent.com", password: "Asha.treesa@#1234")
      
         
       
                      //  service.getChannels()
                     // service.getUsers()
        
        MattermostSocketManager.sharedInstance.establishConnection()
              SocketIOManager.sharedInstance.connectSocket { (success) in
                print("success\(success)")

              }
                  //self.fetchuserList()
        
        return true
    
    }

//    func applicationDidBecomeActive(_ application: UIApplication) {
//        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
//
//    }
//    // MARK: UISceneSession Lifecycle
//    func applicationDidEnterBackground(_ application: UIApplication) {
//        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
//        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
//    }
//    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
//        // Called when a new scene session is being created.
//        // Use this method to select a configuration to create the new scene with.
//        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
//    }


    
          

              

        
    
    
    
   

    

//    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
//        // Called when the user discards a scene session.
//        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
//        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
//    }



}


