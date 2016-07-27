//
//  Review.swift
//  troiswresto
//
//  Created by etudiant-02 on 01/07/2016.
//  Copyright © 2016 etudiant-02. All rights reserved.
//

import Foundation




class Review {
    
    var reviewerName : String?
    var reviewerId : String
    var rating : Double
    var comment : String?
    var date: NSDate
    var validate : Int = 0
    
    init (reviewerId: String, rating: Double, date: NSDate) {
        
        self.reviewerId = reviewerId
        self.rating = rating
        self.date = date
        
    }
    
    
    
    
}