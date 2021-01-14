//
//  RecentTableViewCell.swift
//  MessageMe
//
//  Created by PuNeet on 28/12/20.
//  Copyright © 2020 dreamsteps. All rights reserved.
//

import UIKit

class RecentTableViewCell: UITableViewCell {
    
    @IBOutlet weak var imgUser: UIImageView!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblLastMsg: UILabel!
    @IBOutlet weak var lblMsgDate: UILabel!
    @IBOutlet weak var unreadlblMsgCount: UILabel!
    @IBOutlet weak var unreagMsgView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        unreagMsgView.layer.cornerRadius = unreagMsgView.frame.width / 2
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func configure(recent: RecentChat){
        lblUserName.text = recent.receiverName
        lblUserName.adjustsFontSizeToFitWidth =  true
        lblUserName.minimumScaleFactor = 0.9
        
        lblLastMsg.text = recent.lastMessage
        lblLastMsg.adjustsFontSizeToFitWidth =  true
        lblLastMsg.numberOfLines = 2
        lblLastMsg.minimumScaleFactor = 0.9
        
        if recent.unreadCount != 0 {
            self.unreadlblMsgCount.text = "\(recent.unreadCount)"
            self.unreagMsgView.isHidden = false
        }else{
            self.unreagMsgView.isHidden = true
        }
        setAvatar(avatarLink: recent.avatarLink)
        lblMsgDate.text = timeElapsed(recent.date ?? Date())
        lblMsgDate.adjustsFontSizeToFitWidth = true
    }
     
    private func setAvatar(avatarLink: String){
        if avatarLink != ""{
            FileStorage.downloadImage(avatarLink) { (avatarImg) in
                self.imgUser.image = avatarImg?.circleMasked
            }
        }else{
            self.imgUser.image = UIImage(named: "avatar ")?.circleMasked
        }
    }
}

