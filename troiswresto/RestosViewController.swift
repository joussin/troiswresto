//
//  RestosViewController.swift
//  troiswresto
//
//  Created by etudiant-02 on 01/07/2016.
//  Copyright © 2016 etudiant-02. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON
import Firebase
import FirebaseDatabase

enum SortType {
    case Distance, Price, Rating
}





class RestosViewController: UIViewController, CLLocationManagerDelegate {
    
    var locationFixAchieved = false
    var userLocation : CLLocation!
    var locationManager : CLLocationManager!
    
    var sortType = SortType.Distance
    
    var userLogged : User?
    var restos = [Resto]()
    var refreshControl : UIRefreshControl!
    
    
   
    @IBOutlet var myTableView : UITableView!
    @IBOutlet var activityIndicator : UIActivityIndicatorView!
    
    
    @IBAction func addRestoButtonPressed (){
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
            performSegueWithIdentifier("toMap", sender: self)
        }
    }
    
    @IBAction func backToMain () {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func backToRestos(segue: UIStoryboardSegue){
        
    }
    
    @IBAction func segmentedControlChanged (sender : UISegmentedControl){
   
        if sender.selectedSegmentIndex == 0 {
            sortType = .Distance
        }
        if sender.selectedSegmentIndex == 1 {
            sortType = .Rating
        }
        if sender.selectedSegmentIndex == 2 {
            sortType = .Price
        }
        loadData()
        
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
            myTableView.reloadData()

        }
    }

    
    func loadData () {
        activityIndicator.hidden = false
        
        FirebaseHelper.getAllRestos({ restos in
            self.restos = restos
            
            switch self.sortType {
            case .Distance:
                if self.userLocation != nil {
                    self.restos = self.restos.sort({ $0.location.distanceFromLocation(self.userLocation) < $1.location.distanceFromLocation(self.userLocation) })
                }
            case .Price:
                self.restos = self.restos.sort({ $0.price!.rawValue < $1.price!.rawValue })

            case .Rating:
                self.restos = self.restos.sort({ $0.rating > $1.rating })

            }
            
            self.myTableView.reloadData()
            self.activityIndicator.hidden = true
            },completionWithImage: { index in
                self.myTableView.reloadData()
        })
    }
    
    override func viewWillAppear(animated: Bool) {
        
        FirebaseHelper.getcurrentLoggedInUser({ (user) in
            self.userLogged = user
            }) { 
                
        }
        
        activityIndicator.hidden = true
        activityIndicator.startAnimating()
        initMap()
        loadData()
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        myTableView.addSubview(refreshControl)
    }
    
    func refresh(sender:AnyObject) {
        // Code to refresh table view
        loadData()
        refreshControl.endRefreshing()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "toRestoDetail") {
            if let detailVC  = segue.destinationViewController as? RestoDetailViewController {
                detailVC.resto = restos[myTableView.indexPathForSelectedRow!.row]
                
            }
        }
        
        if (segue.identifier == "toMap") {
            if let detailVC  = segue.destinationViewController as? MapViewController {
                detailVC.restos = restos
            }
        }
        
         
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




extension RestosViewController : UITableViewDelegate, UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // A modifier, retourner le nombre de ligne dans la section
        return restos.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("RestoCell", forIndexPath: indexPath) as! RestoCell
        
        if indexPath.row <= restos.count {
            
            
            
            cell.titleLabel.text = restos[indexPath.row].name
            
            if restos[indexPath.row].description != nil {
                cell.descriptionLabel.text = restos[indexPath.row].description
            } else {
                cell.descriptionLabel.text = "Pas de description pour le moment"
            }
            
            let rating = restos[indexPath.row].rating
            if rating != nil {
                cell.starLabel.text = Utils.ratingToStr(rating!)
            } else {
                cell.starLabel.text = Utils.ratingToStr(0)
            }

            if restos[indexPath.row].image != nil {
                cell.myImage.image = restos[indexPath.row].image
                cell.indicatorView.stopAnimating()
                cell.indicatorView.hidden = true
            } else {
               cell.indicatorView.startAnimating()
                cell.indicatorView.hidden = false
            }
            
            if restos[indexPath.row].price != nil {
                cell.prixLabel.text = "€".repeat_nb(restos[indexPath.row].price!.rawValue)
            } else {
                cell.prixLabel.text = "nc"
            }
            
            if userLocation != nil {
                 let d = Int(ceil(restos[indexPath.row].location.distanceFromLocation(userLocation)))
                cell.distanceLabel.text = "\( d ) m "
            }
            

            if indexPath.row % 2 == 1 {
                cell.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)
            } else {
                cell.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1.0)
            }
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if restos[indexPath.row].image != nil {
            performSegueWithIdentifier("toRestoDetail", sender: self)
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
            
    }
}




