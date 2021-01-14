//
//  FCollectionReference.swift
//  MessageMe
//
//  Created by PuNeet on 22/12/20.
//  Copyright © 2020 dreamsteps. All rights reserved.
//

import Foundation
import FirebaseFirestore

enum FCollectionReference: String {
    case User
    case Recent
    case Messages
    case Typing
}

func FirebaseReference(_ collectionReference: FCollectionReference) -> CollectionReference{
    
    return Firestore.firestore().collection(collectionReference.rawValue)
}
