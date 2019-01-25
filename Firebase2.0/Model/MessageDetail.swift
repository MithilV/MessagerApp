//
//  MessageDetail.swift
//  FirebaseExample
//
//  Created by mithil on 1/18/19.
//  Copyright © 2019 mithil. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase
import SwiftKeychainWrapper

class MessageDetail {
    
    private var _recipient: String!
    private var _messageKey: String!
    private var _messageRef: DatabaseReference!
    
    var currentUser = KeychainWrapper.standard.string(forKey: "uid")
    var recipient: String {
        return _recipient
    }
    var messageKey:String{
        return _messageKey
    }
    
    var messageReg: DatabaseReference{
        return _messageRef
    }
    
    init(recipient:String) {
        self._recipient = recipient
        
    }
    init(messageKey:String, messageData: Dictionary<String, AnyObject>) {
        self._messageKey = messageKey
        if let recipient = messageData["recipient"] as? String {
            self._recipient = recipient
        }
        
        _messageRef = Database.database().reference().child("recipient").child(_messageKey)
    }
    
}
