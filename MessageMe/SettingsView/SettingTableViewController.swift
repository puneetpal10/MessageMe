//
//  SettingTableViewController.swift
//  MessageMe
//
//  Created by PuNeet on 23/12/20.
//  Copyright © 2020 dreamsteps. All rights reserved.
//

import UIKit

class SettingTableViewController: UITableViewController {
    
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var lblVersion: UILabel!
    @IBOutlet weak var imgUser: UIImageView!
    
    //MARK: ViewLife cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        tableView.tableFooterView = UIView()
//        imgUser.layer.cornerRadius = imgUser.frame.width / 2
//        imgUser.clipsToBounds = true

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.showUserInfo()
    }
    
    //MARK: TableView delegate
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor(named: "tableViewBackground")
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 0.0 : 10.0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 0 && indexPath.row == 0{
            performSegue(withIdentifier: "settingsToEditProfile", sender: self)
        }
    }
    private func showUserInfo(){
        if let user = User.currentUser{
            lblUserName.text = user.userName
            lblStatus.text = user.status
            lblVersion.text = "App version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "")"
            
            if user.avatarLink != ""{
                FileStorage.downloadImage(user.avatarLink) { (avatarImage) in
                    self.imgUser.image = avatarImage?.circleMasked
                }
            }
        }
        
    }
    
    //MARK: IBAction
    
    @IBAction func termsConditions(_ sender: Any) {
    }
    @IBAction func tellAFriend(_ sender: Any) {
    }
    @IBAction func logOutTapped(_ sender: Any) {
        FirebaseUserListener.shared.logoutCurrentUser { (error) in
            if error == nil{
                let login = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "LoginViewController")
                DispatchQueue.main.async {
                    login.modalPresentationStyle = .fullScreen
                    self.present(login, animated: true, completion: nil)
                }
            }
        }
    }
    
    
}
