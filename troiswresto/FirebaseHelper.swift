//
//  FirebaseHelper.swift
//  troiswresto
//
//  Created by etudiant-02 on 04/07/2016.
//  Copyright © 2016 etudiant-02. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase
import CoreLocation
import FirebaseStorage
import Photos
import FirebaseAuth
import FBSDKLoginKit
import GoogleSignIn

class FirebaseHelper {
    
    static var ref =  FIRDatabase.database().reference()
    static var storageRef = FIRStorage.storage().reference()
    
    
    
    
    
    
    
    
    
    
    //  AUTH
    
    
    static func logout() {
        try! FIRAuth.auth()!.signOut()
        
        let loginManager = FBSDKLoginManager()
        loginManager.logOut()
        
        GIDSignIn.sharedInstance().disconnect()
        
    }
    
    static func getcurrentLoggedInUser (userLoggedIn: (user: User) -> (), userNotLoggedIn: () -> () ) {
        
        FIRAuth.auth()?.addAuthStateDidChangeListener { auth, user in
            
            if let user = user {
                getUserInfo(user.uid, completion: { (user) in
                    userLoggedIn(user: user)
                })
            } else {
                // No user is signed in.
                userNotLoggedIn()
            }
        }
    }
    
    static func addUser(email: String, password: String, completion: (user: FIRUser? , error: NSError? ) -> () ) {
        FIRAuth.auth()?.createUserWithEmail(email, password: password) { (user, error) in
            completion(user: user, error: error)
        }
    }
    
    static func addUserToDatabase(user: User, completion: (error: NSError? ) -> () ){
        let userRef = ref.child("data/user/\(user.id)")
        
        let user : [String : AnyObject] = [
            "email": user.email,
            "nickname": user.nickName,
            ]
        userRef.updateChildValues(user, withCompletionBlock: { (error, ref) in
            completion(error: error)
        })
    }
    
    static func login( email: String, password: String, completion: (user: FIRUser? , error: NSError? ) -> () ) {
        FIRAuth.auth()?.signInWithEmail(email, password: password) { (user, error) in
            completion(user: user, error: error)
        }
    }
    
