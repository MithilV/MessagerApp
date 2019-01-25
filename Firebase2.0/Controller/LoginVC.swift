//
//  ViewController.swift
//  FirebaseExample
//
//  Created by mithil on 1/17/19.
//  Copyright © 2019 mithil. All rights reserved.
//

import UIKit
import FirebaseAuth
import SwiftKeychainWrapper
class LoginVC: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    
    @IBOutlet weak var mybutton: UIButton!
    @IBOutlet weak var passwordField: UITextField!
    
    var userUid: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "fade")!)
        // Do any additional setup after loading the view, typically from a nib.
        
        emailField.font = UIFont(name: "HelveticaNeue", size: (emailField.font?.pointSize)!)
        passwordField.font = UIFont(name: "HelveticaNeue", size: (passwordField.font?.pointSize)!)
        mybutton.titleLabel?.font = UIFont(name: "HelveticaNeue", size: (mybutton.titleLabel?.font.pointSize)!)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let _ = KeychainWrapper.standard.string(forKey: "uid"){
            performSegue(withIdentifier: "toMessages", sender: nil)
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSignUp"{
            if let destination = segue.destination as? SignUpVC{
                if self.userUid != nil{
                    destination.userUid = userUid
                    
                }
                if self.emailField.text != nil{
                    destination.emailField = emailField.text
                    
                }
            
                if self.passwordField.text != nil{
                    destination.passwordField = passwordField.text
                }
            }
            
        }
    }
    
    @IBAction func SignIn(sender:AnyObject){
        if let email = emailField.text, let password = passwordField.text{
            Auth.auth().signIn(withEmail: email, password: password, completion: {(user, error) in
                if error == nil {
                    self.userUid = user?.user.uid
                    
                    KeychainWrapper.standard.set(self.userUid, forKey: "uid")
                    
                    self.performSegue(withIdentifier: "toMessages", sender: nil)
                }else{
                    self.performSegue(withIdentifier: "toSignUp", sender: nil)
                }
            })
        }
        
    }

}

