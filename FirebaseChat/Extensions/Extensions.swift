//
//  Extensions.swift
//  FirebaseChat
//
//  Created by Jahongir Nematov on 4/12/18.
//  Copyright © 2018 Jahongir Nematov. All rights reserved.
//

import Foundation
import UIKit


extension UIColor {
    static let amazingBlue = UIColor(named: "amazingBlue")
    static let amazingOrange = UIColor(named: "amazingOrange")
    static let amazingBrown = UIColor(named: "amazingBrown")
    
}

extension UIViewController {
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
