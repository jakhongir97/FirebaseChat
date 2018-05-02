//
//  UserInfoViewController.swift
//  FirebaseChat
//
//  Created by Jahongir Nematov on 4/30/18.
//  Copyright © 2018 Jahongir Nematov. All rights reserved.
//

import UIKit
import TextFieldEffects
import Firebase
import RxSwift
import RxCocoa
import NVActivityIndicatorView

class UserInfoViewController: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    
    var usernameText = Variable<String>("")
    
    let disposeBag = DisposeBag()

    let headerLabel : UILabel = {
        var label = UILabel()
        label.text = "Setup Profile"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 24, weight: .medium)
        label.textColor = .amazingBrown
        return label
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
    
    let editLabel : UILabel = {
        var label = UILabel()
        label.text = "Edit"
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 14)
        label.backgroundColor = UIColor(white: 0, alpha: 0.5)
        return label
    }()
    
    
    
    let usernameTextField : HoshiTextField = {
        var textField = HoshiTextField()
        textField.placeholderColor = UIColor.amazingBrown!
        textField.borderInactiveColor = .white
        textField.borderActiveColor = UIColor.amazingBrown
        textField.textColor = .white
        textField.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        textField.placeholder = "username"
        textField.keyboardAppearance = .dark
        textField.autocorrectionType = .no
        textField.tintColor = UIColor.gray
        textField.returnKeyType = .done
        return textField
    }()
    
    let nextButton : UIButton = {
        var button = UIButton(type: .system)
        button.tintColor = .white
        button.setTitle("Next", for: .normal)
        button.backgroundColor = UIColor.amazingBrown
        button.layer.cornerRadius = 20
        button.isEnabled = false
        button.alpha = 0.6
        button.addTarget(self, action: #selector(handleNextAction), for: .touchUpInside)
        return button
    }()
    
    let activityIndicator : NVActivityIndicatorView = {
        let frameAI = CGRect(x: 0, y: 0, width: 50, height: 50)
        var activity = NVActivityIndicatorView(frame: frameAI)
        activity.type = .ballBeat
        activity.color = UIColor.white
        return activity
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()

        usernameTextField.delegate = self
        
        setupView()
        enableNextButton()
        self.hideKeyboardWhenTappedAround()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.activityIndicator.stopAnimating()
    }
    
    private func setupView(){
        view.backgroundColor = UIColor.amazingBlue
        
        view.addSubview(headerLabel)
        view.addSubview(profileImageView)
        view.addSubview(usernameTextField)
        view.addSubview(nextButton)
        profileImageView.addSubview(editLabel)
        view.addSubview(activityIndicator)
        
        
        usernameTextField.snp.makeConstraints { (make) in
            make.center.equalTo(view)
            make.height.equalTo(50)
            make.width.equalTo(250)
        }
        
        profileImageView.snp.makeConstraints { (make) in
            make.centerX.equalTo(view)
            make.width.height.equalTo(100)
            make.bottom.equalTo(usernameTextField.snp.top).offset(-10)
        }
        
        editLabel.snp.makeConstraints { (make) in
            make.bottom.left.right.equalTo(profileImageView)
            make.height.equalTo(profileImageView.snp.height).dividedBy(4)
        }
        
        headerLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(view)
            make.bottom.equalTo(profileImageView.snp.top).offset(-20)
        }
        
        nextButton.snp.makeConstraints { (make) in
            make.centerX.equalTo(view)
            make.height.equalTo(50)
            make.width.equalTo(250)
            make.top.equalTo(usernameTextField.snp.bottom).offset(50)
        }
        
        activityIndicator.snp.makeConstraints { (make) in
            make.centerX.equalTo(view)
            make.bottom.equalTo(view).offset(-50)
        }
        
        
        
    }
    
    private func enableNextButton(){
        _ = usernameTextField.rx.text.orEmpty.bind(to: usernameText)
        
        usernameText.asObservable().subscribe(onNext: { value in
            if String(value).count > 2 {
                self.nextButton.isEnabled = true
                UIView.animate(withDuration: 0.25, animations: {
                    self.nextButton.alpha = 1
                })
            } else {
                self.nextButton.isEnabled = false
                UIView.animate(withDuration: 0.25, animations: {
                    self.nextButton.alpha = 0.6
                })
            }
            
        } ).disposed(by: disposeBag)
    }
    
    @objc func handleNextAction() {
        
        self.activityIndicator.startAnimating()
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let username = usernameTextField.text , let phone = UserDefaults.standard.string(forKey: "phoneNumber") else { return }
        
        let imageName = UUID().uuidString
        let refStorage = Storage.storage().reference().child("profileImages").child("\(imageName).png")
        
        if let uploadImageData =  UIImageJPEGRepresentation(self.profileImageView.image!, 0.1) {
            refStorage.putData(uploadImageData, metadata: nil, completion: { (metadata, error) in
                
                if error != nil {
                    print(error!)
                    return
                }
                
                if let profileImageUrl = metadata?.downloadURL()?.absoluteString {
                    let values = ["name" : username ,"phone": phone , "profileImageUrl" : profileImageUrl]
                    
                    self.registerUserWithUid(uid: uid, values: values as [String : AnyObject])
                }
                
                
            })
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
            
            
            UpdateUser.shared.shouldBeReloaded.value = true
            self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
            
            
        })
        
    }

    
    

    

}

extension UserInfoViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        usernameTextField.resignFirstResponder()
        return true
    }
    
    
}

extension UserInfoViewController : UINavigationControllerDelegate , UIImagePickerControllerDelegate {
    
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
