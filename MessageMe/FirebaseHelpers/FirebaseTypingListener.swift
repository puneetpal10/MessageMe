//
//  FirebaseTypingListener.swift
//  MessageMe
//
//  Created by PuNeet on 31/12/20.
//  Copyright © 2020 dreamsteps. All rights reserved.
//

import Foundation
import Firebase


class FirebaseTypingListener{
    
    static let shared = FirebaseTypingListener()
    
    var typingListener: ListenerRegistration!
    private init () {}
    
    
    
    func createTypingObserver(chatRoomId: String, completion: @escaping(_ isTyping: Bool)->Void) {
        typingListener = FirebaseReference(.Typing).document(chatRoomId).addSnapshotListener({ (snapShot, error) in
            guard let snapShot = snapShot else{return}
            
            if snapShot.exists{
                for data in snapShot.data()!{
                    if data.key != User.currentId{
                        completion(data.value as! Bool)
                    }
                }
            }else{
                completion(false)
                FirebaseReference(.Typing).document(chatRoomId).setData([User.currentId : false])
            }
        })
    }
    
    
    class func saveTypingCounter(typing: Bool, chatRoomId: String){
        FirebaseReference(.Typing).document(chatRoomId).updateData([User.currentId : typing])
        
    }
    
    func removeTypingListener(){
        self.typingListener.remove()
    }
}
