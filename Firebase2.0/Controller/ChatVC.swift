//
//  ChatVC.swift
//  FirebaseExample
//
//  Created by mithil on 1/18/19.
//  Copyright © 2019 mithil. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import SwiftKeychainWrapper



class ChatVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
   
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var label: UILabel!
    
    var messageDetail = [MessageDetail]()
    
    var detail: MessageDetail!
    var currentUser = KeychainWrapper.standard.string(forKey: "uid")
    var recipient: String!
    var messageId: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        print("MYYYY RECIPIEEEENT" , recipient)
        
       // print("Detol: " , messageDetail)
        let recipientData = Database.database().reference().child("users").child(currentUser!)

        recipientData.observeSingleEvent(of: .value, with: {(snapshot) in
            let data = snapshot.value as! Dictionary<String, AnyObject>
            print("yessliterally " , data)
            let username = data["username"]
            let userImg = data["userImg"]
        })
        //label.text = recipient
    Database.database().reference().child("users").child(currentUser!).child("messages").observe(.value, with: {(snapshot) in
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot]{
            self.messageDetail.removeAll()
                for data in snapshot{
                   print("OMGGGG ITS DATAAAAy: " , data)
                    if let messageDict = data.value as? Dictionary<String, AnyObject>{
                        //label.text = MessageDetail(recipient: )
                        let key = data.key
                        let info = MessageDetail(messageKey: key, messageData: messageDict)
                        self.messageDetail.append(info)
                        
                    }
                }
            }
            self.tableView.reloadData()
        })
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageDetail.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let messageDet = messageDetail[indexPath.row]
        if let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell") as? messageDetailCell{
            cell.configureCell(messageDetail: messageDet)
        return cell
        }else{
    return messageDetailCell()
        }
    }
        
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath:IndexPath){
            recipient = messageDetail[indexPath.row].recipient
            messageId = messageDetail[indexPath.row].messageReg.key
        
            performSegue(withIdentifier: "toMessages", sender: nil)
            }
        override func prepare(for segue: UIStoryboardSegue, sender: Any?){
            if let destinationViewController = segue.destination as? MessageVC {
                destinationViewController.recipient = recipient
                destinationViewController.messageId = messageId
                
        }
        
    }
    
    @IBAction func signOut(_ sender: AnyObject){
        try! Auth.auth().signOut()
        KeychainWrapper.standard.removeObject(forKey: "uid")
        dismiss(animated: true, completion: nil)
        }
}