    static func getUserInfo(key: String, completion: (user: User) -> () ) {
        ref.child("data/user/" + key ).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            let email = snapshot.value!["email"] as? String
            let nickname = snapshot.value!["nickname"] as? String
            
            if email != nil && nickname != nil {
                let user = User(email: email!, nickName: nickname!,id: key)
                completion(user: user)
            }
        })
    }
    
    
    // IMAGE STORAGE
    
    static func sendImageToStorage(imageUrl: NSURL, restoId : String) {
        let assets = PHAsset.fetchAssetsWithALAssetURLs([imageUrl], options: nil)
        let asset = assets.firstObject
        
        asset?.requestContentEditingInputWithOptions(nil, completionHandler: { (contentEditingInput,info) in
            let imageFile = contentEditingInput?.fullSizeImageURL
            let filePath = "images/\(restoId)/main.jpg"
            
            self.storageRef.child(filePath)
                .putFile(imageFile!, metadata: nil) { (metadata, error) in
                    if let error = error {
                        print("Error uploading: \(error)")
                        return
                    }
            }
        })
    }
    
    static func sendImageToStorage2(image: UIImage, restoId: String){
        let data: NSData = UIImagePNGRepresentation(image)!
        let imageRef = storageRef.child("images/\(restoId)/main.jpg")
        // Upload the file to the path "images/rivers.jpg"
        let uploadTask = imageRef.putData(data, metadata: nil) { metadata, error in
            if (error != nil) {
                // Uh-oh, an error occurred!
                print("Error uploading: \(error)")
            } else {
                // Metadata contains file metadata such as size, content-type, and download URL.
                let downloadURL = metadata!.downloadURL
            }
        }
    }
    
    static func getImageFromStorage (restoId : String, resto : Resto , completion : (image : UIImage, resto : Resto) -> () ){
        let storagePath = "images/\(restoId)/main.jpg"
        
        storageRef.child(storagePath).dataWithMaxSize(10 * 1024 * 1024) { (data, error) -> Void in
            if (error != nil) {
                completion(image: UIImage(named: "menu-placeholder")!, resto : resto)
            } else {
                if let image = UIImage(data: data!) {
                    completion(image: image, resto : resto)
                }
            }
        }
    }
    
    
    
    /// CHAT
    static func createChatRoom( resto: Resto, completion : (error : NSError!, chatroomKey: String) -> () ) {
        
        let chatroomRef = ref.child("data/chatroom/").childByAutoId()
        let chatroom : [String : AnyObject] = [
            "restoid": resto.restoId
        ]
        
        chatroomRef.updateChildValues(chatroom, withCompletionBlock: { (error, ref) in
            completion(error: error, chatroomKey: chatroomRef.key )
        })
    }
    
    
    static func sendMessage( message: Message, chatroomKey: String, completion : (error : NSError! ) -> () ) {
        
        let messageRef = ref.child("data/message/\(chatroomKey)/").childByAutoId()
        let chatroom : [String : AnyObject] = [
            "user": message.user,
            "message": message.message,
            "date": Utils.dateToString(message.date)
        ]
        
        messageRef.updateChildValues(chatroom, withCompletionBlock: { (error, ref) in
            completion(error: error)
        })
        
    }
    
    
    static func loadMessages(chatroomKey: String, completion : (message: Message ) -> () ){
        
        ref.child("data/message/\(chatroomKey)/").observeEventType(FIRDataEventType.ChildAdded, withBlock: { (snapshot) in
            let date = snapshot.value!["date"] as? String
            let message = snapshot.value!["message"] as? String
            let user = snapshot.value!["user"] as? String
            
            if date != nil && user != nil && date != nil {
                let msg = Message(user: user!, message: message!, date: Utils.stringToDate(date!)! )
                completion(message: msg)
            }
        })
    }
    
    
    
    static func loadChatRooms( completion : (chatroomId: String , resto: Resto ) -> () ){
        
        ref.child("data/chatroom/").observeEventType(FIRDataEventType.ChildAdded, withBlock: { (snapshot) in
            let chatroomId = snapshot.key as? String
            let restoId =  snapshot.value!["restoid"] as? String
            
            if chatroomId != nil && restoId != nil {
                
                ref.child("data/resto/" + restoId! + "/" ).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                    let name =  snapshot.value!["name"] as? String
                    
                    let position = snapshot.value!["location"] as? [String: Double]
                    
                    if name != nil && position != nil  {
                        
                        let lat = position!["lat"]
                        let long = position!["long"]
                        
                        let lat_ = ( lat != nil ) ? lat! : 0
                        let long_ = ( long != nil ) ? long! : 0
                        
                        let r = Resto(restoId:  snapshot.key, name: name!, location: CLLocation(latitude: lat_, longitude: long_ ) )
                     completion(chatroomId: chatroomId!,resto:r)
                    }
                    
                    
               })
            }
            
        })
    }
    
    
    
    
    // DATABASE
    
    
    /**
     
     get all restos from firebase
     
     */
    
    
    
    
    static func  getAllRestos ( completion: (restos : [Resto]) -> () , completionWithImage : (index: Int) -> () ) {
        
        ref.child("data/resto").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            
            var index = 0
            
            var restos = [Resto]()
            
            for subSnapshot in snapshot.children.allObjects as! [FIRDataSnapshot] {
                
                var reviewsArray = [Review]()
                let reviews = subSnapshot.childSnapshotForPath("reviews")
                
                for subReview in reviews.children.allObjects as! [FIRDataSnapshot]  {
                    
                    let date = subReview.value!["date"] as? String
                    let message = subReview.value!["message"] as? String
                    let rating = subReview.value!["rating"] as? Double
                    let reviewerId = subReview.value!["reviewerId"] as? String
                    let reviewerName = subReview.value!["reviewerName"] as? String
                    let validate = subReview.value!["validate"] as? Int
                    
                    if date != nil && reviewerId != nil && rating != nil  && validate != nil {
                        
                        if validate == 1 {
                            let review = Review(reviewerId: reviewerId!, rating: rating!, date: Utils.stringToDate(date!)! )
                            if message != nil {
                                review.comment = message
                            }
                            if reviewerName != nil {
                                review.reviewerName = reviewerName
                            }
                            
                            reviewsArray.insert(review, atIndex: 0)
                        }
                    }
                }
                
                let name = subSnapshot.value!["name"] as? String
                let position = subSnapshot.value!["location"] as? [String: Double]
                
                if name != nil && position != nil  {
                    
                    let lat = position!["lat"]
                    let long = position!["long"]
                    
                    let lat_ = ( lat != nil ) ? lat! : 0
                    let long_ = ( long != nil ) ? long! : 0
                    
                    let r = Resto(restoId:  subSnapshot.key, name: name!, location: CLLocation(latitude: lat_, longitude: long_ ) )
                    
                    if let description = subSnapshot.value!["description"]  as! String? {
                        r.description = description
                    }
                    if let address = subSnapshot.value!["address"]  as! String? {
                        r.address = address
                    }
                    if let image = subSnapshot.value!["image"]  as! String? {
                        r.image = UIImage(named: image)
                    }
                    if let price = subSnapshot.value!["price"]  as! Int? {
                        switch price {
                        case 0:
                            r.price = .PasCher
                        case 1:
                            r.price = .Moyen
                        case 2:
                            r.price = .Cher
                        default:
                            break
                        }
                    }
                    
                    r.reviews = reviewsArray
                    
                    restos.insert(r, atIndex: 0)
                    getImageFromStorage(subSnapshot.key, resto : r, completion: { (image, resto) in
                        resto.image = image
                        index += 1
                        completionWithImage(index: index )
                    })
                }
            }
            completion(restos: restos)
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    
    static func sendReviewForResto( resto: Resto, review : Review, completion : (error : NSError! ) -> () ) {
        
        let reviewRef = ref.child("data/resto/\(resto.restoId)/reviews/").childByAutoId()
        
        let review : [String : AnyObject] = [
            "message": review.comment!,
            "rating": review.rating,
            "date" : Utils.dateToString(review.date),
            "reviewerId" : review.reviewerId,
            "reviewerName": review.reviewerName!,
            "validate": review.validate
        ]
        
        reviewRef.updateChildValues(review, withCompletionBlock: { (error, ref) in
            completion(error: error)
        })
    }
    
    static func sendResto( resto: Resto, completion : (error : NSError! , ref: FIRDatabaseReference, key: String) -> () ) {
        
        let restoRef = ref.child("data/resto/").childByAutoId()
        
        let location : [String : AnyObject] = [
            "lat": resto.location.coordinate.latitude,
            "long": resto.location.coordinate.longitude,
            ]
        let resto : [String : AnyObject] = [
            "description": resto.description!,
            "address": resto.address!,
            "name": resto.name,
            "location": location,
            "price": resto.price!.rawValue,
            "validate": resto.validate
        ]
        
        restoRef.updateChildValues(resto, withCompletionBlock: { (error, ref) in
            completion(error: error, ref: ref, key : restoRef.key)
        })
    }
}