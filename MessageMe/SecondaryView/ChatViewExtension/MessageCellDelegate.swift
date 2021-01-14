//
//  MessageCellDelegate.swift
//  MessageMe
//
//  Created by PuNeet on 29/12/20.
//  Copyright © 2020 dreamsteps. All rights reserved.
//

import Foundation
import MessageKit
import AVKit
import AVFoundation
import SKPhotoBrowser

extension ChatViewController: MessageCellDelegate{
    
    func didTapImage(in cell: MessageCollectionViewCell) {
        if let indexPath = messagesCollectionView.indexPath(for: cell){
            let mkMessage = mkMessages[indexPath.section]
            if mkMessage.photoItem != nil && mkMessage.photoItem!.image != nil{
                //this is photo message
                print("photp")
                
                var images = [SKPhoto]()
                let photo = SKPhoto.photoWithImage(mkMessage.photoItem!.image!)
                images.append(photo)
                
                let browser = SKPhotoBrowser(photos: images)
                browser.initializePageIndex(0)
                present(browser, animated: true, completion: nil)
                
            }
            
            if mkMessage.videoItem != nil && mkMessage.videoItem!.url != nil{
                //this is video message
                print("video")
                
                let player = AVPlayer(url: mkMessage.videoItem!.url!)
                let moviePlayer = AVPlayerViewController()
                
                let session = AVAudioSession.sharedInstance()
                
                try! session.setCategory(.playAndRecord, mode: .default, options: .defaultToSpeaker)
                
                moviePlayer.player = player
                
                present(moviePlayer, animated: true) {
                    moviePlayer.player!.play()
                }
            }
        }
    }
    
    func didTapMessage(in cell: MessageCollectionViewCell) {
        print("Message tapped ")
        
        if let indexPath = messagesCollectionView.indexPath(for: cell){
            let mkMessage = mkMessages[indexPath.section]
            
            if mkMessage.locationItem != nil{
                let mapView = MapViewController()
                mapView.location = mkMessage.locationItem?.location
                
                navigationController?.pushViewController(mapView, animated: true)
            }
        }
    }
}
