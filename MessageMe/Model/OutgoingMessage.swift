//
//  OutgoingMessage.swift
//  MessageMe
//
//  Created by PuNeet on 29/12/20.
//  Copyright © 2020 dreamsteps. All rights reserved.
//

import Foundation
import UIKit
import FirebaseFirestoreSwift
import Gallery
class OutGoingMessage {
    
    class func send(chatId: String, text: String?, photo: UIImage?, video: Video?, audio: String?, audioDuration: Float = 0.0, location: String?, memberIds:[String]){
        
        let currentUser = User.currentUser!
        let message = LocalMessage()
        message.id = UUID().uuidString
        message.chatRoomId = chatId
        message.senderId = currentUser.id
        message.senderName = currentUser.userName
        message.senderInitials = String(currentUser.userName.first!)
        message.date = Date()
        message.status = kSENT
        
       
        
        if text != nil{
            //send text message
            sendTextMessage(message: message, text: text!, memberIds: memberIds)
            
        }
        
        if photo != nil{
            sendPictureMessage(message: message, photo: photo!, memberIds: memberIds)
        }
        
        if video != nil{
         sendVideoMessage(message: message, video: video!, memberIds: memberIds)
        }
        
        if location != nil{
            //send text message
            
            print("please send location \(LocationManager.shared.currentLocation)")
//            sendTextMessage(message: message, text: text!, memberIds: memberIds)
            
            sendLocationMessage(message: message, memberIds: memberIds)
            
        }
        
        
        FirebaseRecentListener.shared.updateRecents(chatRoomId: chatId, lastMessage: message.message)
        //TODO: send pushnotification
        //TODO: updat resent chat
    }
    
    
    class func sendMessage(message: LocalMessage, memberIds: [String]){
     
        RealmManager.shared.saveToRealm(message)
        for memberId in memberIds{
//            print("save message for ",memberId)
            FirebaseMessageListener.shared.addMessage(message: message, memberId: memberId)
        }
    }
}


func sendTextMessage(message: LocalMessage, text: String, memberIds:[String]){
    message.message = text
    message.type = kTEXT
    
    OutGoingMessage.sendMessage(message: message, memberIds: memberIds)
    
}


func sendPictureMessage(message: LocalMessage, photo: UIImage, memberIds:[String]){

    print("Sending picture message")
    message.message = "Picture message"
    message.type = kPHOTO
    
    let fileName = Date().stringDate()
    let fileDirectory = "MediaMessages/Photo/" + "\(message.chatRoomId)/" + "_\(fileName)" + ".jpg"
    FileStorage.saveFileLocally(fileData: photo.jpegData(compressionQuality: 0.6)! as NSData, fileName: fileDirectory)
    FileStorage.uploadImage(photo, directory: fileDirectory) { (imageUrl) in
        if imageUrl != nil{
            message.pictureUrl = imageUrl!
            
            OutGoingMessage.sendMessage(message: message, memberIds: memberIds)
        }
    }
}

func sendVideoMessage(message: LocalMessage, video: Video, memberIds:[String]){
    
    print(".....Sending video")
    message.message = "Video message"
    message.type = kVIDEO
    
    let fileName = Date().stringDate()
    let thumbNailDirectory = "MediaMessages/Photo/" + "\(message.chatRoomId)/" + "_\(fileName)" + ".jpg"
    
    let videoDirectory = "MediaMessages/Video/" + "\(message.chatRoomId)/" + "_\(fileName)" + ".mov"
    
    let editor = VideoEditor()
    editor.process(video: video) { (processedVideo, videoUrl) in
        if let tempPath = videoUrl{
            let thumbNail = videoThumbNail(video: tempPath)
            FileStorage.saveFileLocally(fileData: thumbNail.jpegData(compressionQuality: 0.7)! as NSData, fileName: fileName)
            
            
            FileStorage.uploadImage(thumbNail, directory: thumbNailDirectory) { (imageLink) in
                if imageLink != nil{
                    let videoData = NSData(contentsOfFile: tempPath.path)
                    
                    FileStorage.saveFileLocally(fileData: videoData!, fileName: fileName + ".mov")
                    
                    FileStorage.uploadVideo(videoData!, directory: videoDirectory) { (videoLink) in
                        message.pictureUrl = imageLink ?? ""
                        message.videoUrl = videoLink ?? ""
                        
                        
                        OutGoingMessage.sendMessage(message: message, memberIds: memberIds)

                        
                    }
                }
            }
        }
    }
    
}


func sendLocationMessage(message: LocalMessage, memberIds:[String]){

    let currentLocation = LocationManager.shared.currentLocation
    message.message = "Location message"
    message.type = kLOCATION
    message.latitude = currentLocation?.latitude ?? 0.0
    message.longitude = currentLocation?.longitude ?? 0.0
    
    
    OutGoingMessage.sendMessage(message: message, memberIds: memberIds)
}
