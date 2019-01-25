//
//  MessagesCell.swift
//  FirebaseExample
//
//  Created by mithil on 1/18/19.
//  Copyright © 2019 mithil. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper

class MessagesCell: UITableViewCell {
    
    @IBOutlet weak var receivedMessageLbl: UILabel!
    @IBOutlet weak var receivedMessageView: UIView!
    @IBOutlet weak var sentMessageLbl: UILabel!
    @IBOutlet weak var sentMessageView: UIView!
    
    var message: Message!
    
    var currentUser = KeychainWrapper.standard.string(forKey: "uid")
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configCell(message: Message){
        self.message = message
        
        sentMessageView.layer.cornerRadius = 5
        sentMessageView.layer.masksToBounds = true
        
        sentMessageLbl.font = UIFont(name: "HelveticaNeue", size: (sentMessageLbl.font?.pointSize)!)
        receivedMessageLbl.font = UIFont(name: "HelveticaNeue", size: (receivedMessageLbl.font?.pointSize)!)


        
        receivedMessageView.layer.cornerRadius = 5
        receivedMessageView.layer.masksToBounds = true
        
        if message.sender == currentUser{
            sentMessageView.isHidden = true
            sentMessageLbl.text = ""
            receivedMessageView.isHidden = false
            receivedMessageLbl.text = message.message
        }else{
            sentMessageView.isHidden = false
            sentMessageLbl.text = message.message
            receivedMessageView.isHidden = true
            receivedMessageLbl.text = ""
            
        }
        
    }

}
