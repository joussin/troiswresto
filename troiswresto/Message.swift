//
//  Message.swift
//  troiswresto
//
//  Created by etudiant-02 on 21/07/2016.
//  Copyright © 2016 etudiant-02. All rights reserved.
//

import Foundation


class Message {
    var message: String
    var user: String
    var date : NSDate
    
    init(user: String, message: String, date: NSDate){
        self.user = user
        self.message = message
        self.date = date
    }
}