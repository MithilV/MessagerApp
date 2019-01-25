//
//  searchCell.swift
//  FirebaseExample
//
//  Created by mithil on 1/18/19.
//  Copyright © 2019 mithil. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage
import SwiftKeychainWrapper
class searchCell: UITableViewCell {

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    
    var searchDetail: Search!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configCell(searchDetail: Search){
        self.searchDetail = searchDetail
        self.nameLbl.font = UIFont(name: "HelveticaNeue", size: (self.nameLbl.font?.pointSize)!)

        nameLbl.text = searchDetail.username
        
        let ref = Storage.storage().reference(forURL: searchDetail.userImg)
        ref.getData(maxSize: 1000000, completion: {(data,error) in
            if error != nil{
                print("We couldn't upload the image")
            }
            else{
                if let imgData = data{
                    if let img = UIImage(data: imgData){
                    //self.userImage.layer.borderWidth = 1.0
                    self.userImage.layer.masksToBounds = false
                    //self.userImage.layer.borderColor = UIColor.white.cgColor
                    self.userImage.layer.cornerRadius = self.userImage.frame.size.width/2
                    self.userImage.clipsToBounds = true
                    self.userImage.image = img
                    
                  
                    
                    }
                }
            }
            
        })
        
    }

}
