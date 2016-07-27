//
//  ReviewViewController.swift
//  troiswresto
//
//  Created by etudiant-02 on 01/07/2016.
//  Copyright © 2016 etudiant-02. All rights reserved.
//

import UIKit

class AddReviewViewController: UIViewController {
    
    
    var userLogged : User!
    var rating : Int = 0
    var resto : Resto!
    
    @IBOutlet var messageTextView : UITextView!
    @IBOutlet var star1Button : UIButton!
    @IBOutlet var star2Button : UIButton!
    @IBOutlet var star3Button : UIButton!
    @IBOutlet var star4Button : UIButton!
    @IBOutlet var star5Button : UIButton!
    @IBOutlet var sendButton : UIButton!

    @IBAction func viewTapped(){
        messageTextView.resignFirstResponder()
    }
    
    func resetAllStar() {
        star1Button.setTitle("\u{f006}", forState: .Normal)
        star2Button.setTitle("\u{f006}", forState: .Normal)
        star3Button.setTitle("\u{f006}", forState: .Normal)
        star4Button.setTitle("\u{f006}", forState: .Normal)
        star5Button.setTitle("\u{f006}", forState: .Normal)
    }
    
    
    @IBAction func starPressed(sender: UIButton ) {
        self.rating = sender.tag
        
        switch rating {
        case 1:
            resetAllStar()
            star1Button.setTitle("\u{f005}", forState: .Normal)
            
        case 2:
            resetAllStar()
            star1Button.setTitle("\u{f005}", forState: .Normal)
            star2Button.setTitle("\u{f005}", forState: .Normal)
        case 3:
            resetAllStar()
            star1Button.setTitle("\u{f005}", forState: .Normal)
            star2Button.setTitle("\u{f005}", forState: .Normal)
            star3Button.setTitle("\u{f005}", forState: .Normal)
        case 4:
            resetAllStar()
            star1Button.setTitle("\u{f005}", forState: .Normal)
            star2Button.setTitle("\u{f005}", forState: .Normal)
            star3Button.setTitle("\u{f005}", forState: .Normal)
            star4Button.setTitle("\u{f005}", forState: .Normal)
        case 5:
            resetAllStar()
            star1Button.setTitle("\u{f005}", forState: .Normal)
            star2Button.setTitle("\u{f005}", forState: .Normal)
            star3Button.setTitle("\u{f005}", forState: .Normal)
            star4Button.setTitle("\u{f005}", forState: .Normal)
            star5Button.setTitle("\u{f005}", forState: .Normal)
        default:
            break
        }
        
        
    }
    
    @IBAction func sendPressed () {
        if rating == 0 || messageTextView.text == "" {
            let alert = UIAlertController(title: "Error", message: "veuillez selectionner une note et entrer un message", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        } else {
            
            let review = Review(reviewerId: userLogged.id , rating: Double(self.rating), date: NSDate() )
            review.comment = messageTextView.text
            review.reviewerName = userLogged.nickName
            
            
            FirebaseHelper.sendReviewForResto( self.resto, review: review){ error in
                    // avis ajouté avec succes
                NSNotificationCenter.defaultCenter().postNotificationName("reviewsubmitted", object: nil, userInfo: ["rating" : review.rating, "message" : self.messageTextView.text])
                self.navigationController?.popViewControllerAnimated(true)
            }
        }
    }
    
    override func viewWillAppear(animated : Bool){
       
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
