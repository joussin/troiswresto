//
//  Resto.swift
//  troiswresto
//
//  Created by etudiant-02 on 01/07/2016.
//  Copyright © 2016 etudiant-02. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

class Resto {
    
    let restoId : String
    var name : String
    var address : String?
    var location : CLLocation
    var description : String?
    var price: PriceRange?
    var validate : Int = 0
    
    var image : UIImage?
    
    var reviews = [Review]()
    
    var rating : Double? {
        var total  = 0.0
        for review in self.reviews {
            total += review.rating
        }
        if total == 0 || self.reviews.count == 0 {
            return 0
        }
        let moyenne = total / Double(reviews.count)
       
        return moyenne
    }
    
    init ( restoId: String, name : String, location : CLLocation ){
        self.restoId = restoId
        self.name = name
        self.location = location
    }
    
    
}

