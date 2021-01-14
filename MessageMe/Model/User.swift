//
//  User.swift
//  MessageMe
//
//  Created by PuNeet on 22/12/20.
//  Copyright © 2020 dreamsteps. All rights reserved.
//

import Foundation
import Firebase
//import FirebaseFirestoreSwitf
import FirebaseFirestoreSwift


struct User: Codable, Equatable  {//Equtable
    var id = ""
    var userName: String
    var emailId: String
    var pushId = ""
    var avatarLink = ""
    var  status: String
    
    static var currentId: String{
        return Auth.auth().currentUser!.uid
    }
    
    static var currentUser: User? {
        if Auth.auth().currentUser != nil {
            if let dictonary = UserDefaults.standard.data(forKey: kCURRENTUSRE){
                let decoder = JSONDecoder()
                
                do{
                    let object = try decoder.decode(User.self, from: dictonary)
                    return object
                }catch{
                    print("Error to decode user form userDefaults \(error.localizedDescription)")
                }
            }
        }
        return nil
    }
    
    static func == (lhs: User, rhs: User) -> Bool{
        lhs.id == rhs.id
    }
}

func saveUserLocally(_ user: User){
    let encoder = JSONEncoder()
    do{
        let data = try encoder.encode(user)
        UserDefaults.standard.set(data, forKey: kCURRENTUSRE)
    }catch{
        print("Error saving user locally \(error.localizedDescription)")
    }
    
}
    
func createDummyUser() {
    print("creating dummy user")
    let name = ["Saksham","Sakshi","Ayushi","Advik","Anshu","Nitin","Roli"]
    var imageIndex = 1
    var userIndex = 1
    
    for i in 0..<5{
        let id = UUID().uuidString
        let fileDirectory = "Avatar/" + "_\(id)" + ".jpg"
        FileStorage.uploadImage(UIImage(named: "user\(imageIndex)")!, directory: fileDirectory) { (avatarLink) in
            let user = User(id: id, userName: name[i], emailId: "user\(userIndex)@gmail.com", pushId: "", avatarLink: avatarLink ?? "", status: "No Status")
            
            userIndex += 1
            
            FirebaseUserListener.shared.saveUserToFireStore(user)
            
        }
        imageIndex += 1
        
        if imageIndex == 5 {
            imageIndex = 1
        }
    }
}
