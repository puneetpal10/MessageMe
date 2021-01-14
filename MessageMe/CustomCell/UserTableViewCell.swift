//
//  UserTableViewCell.swift
//  MessageMe
//
//  Created by PuNeet on 24/12/20.
//  Copyright © 2020 dreamsteps. All rights reserved.
//

import UIKit

class UserTableViewCell: UITableViewCell {

    //MARK: IBOutltes
    @IBOutlet weak var imgUser: UIImageView!
    @IBOutlet weak var lblUser: UILabel!
    @IBOutlet weak var lblStats: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func confogureOf(user: User){
        lblUser.text = user.userName
        lblStats.text = user.status
        self.setAvtar(avatarLink: user.avatarLink )
    }
    
    private func setAvtar(avatarLink: String){
        if avatarLink != ""{
            FileStorage.downloadImage(avatarLink) { (avatarImg) in
                self.imgUser.image = avatarImg?.circleMasked
            }
        }else{
            self.imgUser.image = UIImage(named: "avatar")
        }
    }

}
