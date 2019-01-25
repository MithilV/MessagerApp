//
//  messageDetailCell.swift
//  FirebaseExample
//
//  Created by mithil on 1/18/19.
//  Copyright © 2019 mithil. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import FirebaseDatabase
import SwiftKeychainWrapper

class messageDetailCell: UITableViewCell {
    
    
    @IBOutlet weak var recipientImage: UIImageView!
    @IBOutlet weak var recipientName: UILabel!
    @IBOutlet weak var chatPreview: UILabel!
    
    var messageDetail: MessageDetail!

    var userPostKey: DatabaseReference!
    var myArr = [String]()
    let currentUser = KeychainWrapper.standard.string(forKey: "uid")
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

    
    func configureCell(messageDetail: MessageDetail){
    self.messageDetail = messageDetail
        self.recipientName.font = UIFont(name: "HelveticaNeue", size: (self.recipientName.font?.pointSize)!)
        self.chatPreview.font = UIFont(name: "HelveticaNeue", size: (self.chatPreview.font?.pointSize)!)
        

        
        let messageData = Database.database().reference().child("users").child(messageDetail.recipient).child("messages").child(messageDetail.messageKey)
        
        messageData.observeSingleEvent(of: .value, with: {(snapshot) in
            let data = snapshot.value as! Dictionary<String, AnyObject>
            
            self.chatPreview.text = data["lastmessage"] as? String
            self.chatPreview.font = UIFont(name: "Helvetica", size: self.chatPreview.font.pointSize)
            print("Message Data: " , data["lastmessage"])
        })
        
        let recipientData = Database.database().reference().child("users").child(messageDetail.recipient)
        
        recipientData.observeSingleEvent(of: .value, with: {(snapshot) in
            let data = snapshot.value as! Dictionary<String, AnyObject>
            //print("msg, " , messageDetail)
            print("literally " , data)
            let username = data["username"]
            let userImg = data["userImg"]
            
            self.recipientName.text = username as? String
            self.myArr.append(self.recipientName.text!)
            
            
            //self.recipientName.font = UIFont(name: "Helvetica", size: self.recipientName.font.pointSize)
            let ref = Storage.storage().reference(forURL: userImg as! String)
            
            ref.getData(maxSize: 100000, completion: {(data, error) in
                if error != nil{
                    print("Could not load image.")
                }
                else{
                    print("Here it is")
                    if let imageData = data{
                        if let img = UIImage(data: imageData){
                            //self.recipientImage.setRounded()
                            print("HIIIIIIII")
                           // self.recipientImage.frame = CGRect( x:0, y:0, width:200, height:200)
                           // self.layoutSubviews()
                            self.recipientImage.layer.masksToBounds = false
                          //  self.recipientImage = UIImageView(frame: CGRect(0, 0, 100, 100))
                           // self.recipientImage.layer.masksToBounds = false
                            self.recipientImage.layer.cornerRadius = (self.recipientImage.frame.size.width ) / 2

                            //self.recipientImage.layer.cornerRadius = self.recipientImage.frame.size.width/2
                            self.recipientImage.clipsToBounds = true
                            
                            //self.recipientImage.layer.borderColor = UIColor.white.cgColor
                            //self.recipientImage.layer.cornerRadius = self.recipientImage.frame.height/2
                            self.recipientImage.image = img
                           
                        }
                        
                    }
                }
            })
            
        })
    }
    /*
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.recipientImage.layer.cornerRadius = self.recipientImage.frame.height / 2.0
    }
 */
}



/*
extension UIImageView {
    
    func setRounded() {
        self.layer.cornerRadius = (self.frame.width / 2) //instead of let radius = CGRectGetWidth(self.frame) / 2
        self.layer.masksToBounds = true
    }
}
 */

