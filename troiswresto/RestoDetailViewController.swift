//
//  RestoDetailViewController.swift
//  troiswresto
//
//  Created by etudiant-02 on 01/07/2016.
//  Copyright © 2016 etudiant-02. All rights reserved.
//

import UIKit
import CoreLocation


class RestoDetailViewController: UIViewController, CLLocationManagerDelegate {
    
    var locationFixAchieved = false
    var userLocation : CLLocation!
    
    var userLogged : User?
    var locationManager : CLLocationManager!
    var resto : Resto!
    
    @IBOutlet var myImage : UIImageView!
    @IBOutlet var titleLabel : UILabel!
    @IBOutlet var starLabel : UILabel!
    @IBOutlet var descriptionLabel : UILabel!
    @IBOutlet var addressLabel : UILabel!
    @IBOutlet var tableViewReviews : UITableView!
    @IBOutlet var prixLabel: UILabel!
    @IBOutlet var distanceLabel: UILabel!
    
    
    @IBAction func addReviewButtonPressed (){
        if userLogged == nil {
            let alert = UIAlertController(title: "Error", message: "you must be logged in", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel , handler: nil))
            alert.addAction(UIAlertAction(title: "Login", style: UIAlertActionStyle.Default, handler: { action in
                let storyboard = UIStoryboard(name: "Account", bundle: nil )
                let vc = storyboard.instantiateViewControllerWithIdentifier("loginScreen") as! LoginViewController
                self.presentViewController(vc, animated: true, completion: nil)
            }))
            self.presentViewController(alert, animated: true, completion: nil)
        } else {
            performSegueWithIdentifier("toAddReview", sender: self)
        }
    }
    
    @IBAction func inviteButtonPressed (){
        if userLogged == nil {
            let alert = UIAlertController(title: "Error", message: "you must be logged in", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel , handler: nil))
            alert.addAction(UIAlertAction(title: "Login", style: UIAlertActionStyle.Default, handler: { action in
                let storyboard = UIStoryboard(name: "Account", bundle: nil )
                let vc = storyboard.instantiateViewControllerWithIdentifier("loginScreen") as! LoginViewController
                self.presentViewController(vc, animated: true, completion: nil)
            }))
            self.presentViewController(alert, animated: true, completion: nil)
        } else {
            performSegueWithIdentifier("toInvite", sender: self)
        }
    }
    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "toAddReview") {
            if let detailVC  = segue.destinationViewController as? AddReviewViewController {
                detailVC.resto = self.resto
                detailVC.userLogged = self.userLogged
            }
        }
        
        if segue.identifier == "toMapDetail" {
            if let detailVC  = segue.destinationViewController as? MapDetailViewController {
                detailVC.resto = self.resto
                detailVC.parent = self
            }
        }

        if segue.identifier == "toInvite" {
            if let detailVC  = segue.destinationViewController as? InviteViewController {
                detailVC.resto = self.resto
                detailVC.userLogged = self.userLogged
            }
        }
    }
    

    
    func initMap(){
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if (locationFixAchieved == false) {
            locationFixAchieved = true
            let locationArray = locations as NSArray
            let locationObj = locationArray.lastObject as! CLLocation
            userLocation = locationObj
            locationManager.stopUpdatingLocation()
            let d = Int(ceil(resto.location.distanceFromLocation(userLocation)))
            
            distanceLabel.text = "\( d ) m "
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        FirebaseHelper.getcurrentLoggedInUser({ (user) in
            self.userLogged = user
        }) {
            
        }
        
        if resto != nil {
            
            titleLabel.text = resto.name
            
            if resto.rating != nil {
                starLabel.text = Utils.ratingToStr(resto.rating!)
            }
            
            if resto.description != nil {
                descriptionLabel.text = resto.description
            }
            
            if resto.address != nil {
                addressLabel.text = resto.address!
            }
            
            if resto.image != nil {
                myImage.image = resto.image
            }
            
            if resto.price != nil {
                prixLabel.text = "€".repeat_nb(resto.price!.rawValue)
            }
            
        }
        self.tableViewReviews.reloadData()
        initMap()
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

extension RestoDetailViewController : UITableViewDelegate, UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // A modifier, retourner le nombre de ligne dans la section
        return resto.reviews.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("ReviewCell", forIndexPath: indexPath) as! ReviewCell
        // Ajouter la logique d'affichage du texte dans la cellule de la TableView
        // la variable indexpath.row indique la ligne selectionnée
        // on accède aux IBOutlet de la cellule avec par exemple : cell.name =
        let review = resto.reviews[indexPath.row]
        cell.userLabel.text = review.reviewerName! 
        cell.messageLabel.text = review.comment!
        cell.dateLabel.text = " le " + Utils.dateToString(review.date)
        

        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let selectedRow = indexPath.row
        //faire quelque chose avec selectedRow
        
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
 
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        // more
        
        // delete. Noter le .Desctructive dans le style qui donne automatiquement la couleur rouge
        let delete = UITableViewRowAction(style: UITableViewRowActionStyle.Destructive, title: "Delete") { action, index in
            print("Delete button tapped")
        
        }
        
    
        return [delete]
    }
    
    
}


