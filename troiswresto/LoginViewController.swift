//
//  LoginViewController.swift
//  troiswresto
//
//  Created by etudiant-02 on 13/07/2016.
//  Copyright © 2016 etudiant-02. All rights reserved.
//

import Foundation
import UIKit
import FBSDKLoginKit
import FirebaseAuth
import GoogleSignIn

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate, GIDSignInUIDelegate  {
    
    var emailIsChanged = false
    
    var loginFacebook : FBSDKLoginButton!
    
    
    @IBOutlet var googleLoginBTN: UIButton!
    @IBOutlet var facebookView: UIView!
    @IBOutlet var backButton : UIButton!
    @IBOutlet var emailTextField : UITextField!
    @IBOutlet var passwordTextField : UITextField!
    
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var createButton : UIButton!
    
    @IBAction func googleSignInClicked(sender: UIButton) {
        
        print("------------------1111111111")
        GIDSignIn.sharedInstance().signIn()
        
        if  (GIDSignIn.sharedInstance().currentUser != nil) {
             print("------------------222222")
             connectWithGoogleUser(GIDSignIn.sharedInstance().currentUser)
        }
         
    }
    
    @IBAction func backButtonPressed () {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func viewTapped () {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
    
    @IBAction func loginButtonPressed () {
        if !emailIsValid(emailTextField.text!) || !passwordIsValid (passwordTextField.text!) {            let alert = UIAlertController(title: "Error", message: "email mal formatté ou pass incorrect", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        } else {
            //LOGIN WITH FIREBASE
            FirebaseHelper.login(emailTextField.text!, password: passwordTextField.text!, completion: { (user, error) in
                if error == nil {
                    FirebaseHelper.getUserInfo(user!.uid) { user_ in
                        let alert = UIAlertController(title: "Success", message: "vous etes loggé en tant que :" + String(user_) , preferredStyle: .Alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { action in
                            self.dismissViewControllerAnimated(true, completion: nil)
                        }))
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                } else {
                    let alert = UIAlertController(title: "Error", message: error!.userInfo.description, preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            })
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        FirebaseHelper.logout()
        
    }
    
  
            
            
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError?) {
        if let error = error {
            print(error.localizedDescription)
            return
        } else {
            
          
            
            let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, email, friends"])
            graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
                
                let id = result.valueForKey("id")
                
                let pictureRequest = FBSDKGraphRequest(graphPath: "me/picture?type=large&redirect=false", parameters: nil)
                pictureRequest.startWithCompletionHandler({
                    (connection, result, error: NSError!) -> Void in
                    if error == nil {
                        if let imageURL = result.valueForKey("data")?.valueForKey("url") as? String {
                            //Download image from imageURL
                            let url = NSURL(string: imageURL)
                            let data = NSData(contentsOfURL: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check
    
                            
                            let imgView = UIImageView()
                            imgView.frame.origin.x =  100
                            imgView.frame.origin.y =  100
                            imgView.frame.size = CGSize(width: 100, height: 100)
                            imgView.image = UIImage(data: data!)
                            self.view.addSubview(imgView)
                        }

                    } else {
                        print("\(error)")
                    }
                })
                
                
            })
            
            
            let token = FBSDKAccessToken.currentAccessToken()
            if token != nil {
                let credential = FIRFacebookAuthProvider.credentialWithAccessToken(token.tokenString)
                
                FIRAuth.auth()?.signInWithCredential(credential) { (user, error) in
                     let user_ = User(email: user!.email!, nickName: "pseudo FB", id: user!.uid)
                    FirebaseHelper.addUserToDatabase(user_, completion: { (error) in
                        
                         self.dismissViewControllerAnimated(true, completion: nil)
                    })
                }
            }
        }
    }
        
 
    
    func signIn(signIn: GIDSignIn!, didSignInForUser user: GIDGoogleUser!, withError error: NSError?) {
        print("didSignInForUser")
        
        if let error = error {
             return
        } else {
            let authentication = user.authentication
            let credential = FIRGoogleAuthProvider.credentialWithIDToken(authentication.idToken,
                                                                         accessToken: authentication.accessToken)
            FIRAuth.auth()?.signInWithCredential(credential) { (user, error) in
                let user_ = User(email: user!.email!, nickName: Utils.emailToNickName(user!.email!) , id: user!.uid)
                FirebaseHelper.addUserToDatabase(user_, completion: { (error) in
                    self.dismissViewControllerAnimated(true, completion: nil)
                })
            }
        }
    }
    
    func connectWithGoogleUser(user: GIDGoogleUser!){
        
        print("connectWithGoogleUser")

        let authentication = user.authentication
        let credential = FIRGoogleAuthProvider.credentialWithIDToken(authentication.idToken,accessToken: authentication.accessToken)
                                                                     
        FIRAuth.auth()?.signInWithCredential(credential) { (user, error) in
            let user_ = User(email: user!.email!, nickName: Utils.emailToNickName(user!.email!) , id: user!.uid)
            FirebaseHelper.addUserToDatabase(user_, completion: { (error) in
                self.dismissViewControllerAnimated(true, completion: nil)
            })
        }
    }
    
    
    
    @IBAction func createButtonPressed () {
        let storyboard = UIStoryboard(name: "Account", bundle: nil )
        let vc = storyboard.instantiateViewControllerWithIdentifier("createAccountScreen") as! CreateAccountViewController
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    @IBAction func textFieldDidChange(sender: UITextField ){
        emailIsChanged = true
    }
    
    @IBAction func textFieldDidBeginEditing (sender : UITextField) {
        if !emailIsChanged {
            sender.text = ""
        }
    }
    
    func emailIsValid (email : String) -> Bool {
        if Utils.isValidEmail(email) {
            return true
        }
        return false
    }
    
    func passwordIsValid (password : String) -> Bool {
        
        if password.characters.count > 1 {
            return true
        }
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        loginFacebook = FBSDKLoginButton()
        loginFacebook.frame.origin.x +=  loginFacebook.frame.width/2
         loginFacebook.frame.origin.y +=  loginFacebook.frame.height/2
        loginFacebook.hidden = false
        loginFacebook.delegate = self
        loginFacebook.readPermissions = ["public_profile", "email", "user_friends"]
        self.facebookView.addSubview(loginFacebook)
        
            let gglButton = GIDSignInButton()
        gglButton.frame.origin.y +=  50
        // self.facebookView.addSubview(gglButton)
        
         GIDSignIn.sharedInstance().uiDelegate = self
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

