//
//  CreateAccountViewController.swift
//  troiswresto
//
//  Created by etudiant-02 on 13/07/2016.
//  Copyright © 2016 etudiant-02. All rights reserved.
//

import Foundation
import UIKit



class CreateAccountViewController: UIViewController {
    
    var emailIsChanged = false
    var pseudoIsChanged = false
    
    @IBOutlet var backButton : UIButton!
    
    @IBOutlet var emailTextField : UITextField!
    @IBOutlet var passwordTextField : UITextField!
    @IBOutlet var repasswordTextField : UITextField!
    @IBOutlet var pseudoTextField : UITextField!
    
    @IBOutlet var createButton : UIButton!
    
    @IBAction func viewTapped () {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        repasswordTextField.resignFirstResponder()
        pseudoTextField.resignFirstResponder()

    }
    
    @IBAction func createButtonPressed () {
        
        if !emailIsValid(emailTextField.text!) || !passwordIsValid (passwordTextField.text!,password2: repasswordTextField.text!)  || !pseudoIsValid(pseudoTextField.text!) {
            let alert = UIAlertController(title: "Error", message: "email ou pass ou pseudo incorrect", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        } else {
            //CREATE ACCOUNT WITH FIREBASE
            FirebaseHelper.addUser(emailTextField.text!, password: passwordTextField.text!, completion: { (user, error) in
                if error == nil {
                    
                    let user_ = User(email: self.emailTextField.text!, nickName:  self.pseudoTextField.text! , id: user!.uid)
                    
                    FirebaseHelper.addUserToDatabase(user_ ) { error in
                        let alert = UIAlertController(title: "Account created", message: "Votre compte est créé", preferredStyle: .Alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                } else {
                    if error!.code == 17007 {
                        let alert = UIAlertController(title: "Error", message: "Email déjà utilisé", preferredStyle: .Alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                        self.presentViewController(alert, animated: true, completion: nil)

                    }
                }
            })
        }
    }
    
    @IBAction func emailTextFieldDidChange(sender: UITextField ){
        emailIsChanged = true
    }
    
    @IBAction func emailTextFieldDidBeginEditing (sender : UITextField) {
        if !emailIsChanged {
            sender.text = ""
        }
    }
    
    @IBAction func pseudoTextFieldDidChange(sender: UITextField ){
        pseudoIsChanged = true
    }
    
    @IBAction func pseudoTextFieldDidBeginEditing (sender : UITextField) {
        if !pseudoIsChanged {
            sender.text = ""
        }
    }
    
 
    
    @IBAction func backButtonPressed () {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func emailIsValid (email : String) -> Bool {
        if Utils.isValidEmail(email) {
            return true
        }
        return false
    }
    
    func passwordIsValid (password : String, password2 : String) -> Bool {
        
        if password.characters.count > 1  && password == password2 {
            return true
        }
        return false
    }
    
    func pseudoIsValid (pseudo : String) -> Bool {
        
        if pseudo.characters.count > 1 {
            return true
        }
        return false
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

