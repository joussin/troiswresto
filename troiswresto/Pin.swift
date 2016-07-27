//
//  Pin.swift
//  MyVelib
//
//  Created by etudiant-02 on 17/06/2016.
//  Copyright © 2016 etudiant-02. All rights reserved.
//

import Foundation
import MapKit


class Pin: NSObject, MKAnnotation {
    var title: String?
    var resto : Resto
    var image : UIImage?
 
    
    init(title: String,resto: Resto){
        self.title = title
        self.resto = resto

        super.init()
    }
    
    var coordinate : CLLocationCoordinate2D {
        return self.resto.location.coordinate
    }
    
    //nécessaire si on ne veut pas de subtitle
    var subtitle: String? {
        return ""
    }
}
