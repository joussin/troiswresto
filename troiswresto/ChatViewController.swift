//
//  ChatViewController.swift
//  troiswresto
//
//  Created by etudiant-02 on 21/07/2016.
//  Copyright © 2016 etudiant-02. All rights reserved.
//

import UIKit



class ChatViewController: UIViewController, UITextFieldDelegate {

    var userLogged : User?
    var messages = [Message]()
    var resto : Resto!
    var chatroomKey : String!
    
    @IBOutlet var titleLabel : UILabel!
    @IBOutlet var tableView : UITableView!
    @IBOutlet var messageTextfield : UITextField!
    @IBOutlet var sendButton : UIButton!
    
    
    
    func myAnimateViewMoving (up:Bool, moveValue :CGFloat){
        let movementDuration:NSTimeInterval = 0.3
        let movement:CGFloat = ( up ? -moveValue : moveValue)
        UIView.beginAnimations( "animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration )
        self.view.frame = CGRectOffset(self.view.frame, 0,  movement)
        UIView.commitAnimations()
  
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        myAnimateViewMoving(true,moveValue: 250)
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        myAnimateViewMoving(false,moveValue: 250)
    }
    
    @IBAction func closeButtonpressed () {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func sendButtonPressed () {
        if userLogged != nil && self.messageTextfield.text != "" {
            
            let msg = Message(user: userLogged!.nickName , message: messageTextfield.text!, date: NSDate())
            FirebaseHelper.sendMessage(msg, chatroomKey: chatroomKey, completion: { (error) in
                self.messageTextfield.text = ""
                self.messageTextfield.resignFirstResponder()
            })
        } else {
            let alert = UIAlertController(title: "Error", message: "textfield is empty", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .Default , handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)

        }
    }
    
    @IBAction func viewTapped () {
        messageTextfield.resignFirstResponder()
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        titleLabel.text = resto.name
        
        FirebaseHelper.loadMessages(self.chatroomKey) { (message) in
            self.messages.append(message)
            self.tableView.reloadData()
            self.tableView.scrollToBottom()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messageTextfield.delegate = self
        // Do any additional setup after loading the view.
    }

    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    
    
    
    
}




extension ChatViewController : UITableViewDelegate, UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // A modifier, retourner le nombre de ligne dans la section
        return self.messages.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MessageCell", forIndexPath: indexPath) as! MessageCell
        
        if indexPath.row <= messages.count {
            
            cell.userLabel.text = self.messages[indexPath.row].user
            cell.messageLabel.text = self.messages[indexPath.row].message
            cell.dateLabel.text = Utils.dateToString(self.messages[indexPath.row].date)
        
            if indexPath.row % 2 == 1 {
                cell.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)
            } else {
                cell.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1.0)
            }

        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
     
        
    }
}





