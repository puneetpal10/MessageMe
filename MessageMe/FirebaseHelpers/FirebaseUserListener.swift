//
//  FirebaseUserListener.swift
//  MessageMe
//
//  Created by PuNeet on 22/12/20.
//  Copyright © 2020 dreamsteps. All rights reserved.
//

import Foundation
import Firebase

class FirebaseUserListener {
    static let shared = FirebaseUserListener()
    private init(){}
    //MARK: - LOGIN
    
    func loginUserWith(email: String, password: String, comppletion: @escaping (_ error: Error?, _ isEmailVerified: Bool)-> Void){
        Auth.auth().signIn(withEmail: email, password: password) { (authResult, error) in
            if error == nil && authResult!.user.isEmailVerified{
                
                FirebaseUserListener.shared.downloadUserFromFirebase(userId: authResult!.user.uid, email: email)
                comppletion(error, true)
            }else{
                print("Email is not verified")
                comppletion(error,false)
            }
        }
    }
    
    //MARK: - REGISTRATION
    
    func registerUserWith(email: String, password: String, completion: @escaping (_ error: Error?) -> Void){
        Auth.auth().createUser(withEmail: email, password: password) { (authDataResult, errror) in
            completion(errror)
            if errror == nil{
                //send verification email
                authDataResult?.user.sendEmailVerification(completion: { (error) in
                    print("Auth email email send with error \(error?.localizedDescription)")
                })
                
                //create user and save it
                
                if authDataResult?.user != nil{
                    let user = User(id: authDataResult!.user.uid, userName: email, emailId: email, pushId: "", avatarLink: "", status: "Hey there I am using messanger")
                    saveUserLocally(user)
                    self.saveUserToFireStore(user)
                    
                }
            }
        }
    }
    // MARK: Resend Method Link
    
    func resendVerificationEmail(email: String, completion: @escaping(_ error: Error?) -> Void){
        Auth.auth().currentUser?.reload(completion: { (error) in
            Auth.auth().currentUser?.sendEmailVerification(completion: { (error) in
                completion(error)
            })
        })
    }
    
    func resetPassword(email: String, completion: @escaping(_ error: Error?)-> Void){
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            completion(error)
        }
    }
    func logoutCurrentUser(completion : @escaping(_ error: Error?)-> Void){
        do {
           try Auth.auth().signOut()
            userDefault.removeSuite(named: kCURRENTUSRE)
            userDefault.synchronize()
            completion(nil)
        }catch let error as NSError{
            print(error.localizedDescription)
        }
    }
    
    // MARK: Save users
    
    func saveUserToFireStore(_ user: User){
        do{
            try FirebaseReference(.User).document(user.id).setData(from: user)
        }catch{
            print("Error in adding user \(error.localizedDescription)")
        }
    }
    
    // MARK: Download user from Firebase
    
    func downloadUserFromFirebase(userId: String,email: String? = nil){
        FirebaseReference(.User).document(userId).getDocument { (querySnapShot, error) in
            guard let document = querySnapShot else {
                print("No document for user")
                return
            }
            let result = Result{
                try! document.data(as: User.self)
            }
            switch result{
            case .success(let userObject) :
                if let user = userObject{
                    self.saveUserToFireStore(user)
                }else{
                    print("document does not exist")
                }
            case .failure(let error):
                print("Error decoding user \(error.localizedDescription)")
            }
        }
    }
    
    
    func downloadAllUserFormFirebase(completion: @escaping(_ allUsers: [User])-> Void) {
        var users: [User] = []
        FirebaseReference(.User).limit(to: 500).getDocuments { (querySnapshot, error) in
            guard let document = querySnapshot?.documents else {
                print("No document user")
                return
            }
            
            let allUsers = document.compactMap{(queryDocumentSnapshot) -> User? in
                
                return try? queryDocumentSnapshot.data(as: User.self)
            }
            
            for user in allUsers{
                if User.currentId != user.id{
                    users.append(user)
                }
            }
            completion(users)
        }
    }
    
    func downlaodUsersFromFirebase(withIDs: [String],completion: @escaping(_ allUsers: [User])-> Void){
        var count = 0
        var usersArray: [User] = []
        
        for userId in withIDs {
            FirebaseReference(.User).document(userId).getDocument { (querySnapShot, error) in
                guard let document = querySnapShot else {
                    print("No document for user")
                    return
                }
                
                let user = try? document.data(as: User.self)
                usersArray.append(user!)
                count += 1
                
                if count == withIDs.count{
                    completion(usersArray)
                }
            }
        }
    }
}

