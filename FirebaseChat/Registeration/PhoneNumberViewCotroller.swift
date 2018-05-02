//
//  PhoneNumberViewCotroller.swift
//  FirebaseChat
//
//  Created by Jahongir Nematov on 4/30/18.
//  Copyright © 2018 Jahongir Nematov. All rights reserved.
//

import UIKit
import FirebaseAuth
import RxSwift
import RxCocoa
import SnapKit
import CTKFlagPhoneNumber
import NVActivityIndicatorView

class PhoneNumberViewCotroller: UIViewController , UITextFieldDelegate {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    var phoneNumber = Variable<String>("")
    
    let disposeBag = DisposeBag()
    
    
    let headerLabel : UILabel = {
        var label = UILabel()
        label.text = "Phone Number Verification"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 24, weight: .medium)
        label.textColor = .amazingBrown
        return label
    }()
    
    let detailLabel : UILabel = {
        var label = UILabel()
        label.text = "Enter phone Number"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        label.textColor = .lightGray
        return label
    }()
    
    let phoneNumberTextField : CTKFlagPhoneNumberTextField = {
        var textfield = CTKFlagPhoneNumberTextField()
        textfield.setFlag(with: "UZ")
        textfield.borderStyle = .none
        textfield.flagSize = CGSize(width: 30, height: 30)
        textfield.font = UIFont.systemFont(ofSize: 22, weight: .medium)
        textfield.textColor = .white
        textfield.keyboardType = .phonePad
        textfield.keyboardAppearance = .dark
        textfield.tintColor = UIColor.amazingBrown
        return textfield
    }()
    
    let lineView : UIView = {
        var view = UIView()
        view.backgroundColor = UIColor.white
        return view
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
        
        phoneNumberTextField.parentViewController = self
        setupView()
        phoneNumberValidation()
        self.hideKeyboardWhenTappedAround()
        

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.activityIndicator.stopAnimating()
    }
    
    private func setupView(){
        
        view.backgroundColor = .amazingBlue
        
        view.addSubview(headerLabel)
        view.addSubview(detailLabel)
        view.addSubview(phoneNumberTextField)
        view.addSubview(nextButton)
        view.addSubview(lineView)
        view.addSubview(activityIndicator)
        
        phoneNumberTextField.snp.makeConstraints { (make) in
            make.center.equalTo(view)
            make.height.equalTo(50)
            make.width.equalTo(250)
        }
        
        lineView.snp.makeConstraints { (make) in
            make.centerX.equalTo(view)
            make.top.equalTo(phoneNumberTextField.snp.bottom)
            make.height.equalTo(2)
            make.width.equalTo(250)
        }
        
        nextButton.snp.makeConstraints { (make) in
            make.centerX.equalTo(view)
            make.height.equalTo(50)
            make.width.equalTo(250)
            make.top.equalTo(phoneNumberTextField.snp.bottom).offset(50)
        }
        
        detailLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(view)
            make.bottom.equalTo(phoneNumberTextField.snp.top).offset(-50)
        }
        
        headerLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(view)
            make.bottom.equalTo(detailLabel.snp.top).offset(-50)
        }
        
        activityIndicator.snp.makeConstraints { (make) in
            make.centerX.equalTo(view)
            make.bottom.equalTo(view).offset(-50)
        }
        
        
        
    }
    
    private func phoneNumberValidation(){
        
        _ = phoneNumberTextField.rx.text.map{$0 ?? "" }.bind(to: phoneNumber)
        
        phoneNumber.asObservable().subscribe(onNext: { [unowned self] number in
            if self.phoneNumberTextField.isValid(phoneNumber: number) {
                self.nextButton.isEnabled = true
                UIView.animate(withDuration: 0.25, animations: {
                    self.nextButton.alpha = 1
                    self.phoneNumberTextField.textColor = .amazingBrown
                    self.phoneNumberTextField.tintColor = .clear
                    self.lineView.backgroundColor = .amazingBrown
                    self.phoneNumberTextField.resignFirstResponder()
                })
                
            } else {
                self.nextButton.isEnabled = false
                UIView.animate(withDuration: 0.25, animations: {
                    self.nextButton.alpha = 0.6
                    self.phoneNumberTextField.textColor = .white
                    self.phoneNumberTextField.tintColor = .amazingBrown
                    self.lineView.backgroundColor = .white
                })
            }
            
        }).disposed(by: disposeBag)
    }
    
    @objc func handleNextAction() {
        
        self.activityIndicator.startAnimating()
        
        guard let phoneNumber = phoneNumberTextField.getFormattedPhoneNumber() else {return}
        
        UserDefaults.standard.set(phoneNumber, forKey: "phoneNumber")
        UserDefaults.standard.set(self.phoneNumberTextField.text, forKey: "phoneNumberFormatted")
        UserDefaults.standard.synchronize()
        
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { (verificationID, error) in
            if let error = error {
                print(error)
                return
            }
            
            UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
            UserDefaults.standard.synchronize()
            
            let verificationViewController = VerificationViewController()
            self.present(verificationViewController, animated: true, completion: nil)
            
            
        }
    }
    

    

   

}
