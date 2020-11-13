//
//  AppDataManager.swift
//  Chat
//
//  Created by Asha Treesa Kurian on 24/08/20.
//  Copyright © 2020 fingent. All rights reserved.
//

import Foundation
import CoreData
enum Token: String{
    case sessionToken
}
class AppDataManager
{
    static let sharedInstance = AppDataManager()

    
        let userAccount = "chatSettings"
        
        // Arguments for the keychain queries
        let kSecClassValue = NSString(format: kSecClass)
        let kSecAttrAccountValue = NSString(format: kSecAttrAccount)
        let kSecValueDataValue = NSString(format: kSecValueData)
        let kSecClassGenericPasswordValue = NSString(format: kSecClassGenericPassword)
        let kSecAttrServiceValue = NSString(format: kSecAttrService)
        let kSecMatchLimitValue = NSString(format: kSecMatchLimit)
        let kSecReturnDataValue = NSString(format: kSecReturnData)
        let kSecMatchLimitOneValue = NSString(format: kSecMatchLimitOne)
    
    
        
        func saveInKeychain(value: String, key: Token) {
            let secureKey = "chat" + key.rawValue
            
            let dataFromString = value.data(using: .utf8)!
            
             //Instantiate a new default keychain query
            let keychainQuery: NSMutableDictionary = NSMutableDictionary(objects: [kSecClassGenericPasswordValue, secureKey, userAccount, dataFromString], forKeys: [kSecClassValue, kSecAttrServiceValue, kSecAttrAccountValue, kSecValueDataValue])
            
            let deleteQuery: NSMutableDictionary = NSMutableDictionary(objects: [kSecClassGenericPasswordValue, secureKey, userAccount, dataFromString], forKeys: [kSecClassValue, kSecAttrServiceValue, kSecAttrAccountValue, kSecValueDataValue])
            let deleteStatus = SecItemDelete(deleteQuery as CFDictionary)
            
            // Add the new keychain item
            let status = SecItemAdd(keychainQuery as CFDictionary, nil) as? OSStatus
            if #available(iOS 11.3, *) {
                let error = SecCopyErrorMessageString(status!, nil)
            } else {
                // Fallback on earlier versions
            }
            guard status == errSecSuccess else { return }
        }
    
    
  
        
        /**
         Retrieves data from keychain.
         
         - Parameter key: key used to fetch data from keychain.
         
         - Returns: Value fetched from keychain
         */
        func retriveFromKeychain(key: Token) -> String{
            let secureKey = "chat" + key.rawValue
            
            let keychainQuery: NSMutableDictionary = NSMutableDictionary(objects: [kSecClassGenericPasswordValue, secureKey, userAccount, kCFBooleanTrue, kSecMatchLimitOneValue], forKeys: [kSecClassValue, kSecAttrServiceValue, kSecAttrAccountValue, kSecReturnDataValue, kSecMatchLimitValue])
            var dataTypeRef:AnyObject?
            
            // Search for the keychain items
            let status: OSStatus = SecItemCopyMatching(keychainQuery, &dataTypeRef)
            var contentsOfKeychain: NSString? = ""
            
            if status == errSecSuccess {
                if let retrievedData = dataTypeRef as? NSData {
                    contentsOfKeychain = NSString(data: retrievedData as Data, encoding: String.Encoding.utf8.rawValue)
                }
            }else {
            }
           
            return contentsOfKeychain! as String
        }
 
  open func setUserDetails(_ value: NSDictionary) {
        //  Utility.clearStandardUserDefaults()
       
    }
 
    func fetchFromSharedPreference(key: String) -> Any? {
        let preferences = UserDefaults.standard
        
        let masterKey = "chatapp"
        
        if preferences.object(forKey: masterKey) == nil {
            return nil
        } else {
            
            
            guard let masterObj:Data = (preferences.object(forKey: masterKey) as? Data) else {
                return nil
            }
            let masterDict = NSKeyedUnarchiver.unarchiveObject(with: masterObj) as? Dictionary<String, Any>
            
            guard let value = masterDict![key] else {
                return nil
            }
            
            return value
        }
        
    }
    func saveInSharedPreference(key: String, value: Any) {
       
            let masterKey = "chatapp"
            
            let preferences = UserDefaults.standard

            var masterDict:Dictionary<String, Any>?
            
            if let dataFromDB = preferences.object(forKey: masterKey)  as? Data {

                masterDict = NSKeyedUnarchiver.unarchiveObject(with: dataFromDB) as? Dictionary<String, Any>
                //masterDict = dataFromDB as? Dictionary<String, Any>
            }
            else {
                masterDict = Dictionary<String, Any>()
            }
            masterDict![key] = value
            
        
            let encodedData = NSKeyedArchiver.archivedData(withRootObject: masterDict!)
            preferences.set(encodedData, forKey: masterKey)
            preferences.synchronize()

        }
    func GetAppData(key: String) -> Any? {
        if let appDataDict = fetchFromSharedPreference(key: Global.DatabaseKey.appData) as? Dictionary<String, Any> {
            if let appDataValue = appDataDict[key] {
                return appDataValue
            }
            else{
                return nil
            }
        }
        else{
            return nil
        }
    }
    
   

    
    
}
