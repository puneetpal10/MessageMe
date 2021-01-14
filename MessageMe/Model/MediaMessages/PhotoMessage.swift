//
//  PhotoMessages.swift
//  MessageMe
//
//  Created by PuNeet on 05/01/21.
//  Copyright © 2021 dreamsteps. All rights reserved.
//

import Foundation
import MessageKit


class PhotoMessage: NSObject, MediaItem{
    var url: URL?
    
    var image: UIImage?
    
    var placeholderImage: UIImage
    
    var size: CGSize
    
    init(path: String) {
        self.url = URL(fileURLWithPath: path)
        self.placeholderImage = UIImage(named: "photoPlaceholder")!
        self.size = CGSize(width: 240, height: 240)
    }
    
}
