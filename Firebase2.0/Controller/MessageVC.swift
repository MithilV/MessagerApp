//
//  MessageVC.swift
//  FirebaseExample
//
//  Created by mithil on 1/18/19.
//  Copyright © 2019 mithil. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import SwiftKeychainWrapper
class MessageVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate{

    @IBOutlet weak var camera: UIButton!
    @IBOutlet weak var messager: UILabel!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var messageField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    var messageId: String!
    var messages = [Message]()
    var message: Message!
    var myDetail: MessageDetail!
    var currentUser = KeychainWrapper.standard.string(forKey: "uid")
    
    var recipient: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Me Detail : " , myDetail)
        
        camera.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleUploadTap)))
        
        
        
        messageField.font = UIFont(name: "HelveticaNeue", size: (messageField.font?.pointSize)!)
        sendButton.titleLabel?.font = UIFont(name: "HelveticaNeue", size: (sendButton.titleLabel?.font?.pointSize)!)


        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 300
        if messageId != "" && messageId != nil{
            loadData()
        }
        
        print("WE Are Here: " , message)
        let recipientData = Database.database().reference().child("users").child(recipient)
        
        recipientData.observeSingleEvent(of: .value, with: {(snapshot) in
            let data = snapshot.value as! Dictionary<String, AnyObject>
            print("yessliterally " , data["username"])
            let username = data["username"]
            let userImg = data["userImg"]
            self.messager.text = username as? String
            
        })
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        
        view.addGestureRecognizer(tap)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)){
            self.moveToBottom()
        }
    }
    
    @objc func handleUploadTap(){
        print("we tapped upload")
        let imagePick = UIImagePickerController()
        present(imagePick, animated: true, completion: nil)
        imagePick.delegate = self
        imagePick.allowsEditing = true
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print("we selected an image")
        
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as?
            UIImage{
            selectedImageFromPicker = editedImage
        } else if let originalImage =
            info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        if let selectedImage = selectedImageFromPicker{
            uploadToFirebaseStorageUsingImage(image: selectedImage)
        }
        dismiss(animated: true, completion: nil)
    
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
        
    }
    private func uploadToFirebaseStorageUsingImage(image: UIImage)
    {
        let imageName = NSUUID().uuidString
        let ref = Storage.storage().reference().child("message_img").child(imageName)
        print("Upload to firebase")
        
        if let uploadData = UIImageJPEGRepresentation(image, 0.2){
            ref.putData(uploadData, metadata: nil, completion: {(
                metadata, error) in
                if error != nil{
                    print("failed to upload" , error)
                    return
                }
                ref.downloadURL(completion: { (url, err) in
                    if err != nil{
                        print(err as Any)
                        return
                    }
                    else{
                        let imageUrl = url?.absoluteString
                       // self.sendMessageWithImageURL(imageUrl: imageUrl!)
                        print(imageUrl)
                    }
                })
                
            })
        }
    }
    /*
    private func sendMessageWithImageURL(imageUrl: String){
        let ref = Database.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        let toId = user!.id!
        let fromId = Auth.auth().currentUser!.uid
        let timestamp: NSNumber = Int(NSDate().timeIntervalSince1970)
        let values = ["imageUrl": imageUrl, "toId": toId, "fromId" : fromId, "timestamp" : timestamp]
        childRef.updateChildValues(values){(error, ref) in
            if error != nil{
                print(error)
                return
            }
            self.inputTextField.text = nil
            let userMessagesRef = Database.database().reference().child("user-messages").child(fromId).child(toId)
            
            let messageId = childRef.key
            userMessagesRef.updateChildValues([messageId: 1])
            
            let recipientUserMessageRef = Database.database().reference().child("user-messages").child(toId).child(fromId)
            recipientUserMessageRef.updateChildValues([messageId: 1])
            
        }
    }
 */
    @objc func keyboardWillShow(notify: NSNotification){
        if let keyboardSize = (notify.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue{
            if self.view.frame.origin.y == 0 {
                
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
        
    }
    
    @objc func dismissKeyboard(){
        view.endEditing(true)
    }
    
    @objc func keyboardWillHide(notify: NSNotification){
        if let keyboardSize = (notify.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue{
            if self.view.frame.origin.y != 0 {
                self.view.frame.origin.y += keyboardSize.height
                
            }
        }
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        if let cell = tableView.dequeueReusableCell(withIdentifier: "Message") as? MessagesCell{
            cell.configCell(message: message)
            return cell
            
        }
        else{
            return MessagesCell()
        }
    }
    
    func loadData(){
        Database.database().reference().child("messages").child(messageId).observe(.value, with: {(snapshot) in
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot]{
                self.messages.removeAll()
                for data in snapshot{
                    if let postDict = data.value as? Dictionary<String, AnyObject>{
                        let key = data.key
                        let post = Message(messageKey: key, postData: postDict)
                        self.messages.append(post)
                    }
                }
            }
            
            self.tableView.reloadData()
        })
    }
    func moveToBottom(){
        if messages.count  > 0{
            let indexPath = IndexPath(row: messages.count-1, section: 0)
            tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
        }
    }

    @IBAction func sendPressed(_ sender: AnyObject){
        dismissKeyboard()
        if (messageField.text != nil && messageField.text != ""){
            
            print("hello")
            if messageId == nil{
                print("hi")
                let post: Dictionary <String, AnyObject> = [
                    "message":messageField.text as AnyObject,
                    "sender": recipient as AnyObject
                ]
                let message: Dictionary <String, AnyObject> = [
                    "lastmessage":messageField.text as AnyObject,
                    "recipient": recipient as AnyObject
                ]
                let recipientMessage: Dictionary <String, AnyObject> = [
                    "lastmessage":messageField.text as AnyObject,
                    "recipient": currentUser as AnyObject
                ]
                messageId = Database.database().reference().child("messages").childByAutoId().key
                let firebaseMessage = Database.database().reference().child("messages").child(messageId).childByAutoId()
                firebaseMessage.setValue(post)
                
                 let recipentMessage = Database.database().reference().child("users").child(recipient).child("messages").child(messageId)
                recipentMessage.setValue(recipientMessage)
                
                let userMessage = Database.database().reference().child("users").child(currentUser!).child("messages").child(messageId)
                userMessage.setValue(message)
                
                loadData()
                
            }
            else if messageId != "" {
                
                let post: Dictionary <String, AnyObject> = [
                    "message":messageField.text as AnyObject,
                    "sender": recipient as AnyObject
                ]
                let message: Dictionary <String, AnyObject> = [
                    "lastmessage":messageField.text as AnyObject,
                    "recipient": recipient as AnyObject
                ]
                let recipientMessage: Dictionary <String, AnyObject> = [
                    "lastmessage":messageField.text as AnyObject,
                    "recipient": currentUser as AnyObject
                ]
                let firebaseMessage = Database.database().reference().child("messages").child(messageId).childByAutoId()
                firebaseMessage.setValue(post)
                
                let recipentMessage = Database.database().reference().child("users").child(recipient).child("messages").child(messageId)
                recipentMessage.setValue(recipientMessage)
                
                let userMessage = Database.database().reference().child("users").child(currentUser!).child("messages").child(messageId)
                userMessage.setValue(message)
                
                loadData()
                
            }
            messageField.text = ""
            
        }
        moveToBottom()
        
        
    }
    @IBAction func backPressed(_ sender:AnyObject){
        dismiss(animated: true,completion: nil)
    }

}
