//
//  Employee+CoreDataProperties.swift
//  Chat
//
//  Created by Asha Treesa Kurian on 17/09/20.
//  Copyright © 2020 fingent. All rights reserved.
//
//

import Foundation
import CoreData


extension Employee {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Employee> {
        return NSFetchRequest<Employee>(entityName: "Employee")
    }

    @NSManaged public var id: String?
    @NSManaged public var address: String?
    @NSManaged public var address1: String?
    @NSManaged public var city: String?

}
