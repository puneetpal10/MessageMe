//
//  ProfileTableViewController.swift
//  MessageMe
//
//  Created by PuNeet on 28/12/20.
//  Copyright © 2020 dreamsteps. All rights reserved.
//

import UIKit

class ProfileTableViewController: UITableViewController {

    //MARK: IBOutlet
    @IBOutlet weak var avatarImgView: UIImageView!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblStatus: UILabel!
    
    
    //MARK: vars
    
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.largeTitleDisplayMode = .never
        tableView.tableFooterView = UIView()
        setUpUI()
    }

    
    //MARK: SetupUI
    
    private func setUpUI(){
        if user != nil{
            self.title = user?.userName
            lblUserName.text = user?.userName ?? ""
            lblStatus.text = user?.status ?? ""
            
            
            if user?.avatarLink != ""{
                FileStorage.downloadImage(user!.avatarLink) { (image) in
                    self.avatarImgView.image = image?.circleMasked
                }
            }
        }
    }
    // MARK: - Table view data source

   // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor(named: "tableViewBackground")
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 5
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 1 {
            
            //TODO: Go to chat room
            
            let chatId = startChat(user1: User.currentUser!, user2: user!)
            print("Chat room id is \(chatId)")
            
            let privateChatView = ChatViewController(chatId: chatId, recepientId: user!.id, recepientName: user!.userName)
            
            privateChatView.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(privateChatView, animated: true)
        }
    }

}
