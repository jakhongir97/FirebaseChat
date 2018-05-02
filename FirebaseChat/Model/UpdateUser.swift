//
//  UpdateUser.swift
//  FirebaseChat
//
//  Created by Jahongir Nematov on 5/2/18.
//  Copyright © 2018 Jahongir Nematov. All rights reserved.
//

import Foundation
import RxSwift

class UpdateUser {
    
    static let shared = UpdateUser()
    
    var shouldBeReloaded = Variable(false)
    
}
