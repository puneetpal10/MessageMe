//
//  RecentChat.swift
//  MessageMe
//
//  Created by PuNeet on 28/12/20.
//  Copyright © 2020 dreamsteps. All rights reserved.
//

import Foundation
import FirebaseFirestoreSwift


struct RecentChat:Codable {
    var id = ""
    var chatRoomId = ""
    var senderId = ""
    var senderName = ""
    var receiverId = ""
    var receiverName = ""
    @ServerTimestamp var date = Date()
    var memberIds = [""]
    var lastMessage = ""
    var unreadCount = 0
    var avatarLink = ""
    
    
    
}
