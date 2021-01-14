//
//  ViewController.swift
//  MessageMe
//
//  Created by PuNeet on 22/12/20.
//  Copyright © 2020 dreamsteps. All rights reserved.
//

import UIKit
import ProgressHUD
class LoginViewController: UIViewController {
    //MARK: IBOutlets
    //Labels
    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var lblPassword: UILabel!
    @IBOutlet weak var lblRepeatPassword: UILabel!
    @IBOutlet weak var lblSignup: UILabel!
    
    //Buttons
    @IBOutlet weak var btnForgotPassword: UIButton!
    @IBOutlet weak var btnResendEmail: UIButton!
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var btnSignUp: UIButton!
    
    //Views
    @IBOutlet weak var viewrepeatPassword: UIView!
    
    //UIText
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtRepeatPassword: UITextField!
    
    var isLogin = true
    
    //MARK: View Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupBackgroundTap()
        setupTextFieldDelegates()
        setupUIFor(login: true)
    }
    
    
    //MARK: Connection Methods
    @IBAction func resendEmail(_ sender: Any) {
        if  isDataInputtedFor(type: "password"){
            // resend verification email
            self.resendVerificationEmail()
            print("Have data for resend email")
        }else{
            ProgressHUD.showFailed("Email is required")
        }
    }
    
    @IBAction func forgotPassword(_ sender: Any) {
        if  isDataInputtedFor(type: "password"){
            // login or register
            self.resetPassword()
            print("Have data for  password")
        }else{
            ProgressHUD.showFailed("Email is required")
        }
    }
    
    @IBAction func loginTapped(_ sender: Any) {
        if  isDataInputtedFor(type: isLogin ? "login" : "registration"){
            // login or register
            isLogin ? loginUser() : registerUser()
            
        }else{
            ProgressHUD.showFailed("All fields are required")
        }
    }
    
    @IBAction func signUpTapped(_ sender: UIButton) {
        setupUIFor(login: sender.titleLabel?.text == "Login")
        isLogin.toggle()
    }
    
    
    //MARK: Setup
    private func setupBackgroundTap(){
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundTap))
        view.addGestureRecognizer(tapGesture)
        
    }
    
    @objc func backgroundTap(){
        view.endEditing(false)
    }
    private func setupUIFor(login: Bool){
        btnLogin.setImage(UIImage(named: login ? "loginBtn" : "registerBtn"), for: .normal)
        btnSignUp.setTitle(login ? "Signup" : "Login", for: .normal)
        lblSignup.text = login ? "Don't have an account" : "Have an accountin"
        
        UIView.animate(withDuration: 0.5) {
            self.lblRepeatPassword.isHidden = login
            self.txtRepeatPassword.isHidden = login
            self.viewrepeatPassword.isHidden = login
        }
        
    }
    private func setupTextFieldDelegates(){
        txtEmail.addTarget(self, action: #selector(textFieldDidChange(_ :)), for: .editingChanged)
        txtPassword.addTarget(self, action: #selector(textFieldDidChange(_ :)), for: .editingChanged)
        txtRepeatPassword.addTarget(self, action: #selector(textFieldDidChange(_ :)), for: .editingChanged)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField){
        updatePlaceholderLabel(textField)
    }
    
    //MARK: Animatin
    
    private func updatePlaceholderLabel(_ textField: UITextField){
        
        switch textField {
        case txtEmail:
            lblEmail.text = textField.hasText ? "Email" : ""
        case txtPassword:
            lblPassword.text = textField.hasText ? "Password" : ""
        case txtRepeatPassword:
            lblRepeatPassword .text = textField.hasText ? "Repeat Password" : ""
        default:
            txtPassword.text = textField.hasText ? "Password" : ""
        }
        
    }
    
    
    //MARK: Helper
    
    private func isDataInputtedFor(type: String) -> Bool{
        switch type {
        case "login":
            return txtEmail.text != "" && txtPassword.text != ""
        case "registration" :
            return txtEmail.text != "" && txtPassword.text != ""  && txtRepeatPassword.text != ""
        default:
            return txtEmail.text != ""
        }
    }
    
    
    private func registerUser(){
        if txtPassword.text == txtRepeatPassword.text{
            FirebaseUserListener.shared.registerUserWith(email: txtEmail.text!, password: txtPassword.text!) { (error) in
                if error == nil{
                    ProgressHUD.showSuccess("Verification email send...")
                    self.btnResendEmail.isHidden = false
                }else{
                    ProgressHUD.showFailed(error?.localizedDescription)
                }
            }
        }else{
            ProgressHUD.showFailed ("Password don't match")
            
        }
    }
    private func loginUser(){
        FirebaseUserListener.shared.loginUserWith(email: txtEmail.text!, password: txtPassword.text!) { (error, isEmailVerified) in
            if error == nil{
                if isEmailVerified{
                    self.goToApp()
                }else{
                    ProgressHUD.showFailed("Please verify your email")
                    self.btnResendEmail.isHidden = false
                }
            }else{
                ProgressHUD.showFailed(error?.localizedDescription)
            }
        }
    }
    
    
    private func resetPassword(){
        FirebaseUserListener.shared.resetPassword(email: txtEmail.text!) { (error) in
            if error == nil{
                ProgressHUD.showSuccess("Reset link sent to email")
            }else{
                ProgressHUD.showFailed(error?.localizedDescription)
            }
        }
    }
    
    private func resendVerificationEmail(){
        FirebaseUserListener.shared.resendVerificationEmail(email: txtEmail.text!) { (error) in
            if error == nil{
                ProgressHUD.showSuccess("Verification link sent to email")
            }else{
                ProgressHUD.showFailed(error?.localizedDescription)
            }
        }
    }
    //MARK: Navigation
    
    private func goToApp(){
        let mainView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "MainApp") as! UITabBarController
        mainView .modalPresentationStyle = .fullScreen
        self.present(mainView, animated: true, completion: nil)
    }
}

