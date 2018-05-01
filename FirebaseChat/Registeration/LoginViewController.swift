//
//  LoginViewController.swift
//  FirebaseChat
//
//  Created by Jahongir Nematov on 4/10/18.
//  Copyright © 2018 Jahongir Nematov. All rights reserved.
//

import UIKit
import SnapKit
import Firebase

class LoginViewController: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    var messagesController : MessagesController?
    
    let inputsContainerView : UIView = {
        var view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 5
        return view
    }()
    
    let loginRegisterButton : UIButton = {
        var button = UIButton(type: .system)
        button.setTitle("Register", for: .normal)
        button.layer.cornerRadius = 5
        button.backgroundColor = UIColor.amazingOrange
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(handleLoginRegister), for: .touchUpInside)
        return button
    }()
    
    let nameTextField : UITextField = {
        var textField = UITextField()
        textField.placeholder = "Name"
        return textField
    }()
    
    let nameSeperatorView : UIView = {
        var view = UIView()
        view.backgroundColor = .lightGray
        return view
    }()
    
    let emailTextField : UITextField = {
        var textField = UITextField()
        textField.placeholder = "Email"
        return textField
    }()
    
    let emailSeperatorView : UIView = {
        var view = UIView()
        view.backgroundColor = .lightGray
        return view
    }()
    
    let passwordTextField : UITextField = {
        var textField = UITextField()
        textField.placeholder = "Password"
        textField.isSecureTextEntry = true
        return textField
    }()
    
    let logoImageView : UIImageView = {
        var imageView = UIImageView()
        imageView.image = UIImage(named: "logo")
        return imageView
    }()
    
    lazy var profileImageView : UIImageView = {
        var imageView = UIImageView()
        imageView.image = UIImage(named: "profile")
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 50
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleProfileImageSelection))
        imageView.addGestureRecognizer(tapGesture)
        return imageView
    }()
    
    let loginRegisterSegmentedControll : UISegmentedControl = {
        var segmentedControl = UISegmentedControl(items: ["Login", "Register"])
        segmentedControl.tintColor = UIColor.amazingOrange
        segmentedControl.selectedSegmentIndex = 1
        segmentedControl.addTarget(self, action: #selector(handleLoginRegisterChange) , for: .valueChanged)
        return segmentedControl
    }()
    
  
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
    
        setupView()

    }
    
    private func setupView() {
        view.backgroundColor = UIColor.amazingBlue
        
        view.addSubview(logoImageView)
        view.addSubview(inputsContainerView)
        view.addSubview(loginRegisterButton)
        view.addSubview(loginRegisterSegmentedControll)
        view.addSubview(profileImageView)
        inputsContainerView.addSubview(nameTextField)
        inputsContainerView.addSubview(nameSeperatorView)
        inputsContainerView.addSubview(emailTextField)
        inputsContainerView.addSubview(emailSeperatorView)
        inputsContainerView.addSubview(passwordTextField)
        
        
        
        logoImageView.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.view)
            make.height.equalTo(150)
            make.width.equalTo(150)
            make.bottom.equalTo(self.loginRegisterSegmentedControll.snp.top).offset(-30)
        }
        
        profileImageView.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.view)
            make.height.width.equalTo(100)
            make.top.equalTo(loginRegisterButton).offset(80)
        }
        
        loginRegisterSegmentedControll.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.view)
            make.width.equalTo(self.view).offset(-24)
            make.bottom.equalTo(self.inputsContainerView.snp.top).offset(-10)
        }
        
        inputsContainerView.snp.makeConstraints { (make) in
            make.center.equalTo(self.view)
            make.width.equalTo(self.view).offset(-24)
            make.height.equalTo(150)
        }
        
        loginRegisterButton.snp.makeConstraints { (make) in
            make.top.equalTo(inputsContainerView.snp.bottom).offset(10)
            make.centerX.equalTo(self.view)
            make.width.equalTo(self.view).offset(-24)
            make.height.equalTo(50)
        }
        
        nameTextField.snp.makeConstraints { (make) in
            make.top.equalTo(self.inputsContainerView)
            make.centerX.equalTo(self.inputsContainerView)
            make.width.equalTo(self.inputsContainerView).offset(-20)
            make.height.equalTo(50)
        }
        
        nameSeperatorView.snp.makeConstraints { (make) in
            make.top.equalTo(nameTextField.snp.bottom)
            make.centerX.equalTo(self.inputsContainerView)
            make.width.equalTo(self.inputsContainerView).offset(-20)
            make.height.equalTo(0.5)
        }
        
        emailTextField.snp.makeConstraints { (make) in
            make.top.equalTo(self.nameSeperatorView.snp.bottom)
            make.centerX.equalTo(self.inputsContainerView)
            make.width.equalTo(self.inputsContainerView).offset(-20)
            make.height.equalTo(50)
        }
        
        emailSeperatorView.snp.makeConstraints { (make) in
            make.top.equalTo(emailTextField.snp.bottom)
            make.centerX.equalTo(self.inputsContainerView)
            make.width.equalTo(self.inputsContainerView).offset(-20)
            make.height.equalTo(0.5)
        }
        
        passwordTextField.snp.makeConstraints { (make) in
            make.top.equalTo(emailSeperatorView.snp.bottom)
            make.centerX.equalTo(self.inputsContainerView)
            make.width.equalTo(self.inputsContainerView).offset(-20)
            make.height.equalTo(50)
        }
    }
    
    @objc func handleLoginRegisterChange(){
        
        let selectedSegmentIndex = loginRegisterSegmentedControll.selectedSegmentIndex
        
        let currentSegmentTitle = loginRegisterSegmentedControll.titleForSegment(at: selectedSegmentIndex)
        loginRegisterButton.setTitle(currentSegmentTitle, for: .normal)
        
        
        
        if selectedSegmentIndex == 0 {
           
            UIView.animate(withDuration: 0.2) {
                
                self.profileImageView.isHidden = true
                
                self.inputsContainerView.snp.updateConstraints { (make) in
                    make.height.equalTo(100)
                }
                
                self.nameTextField.snp.updateConstraints({ (make) in
                    make.height.equalTo(0)
                })
                
                self.nameSeperatorView.snp.updateConstraints({ (make) in
                    make.height.equalTo(0)
                })
                
                self.view.layoutIfNeeded()
            }
            
           
            
           
        } else {
            
            UIView.animate(withDuration: 0.2, animations: {
                
                self.profileImageView.isHidden = false
                
                self.inputsContainerView.snp.updateConstraints { (make) in
                    make.height.equalTo(150)
                }
                
                self.nameTextField.snp.updateConstraints({ (make) in
                    make.height.equalTo(50)
                })
                
                self.nameSeperatorView.snp.updateConstraints({ (make) in
                    make.height.equalTo(0.5)
                })
                
                self.view.layoutIfNeeded()
            })
           
            
          
        }
        
        
       
    }
    
    @objc func handleLoginRegister(){
        
        if loginRegisterSegmentedControll.selectedSegmentIndex == 0 {
            handleLogin()
        } else {
            handleRegister()
        }
        
    }
    
    
    func handleLogin(){
        
        guard let email = emailTextField.text , let password = passwordTextField.text else { return }
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            
            if error != nil {
                print(error!)
                return
            }
            
            self.messagesController?.fetchUserAndSetupNavBarTitle()
            self.dismiss(animated: true, completion: nil)
        }

        
        
        
    }
    
    func handleRegister(){
        
        guard let name = nameTextField.text , let email = emailTextField.text , let password = passwordTextField.text else { return }
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            
            if error != nil {
                print(error!)
                return
            }
            
            guard let uid = user?.uid else { return }
            
            let imageName = UUID().uuidString
            let refStorage = Storage.storage().reference().child("profileImages").child("\(imageName).png")
            
            if let uploadImageData =  UIImageJPEGRepresentation(self.profileImageView.image!, 0.1) {
                refStorage.putData(uploadImageData, metadata: nil, completion: { (metadata, error) in
                    
                    if error != nil {
                        print(error!)
                        return
                    }
                    
                    if let profileImageUrl = metadata?.downloadURL()?.absoluteString {
                        let values = ["name" : name , "email" : email, "profileImageUrl" : profileImageUrl]
                        
                        self.registerUserWithUid(uid: uid, values: values as [String : AnyObject])
                    }
                    
                    
                })
            }
            
           
        }
        
    
    }
    
    private func registerUserWithUid(uid : String , values : [String : AnyObject]){
        let ref = Database.database().reference()
        let userReference = ref.child("users").child(uid)
        userReference.updateChildValues(values, withCompletionBlock: { (error, reference) in
            
            if error != nil {
                print(error!)
                return
            }
            
            self.messagesController?.fetchUserAndSetupNavBarTitle()
            self.dismiss(animated: true, completion: nil)
            
        })
        
    }
    
    



}

extension LoginViewController : UINavigationControllerDelegate , UIImagePickerControllerDelegate {
    
    @objc func handleProfileImageSelection () {
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        imagePicker.allowsEditing = true
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        self.dismiss(animated: true, completion: nil)
        
        var selectedImage : UIImage?
        
        if let imageOriginal = info[UIImagePickerControllerOriginalImage] as? UIImage {
            selectedImage = imageOriginal
        } else if let imageEdited = info[UIImagePickerControllerEditedImage] as? UIImage {
            selectedImage = imageEdited
        } else {
            return
        }
        
        
        if let image = selectedImage {
            profileImageView.image = image
        }
    }
    
}























