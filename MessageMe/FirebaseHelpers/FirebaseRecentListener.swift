//
//  FirebaseRecentListener.swift
//  MessageMe
//
//  Created by PuNeet on 28/12/20.
//  Copyright © 2020 dreamsteps. All rights reserved.
//

import Foundation
import Firebase


class FirebaseRecentListener {
    static let shared = FirebaseRecentListener()
    
    private init() {}
    
    func downloadRecentChatFromFireStore(completion: @escaping(_ allRecent: [RecentChat])-> Void){
        FirebaseReference(.Recent).whereField(kSENDERID, isEqualTo: User.currentId).addSnapshotListener { (querySnapShot, error) in
            var recentChats: [RecentChat] = []
            guard let document = querySnapShot?.documents else {
                return
            }
            let allRecents = document.compactMap { (queryDocumentSnapShot) -> RecentChat? in
                return try? queryDocumentSnapShot.data(as: RecentChat.self)
            }
            for recent in allRecents{
                if recent.lastMessage != ""{
                    recentChats.append(recent)
                }
            }
            recentChats.sort(by: {$0.date! > $1.date!})
            completion(recentChats)
        }
    }
    
    func saveRecent(_ recent: RecentChat) {
        do{
            try FirebaseReference(.Recent).document(recent.id).setData(from: recent)
        }catch{
            print("error saving recent chat \(error.localizedDescription)")
        }
    }
    
    func delete(_ recent: RecentChat){
        FirebaseReference(.Recent).document(recent.id).delete()
    }
    
    func updateRecents(chatRoomId: String, lastMessage: String){
        FirebaseReference(.Recent).whereField(kCHATROOMID, isEqualTo: chatRoomId).getDocuments { (querySnapShot, error) in
            guard let documents = querySnapShot?.documents else {
                print("No document if recent update")
                return
            }
            
            let allRecents = documents.compactMap { (queryDocumentSnapshot) -> RecentChat? in
                return try? queryDocumentSnapshot.data(as: RecentChat.self)
            }
            for recentChat in allRecents{
                self.updateRecentItemWithNewMessage(recent: recentChat, lastMessage: lastMessage)
            }
        }
    }
    
    private func updateRecentItemWithNewMessage(recent: RecentChat, lastMessage: String){
        
        var tempRecent = recent
        
        if tempRecent.senderId != User.currentId{
            tempRecent.unreadCount += 1
        }
        
        tempRecent.lastMessage = lastMessage
        tempRecent.date = Date()
        
        self.saveRecent(tempRecent)
        
    }
    
    func clearUnreadCount(_ recent: RecentChat){
        var newRecent = recent
        newRecent.unreadCount = 0
        self.saveRecent(newRecent)
    }
    
    func resetRecentCounter(chatRoomId: String){
        FirebaseReference(.Recent).whereField(kCHATROOMID, isEqualTo: chatRoomId).whereField(kSENDERID, isEqualTo: User.currentId).getDocuments { (querySnapShot, error) in
            
            guard let documents = querySnapShot?.documents else {
                print("No documents for recent")
                return
            }
            
            let allRecents = documents.compactMap { (queryDocumentSnapshot) -> RecentChat? in
                return try? queryDocumentSnapshot.data(as: RecentChat.self)
            }
            
            if allRecents.count > 0{
                self.clearUnreadCount(allRecents.first!)
            }
            
        }
    }
    
}
