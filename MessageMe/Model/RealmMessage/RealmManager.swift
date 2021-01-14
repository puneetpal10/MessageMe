//
//  RealmManager.swift
//  MessageMe
//
//  Created by PuNeet on 29/12/20.
//  Copyright © 2020 dreamsteps. All rights reserved.
//

import Foundation
import RealmSwift

class RealmManager {
    static let shared = RealmManager()
    
    
    let realm = try!  Realm()
    private init() {}
    
    func saveToRealm<T: Object>(_ object: T){
        do{
            try realm.write{
                realm.add(object, update: .all)
            }
        }catch{
            print("error saving realm object", error.localizedDescription)
        }
    }
    
    
    func deletToRealm<T: Object>(_ object: T){
        do{
            try realm.write{
                realm.delete(object)
            }
        }catch{
            print("error delete  realm object", error.localizedDescription)
        }
    }
    
}
