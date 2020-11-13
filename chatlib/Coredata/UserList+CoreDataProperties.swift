//
//  UserList+CoreDataProperties.swift
//  Chat
//
//  Created by Asha Treesa Kurian on 08/09/20.
//  Copyright © 2020 fingent. All rights reserved.
//
//

import Foundation
import CoreData


extension UserList {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserList> {
        return NSFetchRequest<UserList>(entityName: "UserList")
    }

    @NSManaged public var id: String?
    @NSManaged public var userName: String?
    @NSManaged public var role: String?
    @NSManaged public var updatedAt: String?
    @NSManaged public var deletedAt: String?
    @NSManaged public var email: String?
}
