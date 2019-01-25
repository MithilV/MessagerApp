//
//  SignUpVC.swift
//  FirebaseExample
//
//  Created by mithil on 1/17/19.
//  Copyright © 2019 mithil. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import SwiftKeychainWrapper

class SignUpVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    @IBOutlet weak var userImagePicker: UIImageView!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var  signUpBtn: UIButton!
    @IBOutlet weak var cancel: UIButton!

    @IBOutlet weak var photo: UIButton!
    
    var userUid: String!
    var emailField: String!
    var passwordField: String!
    var imagePicker: UIImagePickerController!
    var imageSelected = false
    var username: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "fade")!)
        // Do any additional setup after loading the view.
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        //cancel.layer.borderWidth = 1.0
        //cancel.frame = CGRect(x: 0, y: 0, width: 10, height: 5)
        //cancel.layer.borderColor = UIColor.white.cgColor
        
        let imagey = UIImage(named: "avatar")
        photo.setBackgroundImage(imagey, for: UIControlState.normal)
        photo.center.x = self.view.center.x
        
        signUpBtn.center.x = self.view.center.x
        signUpBtn.titleLabel?.font = UIFont(name: "HelveticaNeue", size: (signUpBtn.titleLabel?.font?.pointSize)!)

        
        usernameField.center.x = self.view.center.x
        usernameField.font = UIFont(name: "HelveticaNeue", size: (usernameField.font?.pointSize)!)

        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if let _ = KeychainWrapper.standard.string(forKey: "uid"){
            performSegue(withIdentifier: "toMessages", sender: nil)
        }
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage{
            self.photo.isHidden = true
            self.userImagePicker.layer.cornerRadius = (self.userImagePicker.frame.size.width ) / 2
            self.userImagePicker.clipsToBounds = true
            self.userImagePicker.center.x = self.view.center.x
            userImagePicker.image = image
            imageSelected = true
            
        }else{
            print("Image wasn't selected")
        }
        picker.dismiss(animated: true, completion: nil)
    }
    func setUser(img: String){
    let userData = [
    "username": username!,
    "userImg": img]
    
    KeychainWrapper.standard.set(userUid, forKey: "uid")
    
    let location = Database.database().reference().child("users").child(userUid)
        location.setValue(userData)
        dismiss(animated: true, completion: nil)
    }
    
    func uploadImg(){
        if usernameField.text == nil{
            signUpBtn.isEnabled = false
            
        }else{
            username = usernameField.text
            signUpBtn.isEnabled = true
        }
        guard let image = userImagePicker.image, imageSelected == true else{
            print("image needs to be selected")
            return
        }
        if let imageData = UIImageJPEGRepresentation(image, 0.2){
            let imgUid = NSUUID().uuidString
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            let storageRef = Storage.storage().reference().child(imgUid)
                storageRef.putData(imageData, metadata: metadata){
                (metadata, error) in
                if error != nil{
                    print("did not upload image")
                    print("ERRRORRRR: " , error)
                }
                else{
                    print("uploaded")
                    self.photo.removeFromSuperview()
                   // let downloadurl = storageRef.downloadURL()?.absoluteString
                    storageRef.downloadURL(completion: { (url, error) in
                    if let url = url?.absoluteString{
                        self.setUser(img: url)
                    }
                    })
                }
            }
        }
    }
    
    @IBAction func createAccount(_ sender:UIButton){
        Auth.auth().createUser(withEmail: emailField, password: passwordField, completion: {(user, error) in
            print("Error" , error)
            if error != nil{
                print("can't create user")
            }
            else{
                if let user = user{
                    self.userUid = user.user.uid
                }
            }
            self.uploadImg()
        })
    }
    
    @IBAction func selectedImgPicker(_ sender: AnyObject){
          present(imagePicker, animated: true, completion: nil)
        
    }
    
    @IBAction func cancel(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
   



}
