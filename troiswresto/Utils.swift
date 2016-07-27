//
//  Utils.swift
//  troiswresto
//
//  Created by etudiant-02 on 01/07/2016.
//  Copyright © 2016 etudiant-02. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

class Utils {
    
    static func emailToNickName(email: String) -> String{
 
        let fullNameArr = email.characters.split{$0 == "@"}.map(String.init)
        // or simply:
        // let fullNameArr = fullName.characters.split{" "}.map(String.init)
        
         return  fullNameArr[0] // First
       
    }
    
    
    static func isValidEmail(testStr:String) -> Bool {
        // print("validate calendar: \(testStr)")
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(testStr)
    }
    /**
     convert a double rating in an unicode string with STAR FONT AWESOME
     
     */
    static func ratingToStr(rating: Double) -> String {
        var strStar = ""
        
        if rating == 0 {
            return "\u{f006}\u{f006}\u{f006}\u{f006}\u{f006}"
        }
        
        for _ in 1...Int(rating) {
            strStar += "\u{f005}"
        }
        
        if Int(rating) < 5 {
            for _ in 1...(5 - Int(rating) ) {
                strStar += "\u{f006}"
            }
        }
        return strStar
    }
    
    /**
     
     dateString : 2014-01-12
     */
    static func stringToDate(dateString: String) -> NSDate? {
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd H:m"
        let s = dateFormatter.dateFromString(dateString)
        return s
    }
    
    static func dateToString (date : NSDate) -> String {
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd H:m"
        var dateString = dateFormatter.stringFromDate(date)
        return dateString
    }
    
    // Fonction utilitaire
    static func getAdressFromLocation (location : CLLocation, completion:(String)->Void ) {
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
            var output = ""
            if (error != nil) {
                print("Reverse geocoder failed with error" + error!.localizedDescription)
                output = "error"
            }
            
            if placemarks != nil {
                if placemarks!.count > 0 {
                    let pm = placemarks![0] as CLPlacemark
                    if pm.thoroughfare != nil && pm.subThoroughfare != nil {
                        output =  pm.subThoroughfare! + " " + pm.thoroughfare!
                    } else {
                        output = ""
                    }
                } else {
                    output = "Problem with the data received from geocoder"
                }
            } else {
                output = "Problem with the data received from geocoder"
            }
            completion(output)
        })
    }

    //resizing image
    /*
     let resizefactor = Int(image.size.width / 200)
     let resizedImage = reduceImage(image, factor: resizefactor)
     */
    static func reduceImage(image : UIImage, factor : Int)-> UIImage {
        print("original image size=\(image.size)")
        let size = CGSizeApplyAffineTransform(image.size, CGAffineTransformMakeScale(1 / CGFloat(factor), 1 / CGFloat(factor)))
        let hasAlpha = false
        let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
        
        UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale)
        image.drawInRect(CGRect(origin: CGPointZero, size: size))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        print("scaled image size=\(scaledImage.size)")
        return scaledImage
    }
    
}



extension UIColor {
    convenience init(hexa numberHexa: String, alpha: CGFloat) {
        func toFloat( numberHexa: String) -> CGFloat {
            return CGFloat(strtoul(numberHexa, nil, 16))
        }
        
        if numberHexa.characters.count == 7 {
            let red = toFloat(numberHexa.substringWithRange(
                numberHexa.startIndex.advancedBy(1)..<numberHexa.startIndex.advancedBy(3)))
            
            let green = toFloat(numberHexa.substringWithRange(
                numberHexa.startIndex.advancedBy(3)..<numberHexa.startIndex.advancedBy(5)))
            
            let blue = toFloat(numberHexa.substringWithRange(
                numberHexa.startIndex.advancedBy(5)..<numberHexa.startIndex.advancedBy(7)))
            
            self.init(red: red / 255, green: green / 255, blue: blue / 255, alpha: alpha)
            
        } else {
            self.init(red: 0, green: 0, blue: 0, alpha: alpha)
        }
    }
}


extension String {
    
    func repeat_nb(nb: Int) -> String {
        var str_temp = ""
        
        for _ in 0...nb {
            str_temp += self
        }
        return str_temp
    }
    
}



extension UITableView {
    func scrollToBottom(animated: Bool = true) {
        
        let sections = self.numberOfSections
        let rows = self.numberOfRowsInSection(sections - 1)
        
        if rows > 0 {
            
            self.scrollToRowAtIndexPath(NSIndexPath(forRow: rows - 1, inSection: sections - 1), atScrollPosition: .Bottom, animated: false)
        }
    }
}

