//
//  Message.swift
//  ChatFirebase
//
//  Created by Nguyen The Phuong on 11/29/17.
//  Copyright © 2017 Nguyen The Phuong. All rights reserved.
//

import UIKit
import Firebase

@objcMembers
class Message: NSObject {
    @objc var fromId: String?
    @objc var text: String?
    @objc var timestamp: NSNumber?
    @objc var toId: String?
    
    func getChatPartnerId() -> String?{
        return fromId == FIRAuth.auth()?.currentUser?.uid ? toId : fromId
    }
}
