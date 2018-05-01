//
//  AppDelegate.swift
//  FirebaseChat
//
//  Created by Jahongir Nematov on 4/10/18.
//  Copyright © 2018 Jahongir Nematov. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        
        window?.rootViewController = UINavigationController(rootViewController: MessagesController())
//        window?.rootViewController = VerificationViewController()

        return true
    }



}

