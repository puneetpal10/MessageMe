//
//  IncommingMessage.swift
//  MessageMe
//
//  Created by PuNeet on 30/12/20.
//  Copyright © 2020 dreamsteps. All rights reserved.
//

import Foundation
import MessageKit
import CoreLocation

class IncommingMessage {
    var messageCollectionView: MessagesViewController
    
    init(collectionView: MessagesViewController) {
        messageCollectionView = collectionView
    }
    
    //MARK: Create message
    
    func createMessage(localMessage: LocalMessage)-> MKMessage? {
        let mkMessage = MKMessage(message: localMessage)
        
        //Multimedia messages
        if localMessage.type == kPHOTO{
            let photoItem = PhotoMessage(path: localMessage.pictureUrl)
            mkMessage.photoItem = photoItem
            mkMessage.kind = MessageKind.photo(photoItem)
            
            FileStorage.downloadImage(localMessage.pictureUrl) { (image) in
                mkMessage.photoItem?.image = image
                self.messageCollectionView.messagesCollectionView.reloadData()
            }
        }
        
        if localMessage.type == kVIDEO{
            FileStorage.downloadImage(localMessage.pictureUrl) { (thumbNail) in
                FileStorage.downloadVideo(localMessage.videoUrl) { (readyToPlay, fileName) in
                    let videoUrl = URL(fileURLWithPath: fileInDocumentDirectory(fileName: fileName))
                    
                    let videoItem = VideoMessage(url: videoUrl)
                    mkMessage.videoItem = videoItem
                    mkMessage.kind = MessageKind.video(videoItem)
                }
                mkMessage.videoItem?.image = thumbNail
                self.messageCollectionView.messagesCollectionView.reloadData()
            }
        }
        
        
        if localMessage.type == kLOCATION{
            let locationItem = LocationMessage(location: CLLocation(latitude: localMessage.latitude, longitude: localMessage.longitude))
            mkMessage.kind = MessageKind.location(locationItem)
            mkMessage.locationItem = locationItem
        }
        
        return mkMessage
    }
}
