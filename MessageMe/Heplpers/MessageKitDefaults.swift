//
//  MessageKitDefaults.swift
//  MessageMe
//
//  Created by PuNeet on 29/12/20.
//  Copyright © 2020 dreamsteps. All rights reserved.
//

import Foundation
import UIKit
import MessageKit


struct MKSender: SenderType, Equatable {
    var senderId: String
    var displayName: String
}


enum MessageDefaults {
    //Bubble
    static let bubbleColorOutGoing = UIColor(named: "chatOutgoingBubble") ?? UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1)
    static let bubbleColorInComming = UIColor(named: "chatIncommingBubble") ?? UIColor(red: 230/255, green: 229/255, blue: 234/255, alpha: 1)
    
}
