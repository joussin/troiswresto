//
//  User.swift
//  troiswresto
//
//  Created by etudiant-02 on 13/07/2016.
//  Copyright © 2016 etudiant-02. All rights reserved.
//

import Foundation


class User {
    
    var email: String
    var nickName: String
    var id : String
    
    init(email: String, nickName: String, id: String){
        self.email = email
        self.nickName = nickName
        self.id = id
    }
    
}