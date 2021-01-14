//
//  LocationMessage.swift
//  MessageMe
//
//  Created by PuNeet on 13/01/21.
//  Copyright © 2021 dreamsteps. All rights reserved.
//

import Foundation
import CoreLocation
import MessageKit


class LocationMessage: NSObject,LocationItem{
    var location: CLLocation
    
    var size: CGSize
    
    init(location:CLLocation) {
        self.location = location
        self.size = CGSize(width: 240, height: 240)
    }
}
