//
//  GlobalFunctions.swift
//  MessageMe
//
//  Created by PuNeet on 24/12/20.
//  Copyright © 2020 dreamsteps. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation


func fileNameFrom(fileUrl: String) -> String{
  //  let name = fileUrl.components(separatedBy: "_").last?.components(separatedBy: "?").first!.components(separatedBy: ".").first
    return (fileUrl.components(separatedBy: "_").last?.components(separatedBy: "?").first!.components(separatedBy: ".").first!)!
}

func timeElapsed(_ date: Date) -> String{
    let seconds = Date().timeIntervalSince(date)
    var elapsed = ""
    if seconds < 60{
        elapsed = "Now"
    }else if seconds < 60 * 60{
        let minutes = Int(seconds / 60)
        let mintext = minutes > 1 ? "mins" : "min"
        
        elapsed = "\(minutes) \(mintext)"
    }else if seconds < 24 * 60 * 60 {
        let hours = Int(seconds / (60 * 60))
        
        let hourtext = hours > 1 ? "hours" : "hour"
        
        elapsed = "\(hours) \(hourtext)"
    }else{
        elapsed = date.longDate()
    }
    
    return elapsed
}

func videoThumbNail(video: URL) ->UIImage {
    let asset = AVURLAsset(url: video,options: nil)
    let imageGenerator = AVAssetImageGenerator(asset: asset)
    imageGenerator.appliesPreferredTrackTransform = true
    
    let time = CMTimeMakeWithSeconds(0.5, preferredTimescale: 1000)
    
    var actualTime = CMTime.zero
    
    var image:CGImage?
    do{
        image = try imageGenerator.copyCGImage(at: time, actualTime: &actualTime)
    }catch let error as NSError{
        print("error making thumbnail \(error.localizedDescription)")
    }
    
    if image != nil{
        return UIImage(cgImage: image!)
    }else{
        return UIImage(named: "photoPlaceholder")!
    }
}
