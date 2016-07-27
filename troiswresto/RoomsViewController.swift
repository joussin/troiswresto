//
//  RoomsViewController.swift
//  troiswresto
//
//  Created by etudiant-02 on 22/07/2016.
//  Copyright © 2016 etudiant-02. All rights reserved.
//

import UIKit

class RoomsViewController: UIViewController {

    @IBOutlet var collectionView : UICollectionView!
    
    var rooms = [[String: AnyObject]]()
    
     var userLogged : User?
    
    override func viewWillAppear(animated: Bool) {
        rooms = [[String: AnyObject]]()
        
        
        FirebaseHelper.getcurrentLoggedInUser({ (user) in
            self.userLogged = user
        }) {}
        
    
        FirebaseHelper.loadChatRooms { (chatroomId, resto) in
            let tbl = ["chatroomId": chatroomId, "resto":  resto]
            self.rooms.append(tbl as! [String : AnyObject])
            self.collectionView.reloadData()
        }
    }
    
    @IBAction func swipe(){
        self.dismissViewControllerAnimated(true, completion: nil)

    }
    
    @IBAction func close (){
        self.dismissViewControllerAnimated(true, completion: nil)
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


extension RoomsViewController :  UICollectionViewDelegate, UICollectionViewDataSource {
    
 
    
    //2
      func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.rooms.count
    }
    
    //3
      func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("RoomCell", forIndexPath: indexPath) as! RoomCell
        
        let resto = rooms[indexPath.item]["resto"] as! Resto
        cell.titleLabel.text = rooms[indexPath.item]["chatroomId"] as! String
        cell.restoLabel.text = resto.name  as! String
        cell.resto = resto
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        // handle tap events
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! RoomCell
  
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("chatRoom") as! ChatViewController
        vc.resto = cell.resto
        vc.chatroomKey =  cell.titleLabel.text
        vc.userLogged = self.userLogged
        self.presentViewController(vc, animated: true, completion: nil)

    }
    
    // change background color when user touches cell
    func collectionView(collectionView: UICollectionView, didHighlightItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath)
        cell?.backgroundColor = UIColor.redColor()
    }
    
    // change background color back when user releases touch
    func collectionView(collectionView: UICollectionView, didUnhighlightItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath)
        cell?.backgroundColor = UIColor.yellowColor()
    }
    
    
    
}




