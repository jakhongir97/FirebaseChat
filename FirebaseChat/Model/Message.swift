//
//  Message.swift
//  FirebaseChat
//
//  Created by Jahongir Nematov on 4/13/18.
//  Copyright © 2018 Jahongir Nematov. All rights reserved.
//

import Foundation
import Firebase

struct Message {
    var fromId : String?
    var text : String?
    var timestamp : NSNumber?
    var toId : String?
    
    var imageUrl : String?
    var imageHeight : NSNumber?
    var imageWidth: NSNumber?
    
    func chatPartnerId() -> String? {
        return fromId == Auth.auth().currentUser?.uid ? toId : fromId
    }
}
