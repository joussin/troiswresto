//
//  ViewController.swift
//  troiswresto
//
//  Created by etudiant-02 on 01/07/2016.
//  Copyright © 2016 etudiant-02. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FirebaseAuth
import GoogleSignIn
class MainViewController: UIViewController {
    
    @IBOutlet var logoutButton : UIButton!
    @IBOutlet var loginButton : UIButton!
    @IBOutlet var loginLabel: UILabel!
    @IBOutlet var loginIndicator: UIActivityIndicatorView!
    
    
    @IBAction func loginButtonPressed () {
        let storyboard = UIStoryboard(name: "Account", bundle: nil )
        let vc = storyboard.instantiateViewControllerWithIdentifier("loginScreen") as! LoginViewController
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    func initCurrentUser() {
        
        loginIndicator.hidden = false
        loginIndicator.startAnimating()
        loginButton.hidden = true
        logoutButton.hidden = true
        
        
        FirebaseHelper.getcurrentLoggedInUser({ (user) in
 
            self.loginLabel.text = "logged in as: " + user.nickName
            self.loginIndicator.hidden = true
            self.logoutButton.hidden = false
        }) {
            self.loginLabel.text = "not logged"
            self.loginIndicator.hidden = true
            self.loginButton.hidden = false
            self.logoutButton.hidden = true
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
         initCurrentUser()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib. 
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(notificationReceived), name: "reviewsubmitted", object: nil)

    }
    func notificationReceived(notification: NSNotification) {
        print(notification.userInfo)
    }
    
    @IBAction func logoutButtonPressed () {
        FirebaseHelper.logout()
        initCurrentUser()
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

