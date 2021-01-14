//
//  EditProfileTableViewController.swift
//  MessageMe
//
//  Created by PuNeet on 24/12/20.
//  Copyright © 2020 dreamsteps. All rights reserved.
//

import UIKit
import Gallery
import ProgressHUD
class EditProfileTableViewController: UITableViewController {
    
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var txtUserName: UITextField!
    
    //MARK: Gallary instance
    var galarry: GalleryController!
    
    //MARK: View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        
        //        self.showUserInfo()
        configureTextField()
//        imgView.layer.cornerRadius = imgView.frame.width / 2
//        imgView.clipsToBounds = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.showUserInfo()
    }
    private func showUserInfo(){
        if let user = User.currentUser{
            txtUserName.text = user.userName
            lblStatus.text = user.status
            if user.avatarLink != ""{
                FileStorage.downloadImage(user.avatarLink) { (avatarImag) in
                    self.imgView.image = avatarImag?.circleMasked
                }
            }
        }
    }
    
    //MARK: Configure
    private func configureTextField(){
        txtUserName.delegate = self
        
    }
    
    //MARK: TableView delegate
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor(named: "tableViewBackground")
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 0.0 : 30.0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 1 && indexPath.row == 0{
            performSegue(withIdentifier: "editProfileToStatus", sender: self)
        }
    }
    
    
    @IBAction func editProfileTapped(_ sender: UIButton){
        showImageGalarry()
    }
    
    private func showImageGalarry(){
        self.galarry = GalleryController()
        self.galarry.delegate = self
        Config.tabsToShow = [.cameraTab, .imageTab]
        Config.Camera.imageLimit = 1
        Config.initialTab = .imageTab
        
        self.present(galarry, animated: true, completion: nil)
    }
    
    
    private func uploadAvtarImage(_ image: UIImage){
        let fileDirectory = "Avatar/" + "_\(User.currentId)" + ".jpg"
        FileStorage.uploadImage(image, directory: fileDirectory) { (avatarLink) in
            if var user = User.currentUser{
                user.avatarLink =  avatarLink ?? ""
                saveUserLocally(user)
                FirebaseUserListener.shared.saveUserToFireStore(user)
            }
            
            FileStorage.saveFileLocally(fileData: image.jpegData(compressionQuality: 1.0)! as NSData, fileName: User.currentId)
        }
    }

}


extension EditProfileTableViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == txtUserName{
            if textField.text != ""{
                if var user = User.currentUser{
                    user.userName = textField.text!
                    saveUserLocally(user)
                    FirebaseUserListener.shared.saveUserToFireStore(user)
                }
            }
            textField.resignFirstResponder()
            return false
        }
        return true
    }
}


extension EditProfileTableViewController: GalleryControllerDelegate {
    func galleryController(_ controller: GalleryController, didSelectImages images: [Image]) {
        if images.count > 0{
            images.first!.resolve { (avatar) in
                self.uploadAvtarImage(avatar!)
                if let avImage = avatar{
                    self.imgView.image = avImage.circleMasked
                }else{
                    ProgressHUD.showError("Could not load image")
                }
                
            }
        }
        controller.dismiss(animated: true, completion: nil)
    }
    
    func galleryController(_ controller: GalleryController, didSelectVideo video: Video) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func galleryController(_ controller: GalleryController, requestLightbox images: [Image]) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func galleryControllerDidCancel(_ controller: GalleryController) {
        controller.dismiss(animated: true, completion: nil)
    }
    

}
