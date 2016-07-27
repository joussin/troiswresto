//
//  InviteViewController.swift
//  troiswresto
//
//  Created by etudiant-02 on 20/07/2016.
//  Copyright © 2016 etudiant-02. All rights reserved.
//

import UIKit
import AddressBook



class Contact {
    var email : String
    var name : String?
    var invited = false
    var thumbnail : UIImage?
    
    init (email : String) {
        self.email = email
    }
}



class InviteViewController: UIViewController {
    
    
    @IBOutlet var tableView : UITableView!
    @IBOutlet var inviteButton : UIButton!
     var userLogged : User?
    var contacts = [Contact]()
    var resto : Resto!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkForPermission()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func inviteButtonPressed (){
        FirebaseHelper.createChatRoom(resto) { (error, chatroomKey) in
            

            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("chatRoom") as! ChatViewController
            vc.resto = self.resto
            vc.chatroomKey = chatroomKey
            vc.userLogged = self.userLogged
            self.presentViewController(vc, animated: true, completion: nil)
            
        }
    }
    
    func checkForPermission() {
        let authorizationStatus = ABAddressBookGetAuthorizationStatus()
        
        switch authorizationStatus {
        case .Denied, .Restricted:
            //1
            print("Denied")
            displayCantAddContactAlert()
        case .Authorized:
            //2
            print("Authorized")
            browseContacts()
        case .NotDetermined:
            //3
            print("Not Determined")
            promptForAddressBookRequestAccess()
        }
    }
    
    func displayCantAddContactAlert() {
        let cantAddContactAlert = UIAlertController(title: "Cannot Add Contact",
                                                    message: "You must give the app permission to add the contact first.",
                                                    preferredStyle: .Alert)
        cantAddContactAlert.addAction(UIAlertAction(title: "Change Settings",
            style: .Default,
            handler: { action in
                self.openSettings()
        }))
        cantAddContactAlert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
        presentViewController(cantAddContactAlert, animated: true, completion: nil)
    }
    
    func openSettings() {
        let url = NSURL(string: UIApplicationOpenSettingsURLString)
        UIApplication.sharedApplication().openURL(url!)
    }
    
    func promptForAddressBookRequestAccess() {
        let addressBookRef: ABAddressBook = ABAddressBookCreateWithOptions(nil, nil).takeRetainedValue()
        ABAddressBookRequestAccessWithCompletion(addressBookRef) {
            (granted: Bool, error: CFError!) in
            dispatch_async(dispatch_get_main_queue()) {
                if !granted {
                    print("Just denied")
                } else {
                    print("Just authorized")
                    self.browseContacts()
                }
            }
        }
    }
    
    func browseContacts() {
        let addressBookRef: ABAddressBook = ABAddressBookCreateWithOptions(nil, nil).takeRetainedValue()
        self.contacts = [Contact]()
        
        var userEmails = [String]()
        
        let myAllContacts = ABAddressBookCopyArrayOfAllPeople(addressBookRef).takeRetainedValue() as Array
        
        //création du tableau contacts
        for contact in myAllContacts {
            let emails = ABRecordCopyValue(contact, kABPersonEmailProperty).takeRetainedValue()
            
            let count = ABMultiValueGetCount(emails)
            if count > 0 {
                for index in 0..<count
                {
                    if let email = ABMultiValueCopyValueAtIndex(emails, index).takeRetainedValue() as? String {
                        let myContact = Contact(email : email)
                        
                        
                        if  ABRecordCopyCompositeName(contact) != nil {
                            let name = ABRecordCopyCompositeName(contact).takeRetainedValue() as String
                            myContact.name = name
                        }
                        
                        if ABPersonCopyImageDataWithFormat(contact, kABPersonImageFormatThumbnail) != nil {
                            myContact.thumbnail = UIImage(data:ABPersonCopyImageDataWithFormat(contact, kABPersonImageFormatThumbnail).takeRetainedValue())
                        }
                        self.contacts.append(myContact)
                    }
                }
            }
        }
        
        self.tableView.reloadData()
        
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



extension InviteViewController : UITableViewDelegate, UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // A modifier, retourner le nombre de ligne dans la section
        return self.contacts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ContactCell", forIndexPath: indexPath) as! ContactCell
        
        if indexPath.row <= contacts.count {
            if  contacts[indexPath.row].name != nil {
                 cell.nomLabel.text =  contacts[indexPath.row].name
            } else {
                 cell.nomLabel.text = ""
            }
            
            cell.emailLabel.text =  contacts[indexPath.row].email
         
            if indexPath.row % 2 == 1 {
                cell.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)
            } else {
                cell.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1.0)
            }
            
            if cell.added {
                cell.checkLabel.text = "\u{f046}"

            } else {
                cell.checkLabel.text = "\u{f096}"
            }
            
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
 
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! ContactCell
        
        if cell.added {
            cell.added = false
        } else {
             cell.added = true
        }
        tableView.reloadData()
        
    }
}










 