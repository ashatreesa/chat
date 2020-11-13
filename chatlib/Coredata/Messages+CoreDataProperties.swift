//
//  Messages+CoreDataProperties.swift
//  Chat
//
//  Created by Asha Treesa Kurian on 30/09/20.
//  Copyright © 2020 fingent. All rights reserved.
//
//

import Foundation
import CoreData


extension Messages {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Messages> {
        return NSFetchRequest<Messages>(entityName: "Messages")
    }

    @NSManaged public var channelId: String?
    @NSManaged public var createdAt: Int64
    @NSManaged public var deleteAt: Int64
    @NSManaged public var editAt: Int64
    @NSManaged public var file_ids: [String]?
    @NSManaged public var file_names: [String]?
    @NSManaged public var filepath: [String]?
    @NSManaged public var filestatus: String?
    @NSManaged public var filethumbnails: [String]?
    @NSManaged public var hashtag: String?
    @NSManaged public var ispinned: Bool
    @NSManaged public var message: String?
    @NSManaged public var messageId: String?
    @NSManaged public var messageStatus: Int16
    @NSManaged public var messageType: String?
    @NSManaged public var originalId: String?
    @NSManaged public var parentId: String?
    @NSManaged public var pendingPostId: String?
    @NSManaged public var pushmessage: Bool
    @NSManaged public var rootId: String?
    @NSManaged public var updatedAt: Int64
    @NSManaged public var updateDate: Date?
    @NSManaged public var userId: String?

}
