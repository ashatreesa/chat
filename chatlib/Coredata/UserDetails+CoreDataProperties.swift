//
//  UserDetails+CoreDataProperties.swift
//  
//
//  Created by Asha Treesa Kurian on 28/08/20.
//
//

import Foundation
import CoreData


extension UserDetails {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserDetails> {
        return NSFetchRequest<UserDetails>(entityName: "UserDetails")
    }

    @NSManaged public var email: String?
    @NSManaged public var password: String?
    @NSManaged public var userId: String?
    @NSManaged public var userName: String?

}
