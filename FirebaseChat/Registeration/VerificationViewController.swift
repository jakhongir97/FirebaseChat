//
//  VerificationViewController.swift
//  FirebaseChat
//
//  Created by Jahongir Nematov on 4/30/18.
//  Copyright © 2018 Jahongir Nematov. All rights reserved.
//

import UIKit
import FirebaseAuth
import SnapKit
import PinCodeTextField

class VerificationViewController: UIViewController , UITextFieldDelegate {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    let headerLabel : UILabel = {
        var label = UILabel()
        label.text = "Verification Code"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 24, weight: .medium)
        label.textColor = .amazingBrown
        return label
    }()
    
    let detailLabel : UILabel = {
        var label = UILabel()
        label.text = "SMS Verification Code has been sent to:"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        label.textColor = .lightGray
        label.minimumScaleFactor = 0.5
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    let phoneNumberLabel : UILabel = {
        var label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        label.textColor = UIColor.white
        return label
    }()
    
    let errorLabel : UILabel = {
        var label = UILabel()
        label.text = "Pin Code is not correct!"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        label.textColor = .red
        label.isHidden = true
        return label
    }()
    
    let pinCodeLabel : UILabel = {
        var label = UILabel()
        label.text = "Pincode"
        label.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        label.textColor = UIColor.amazingBrown
        return label
    }()
    
    let pinCodeTextField : PinCodeTextField = {
        var textField = PinCodeTextField()
        textField.keyboardType = .phonePad
        textField.font = UIFont.systemFont(ofSize: 24, weight: .medium)
        textField.placeholderColor = .white
        textField.underlineColor = .white
        textField.characterLimit = 6
        textField.textColor = .white
        textField.keyboardAppearance = .dark
        textField.becomeFirstResponder()
        return textField
    }()
    
    let nextButton : UIButton = {
        var button = UIButton()
        button.setTitle("Next", for: .normal)
        button.backgroundColor = UIColor.amazingBrown
        button.layer.cornerRadius = 20
        button.isEnabled = false
        button.alpha = 0.6
        button.addTarget(self, action: #selector(handleNextAction), for: .touchUpInside)
        return button
    }()
   
        

    override func viewDidLoad() {
        super.viewDidLoad()
        
        pinCodeTextField.delegate = self
        
        setupView()

    }
    
    

    private func setupView(){
        
        view.backgroundColor = UIColor.amazingBlue
        
        phoneNumberLabel.text = UserDefaults.standard.string(forKey: "phoneNumberFormatted")
        
        view.addSubview(pinCodeTextField)
        view.addSubview(headerLabel)
        view.addSubview(detailLabel)
        view.addSubview(phoneNumberLabel)
        view.addSubview(pinCodeLabel)
        view.addSubview(errorLabel)
        view.addSubview(headerLabel)
        view.addSubview(nextButton)
        
        pinCodeTextField.snp.makeConstraints { (make) in
            make.center.equalTo(view)
            make.height.equalTo(50)
            make.width.equalTo(250)
        }
        
        nextButton.snp.makeConstraints { (make) in
            make.centerX.equalTo(view)
            make.top.equalTo(pinCodeTextField.snp.bottom).offset(50)
            make.height.equalTo(50)
            make.width.equalTo(250)
        }
        
        errorLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(view)
            make.top.equalTo(nextButton.snp.bottom).offset(20)
        }
        
        pinCodeLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(view)
            make.bottom.equalTo(pinCodeTextField.snp.top).offset(-20)
        }
        
        phoneNumberLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(view)
            make.bottom.equalTo(pinCodeLabel.snp.top).offset(-20)
        }
        
        detailLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(view)
            make.width.equalTo(250)
            make.bottom.equalTo(phoneNumberLabel.snp.top).offset(-20)
        }
        
        headerLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(view)
            make.bottom.equalTo(detailLabel.snp.top).offset(-20)
        }
        
        
    }
    
    
    
    @objc func handleNextAction() {
        
        guard let verificationCode = pinCodeTextField.text else { return }
        guard let verificationID = UserDefaults.standard.string(forKey: "authVerificationID") else {return}


        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: verificationID,
            verificationCode: verificationCode)


        Auth.auth().signIn(with: credential) { (user, error) in
            if let error = error {
                print(error)
                self.errorLabel.isHidden = false
                return
            }


            UserDefaults.standard.set(true, forKey: "isLoggedIn")
            UserDefaults.standard.synchronize()

            let userInfoViewController = UserInfoViewController()
            self.present(userInfoViewController, animated: true, completion: nil)


        }
    }
   

}

extension VerificationViewController : PinCodeTextFieldDelegate {
    

    func textFieldDidBeginEditing(_ textField: PinCodeTextField) {
        nextButton.isEnabled = false
        UIView.animate(withDuration: 0.25, animations: {
            self.nextButton.alpha = 0.6
        })
    }
    
    func textFieldShouldEndEditing(_ textField: PinCodeTextField) -> Bool {
        nextButton.isEnabled = true
        UIView.animate(withDuration: 0.25, animations: {
            self.nextButton.alpha = 1
        })
        return true
    }
}
