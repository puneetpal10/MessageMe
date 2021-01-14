//
//  MKMessage.swift
//  MessageMe
//
//  Created by PuNeet on 29/12/20.
//  Copyright © 2020 dreamsteps. All rights reserved.
//

import Foundation
import MessageKit
import CoreLocation

class MKMessage: NSObject, MessageType {
   
    var messageId: String
    var kind: MessageKind
    var sentDate: Date
    var mkSender: MKSender
    var sender: SenderType{return mkSender}
    var incomming: Bool
    var senderInitial: String
    
    var photoItem:PhotoMessage?
    var videoItem:VideoMessage?
    var locationItem:LocationMessage?
    
    
    var status:String
    var readDate: Date
    
    
    init(message: LocalMessage) {
        self.messageId = message.id
        self.mkSender = MKSender(senderId: message.senderId, displayName: message.senderName)
        self.status = message.status
        self.kind =  MessageKind.text(message.message)
        self.senderInitial = message.senderInitials
        self.sentDate = message.date
        self.readDate = message.readDate
        self.incomming = User.currentId != mkSender.senderId
        
        
        
        switch message.type {
        case kTEXT:
            self.kind = MessageKind.text(message.message)
        case kPHOTO:
            let photoItem = PhotoMessage(path: message.pictureUrl)
            self.kind = MessageKind.photo(photoItem)
            self.photoItem = photoItem
            
        case kVIDEO:
        let videoItem = VideoMessage(url: nil)
        self.kind = MessageKind.video(videoItem)
        self.videoItem = videoItem
        
            
        case kLOCATION:
            let locationItem = LocationMessage(location: CLLocation(latitude: message.latitude, longitude: message.longitude))
            self.kind = MessageKind.location(locationItem)
            self.locationItem = locationItem
            
        default:
            print("unknown message type")
        }
    }
    
}
