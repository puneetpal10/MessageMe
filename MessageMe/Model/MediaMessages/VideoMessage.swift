//
//  VideoMessage.swift
//  MessageMe
//
//  Created by PuNeet on 06/01/21.
//  Copyright © 2021 dreamsteps. All rights reserved.
//

import Foundation
import MessageKit

class VideoMessage: NSObject, MediaItem{
    var url: URL?
    
    var image: UIImage?
    
    var placeholderImage: UIImage
    
    var size: CGSize
    
    init(url: URL?) {
        self.url = url
        self.placeholderImage = UIImage(named: "photoPlaceholder")!
        self.size = CGSize(width: 240, height: 240)
    }
    
}
