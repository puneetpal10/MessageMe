//
//  FirebaseMessageListener.swift
//  MessageMe
//
//  Created by PuNeet on 30/12/20.
//  Copyright © 2020 dreamsteps. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

class FirebaseMessageListener {
    
    static let shared = FirebaseMessageListener()
    
    var newChatListener: ListenerRegistration!
    var updateChatListener: ListenerRegistration!
    
    
    private init() {}
    
    
    func listenForNewChats(documentId: String,collectionId: String, lastMessageDate: Date){
        newChatListener = FirebaseReference(.Messages).document(documentId).collection(collectionId).whereField(kDATE, isGreaterThan: lastMessageDate).addSnapshotListener({ (querySnapShot, error) in
            
            guard let snapShot = querySnapShot else {
                return
            }
            
            for change in snapShot.documentChanges{
                if change.type == .added {
                    
                    let result = Result{
                        try? change.document.data(as: LocalMessage.self)
                    }
                    
                    switch result {
                    case .success(let messageObject):
                        if let message = messageObject{
                            if message.senderId != User.currentId{
                                RealmManager.shared.saveToRealm(message)
                            }
                        }else{
                            print("Document does not exist")
                        }
                    case .failure(let error):
                        print("error decoding local message",error.localizedDescription)
                    }
                }
            }
            
        })
    }
    
    
    func ListenForReadStatusChange(_ documentId: String, _ collectionId: String, completion: @escaping (_ updatedMessage: LocalMessage) -> Void){
        updateChatListener = FirebaseReference(.Messages).document(documentId).collection(collectionId).addSnapshotListener({ (querySnapShot, error) in
            
            guard let snapShot = querySnapShot else {return}
            
            for changes in snapShot.documentChanges{
                if changes.type == .modified{
                    let result = Result{
                        try? changes.document.data(as: LocalMessage.self)
                    }
                    switch result  {
                    case .success(let messageObject):
                        if let message = messageObject{
                            completion(message)
                        }else{
                            print("document does not exist")
                        }
                    case .failure(let error):
                        print("error decoding local message", error.localizedDescription)
                    }
                }
            }
        })
    }
    
    func checkForOldChats(documentId: String,collectionId: String){
        FirebaseReference(.Messages).document(documentId).collection(collectionId).getDocuments { (querySnapShot, error) in
            guard let documents = querySnapShot?.documents else {
                print("No document for old chat")
                return
            }
            
            var oldMessages = documents.compactMap { (queryDocumentSnapshot) -> LocalMessage? in
                    
                return try? queryDocumentSnapshot.data(as: LocalMessage.self)
            }
            
            oldMessages.sort(by: {$0.date < $1.date})
            
            for message in oldMessages{
                RealmManager.shared.saveToRealm(message)
            }
        }
    }
    
    //MARK: Add, Update and Delete
    
    func addMessage(message: LocalMessage, memberId: String){
        do{
            let _ = try FirebaseReference(.Messages).document(memberId).collection(message.chatRoomId).document(message.id).setData(from: message)
        }catch{
            print("Error saving message",error.localizedDescription)
        }
        
    }
    
    //MARK: Update message status
    
    func updateMessageInFirebase(_ message: LocalMessage, memberIds: [String]){
        let values = [kSTATUS: kREAD, kREADDATE: Date()] as [String: Any]
        
        for userId in memberIds{
            FirebaseReference(.Messages).document(userId).collection(message.chatRoomId).document(message.id).updateData(values)
        }
        
    }
    
    
    
    func removeListener(){
        self.newChatListener.remove()
        self.updateChatListener.remove()
    }
    
    
}
