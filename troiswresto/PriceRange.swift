//
//  PriceRange.swift
//  troiswresto
//
//  Created by etudiant-02 on 06/07/2016.
//  Copyright © 2016 etudiant-02. All rights reserved.
//

import Foundation


enum PriceRange : Int {
    case PasCher = 0
    case Moyen = 1
    case Cher = 2
}



/*
 
 
 
 // Enum avec variables calculées
 
 enum PriceRange : Int {
 case PasCher = 0
 case Normal = 1
 case Cher = 2
 
 var stringDisplay: String {
 switch self {
 case .PasCher:
 return "€"
 case .Normal:
 return "€€"
 case .Cher:
 return "€€€"
 }
 }
 }
 
 var myString = ""
 
 //ecriture dans Firebase
 let myPriceRange = PriceRange.Cher
 
 myPriceRange.rawValue
 
 if myPriceRange == .Cher {
 
 }
 
 // lire dans firebase
 let myOtherPriceRange = PriceRange(rawValue: 2)
 
 myOtherPriceRange
 print(myOtherPriceRange!)
 
 myPriceRange.stringDisplay
 
 
 */
