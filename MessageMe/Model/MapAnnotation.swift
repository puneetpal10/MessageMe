//
//  MapAnnotation.swift
//  MessageMe
//
//  Created by PuNeet on 13/01/21.
//  Copyright © 2021 dreamsteps. All rights reserved.
//

import Foundation
import MapKit


class MapAnnotation: NSObject,MKAnnotation{
    let title: String?
    let coordinate: CLLocationCoordinate2D
    
    init(title: String?, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.coordinate = coordinate
    }
}
