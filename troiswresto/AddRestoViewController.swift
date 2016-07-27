//
//  AddRestoViewController.swift
//  troiswresto
//
//  Created by etudiant-02 on 06/07/2016.
//  Copyright © 2016 etudiant-02. All rights reserved.
//

import UIKit
import CoreLocation
import MobileCoreServices


class AddRestoViewController: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var referenceImage : UIImage!
    var referenceUrl : NSURL!
    var location: CLLocation!
    var address : String!
    var price : PriceRange! = .Moyen
    
    @IBOutlet var imageView : UIImageView!
    @IBOutlet var nameTextField : UITextField!
    @IBOutlet var addressLabel : UILabel!
    @IBOutlet var descriptionTextView : UIAdvancedTextView!
    @IBOutlet var priceSlider : UISlider!
    @IBOutlet var infoPriceLabel : UILabel!
    @IBOutlet var addButton: UIButton!
    

    
    @IBAction func nameTextFeldDidBeginEditing(sender : UITextField) {
        sender.text = ""
        sender.layer.borderColor = UIColor.blueColor().CGColor
    }
    @IBAction func nameTextFeldDidEndEditing(sender : UITextField) {
        sender.layer.borderColor = UIColor.lightGrayColor().CGColor
    }
    
    @IBAction func addPhoto(sender : AnyObject ){
        let alertController = UIAlertController(title: "Ajout de resto", message: "d'où ajouter une image ?", preferredStyle: .ActionSheet)
        
        let cameraAction = UIAlertAction(title: "appareil photo", style: .Default, handler: { (alert: UIAlertAction!) in
            self.useCamera()
        })
        alertController.addAction(cameraAction)
        let cameraRollAction = UIAlertAction(title: "bibliothèque", style: .Default, handler:  { (alert: UIAlertAction!) in
            self.useCameraRoll()
        })
        alertController.addAction(cameraRollAction)
        
        let cancelAction = UIAlertAction(title: "cancel", style: .Cancel , handler: nil)
        alertController.addAction(cancelAction)
        
        if isIpad() {
            if let popoverController = alertController.popoverPresentationController {
                popoverController.sourceView = imageView
                popoverController.sourceRect = imageView.bounds
            }
        }
        presentViewController(alertController, animated: true, completion: nil)
    }
  
    
    @IBAction func sliderChanged(sender : UISlider) {
        
        let v = ceil(sender.value)
        sender.setValue(v, animated: true)
        
        switch sender.value {
        case 0:
            price = .PasCher
            infoPriceLabel.text = "pas cher"
        case 1:
            price = .Moyen
            infoPriceLabel.text = "prix moyen"
        case 2:
            price = .Cher
            infoPriceLabel.text = "prix cher"
        default:
            break
        }
    }
    
    @IBAction func addButtonPressed () {
        
        if nameTextField.text != "" && descriptionTextView.text != "" {
            
            let resto = Resto(restoId: "restoId", name: nameTextField.text!, location: location)
            resto.address = address
            resto.description = descriptionTextView.text
            resto.price = price
            
            FirebaseHelper.sendResto(resto){ (error,ref,key) in
                if self.referenceUrl != nil {
                   // FirebaseHelper.sendImageToStorage(self.referenceUrl , restoId: key )
                }
                if self.referenceImage != nil {
                    FirebaseHelper.sendImageToStorage2(self.referenceImage , restoId: key )

                }
                
                self.performSegueWithIdentifier("backToRestos", sender: self)
            }
        }
        else {
            //erreur de formulaire
            let alert = UIAlertController(title: "Error", message: "Veuillez remplir le nom et la description du restaurant", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func viewTapped(){
        nameTextField.resignFirstResponder()
        descriptionTextView.resignFirstResponder()
    }
    
    override func viewWillAppear(animated: Bool) {
       
     }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        descriptionTextView.placeholder = "description du restaurant"
        //descriptionTextView.setBorder(2, color: UIColor.lightGrayColor(), radius: 5 )
        
        nameTextField.layer.borderWidth = 2
        nameTextField.layer.borderColor = UIColor.lightGrayColor().CGColor
        nameTextField.layer.cornerRadius = 5
        

        
        if address != nil {
            addressLabel.text = address
        }
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
    
    
    // ajouter UIImagePickerControllerDelegate dans le VC
    // et UINavigationControllerDelegate
    
    let newMedia = false
    
    func useCamera() {// appareil photo
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            
            let imagePicker = UIImagePickerController()
            
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
            imagePicker.mediaTypes = [kUTTypeImage as String]
            imagePicker.allowsEditing = false
            
            self.presentViewController(imagePicker, animated: true,
                                       completion: nil)
            //  newMedia = true
        }
    }
    
    // récupère une image dans le cameraRoll (bibliothèque)
    func useCameraRoll() {
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.SavedPhotosAlbum) {
            let imagePicker = UIImagePickerController()
            
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            imagePicker.mediaTypes = [kUTTypeImage as String]
            imagePicker.allowsEditing = false
            self.presentViewController(imagePicker, animated: true,
                                       completion: nil)
            // newMedia = false
        }
    }
    
    
    // recupère une photo via le pickerController
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let mediaType = info[UIImagePickerControllerMediaType] as! String
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
        if mediaType == (kUTTypeImage as String) {
            
            // on récupère ICI l'image
            let image = info[UIImagePickerControllerOriginalImage] as! UIImage
            referenceUrl = info[UIImagePickerControllerReferenceURL] as! NSURL
            
            let resizefactor = Int(image.size.width / 200)
            referenceImage = Utils.reduceImage(image, factor: resizefactor)
            
            imageView.image = referenceImage
            
            
            /*
             if (newMedia == true) {
             UIImageWriteToSavedPhotosAlbum(image, self,
             "image:didFinishSavingWithError:contextInfo:", nil)
             } else if mediaType == (kUTTypeMovie as String) {
             // Code to support video here
             }
             */
            
        }
    }
    
    
    
    func isIpad()->Bool {
        return UIDevice.currentDevice().userInterfaceIdiom == .Pad
    }
    
    
    
    
}
