//
//  Channel+CoreDataProperties.swift
//  Chat
//
//  Created by Asha Treesa Kurian on 30/09/20.
//  Copyright © 2020 fingent. All rights reserved.
//
//

import Foundation
import CoreData


extension Channel {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Channel> {
        return NSFetchRequest<Channel>(entityName: "Channel")
    }

    @NSManaged public var chanelMesageStatus: Int16
    @NSManaged public var createdAt: Int64
    @NSManaged public var deletedAt: Int64
    @NSManaged public var displayName: String?
    @NSManaged public var extraUpdate: Int16
    @NSManaged public var id: String?
    @NSManaged public var isShow: Bool
    @NSManaged public var lastMessage: String?
    @NSManaged public var lastPost: Int64
    @NSManaged public var messageCount: Int16
    @NSManaged public var name: String?
    @NSManaged public var teamId: String?
    @NSManaged public var type: String?
    @NSManaged public var updatedAt: Int64
    @NSManaged public var isChannelMember: Bool
    @NSManaged public var userId: String

    @NSManaged public var email: String
    @NSManaged public var profileimage: String?

    @NSManaged public var mentioncount: Int64

}
