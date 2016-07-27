//
//  AdvancedTextView.swift
//  troiswresto
//
//  Created by etudiant-02 on 07/07/2016.
//  Copyright © 2016 etudiant-02. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class UIAdvancedTextView : UITextView, UITextViewDelegate {
    

    var alreadyEdited = false
    var placeholder : String?
    
    
    @IBInspectable var borderColor: UIColor = UIColor.blackColor() {
        didSet {
            layer.borderColor = borderColor.CGColor
        }
    }

    @IBInspectable var borderColorHightLighting: UIColor = UIColor.blueColor() {
        didSet {
            
        }
    }


    @IBInspectable var borderWidth : CGFloat = 1{
        didSet {
            layer.borderWidth = borderWidth
        }
    }

    @IBInspectable var cornerRadius : CGFloat = 5 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
            super.init(frame: frame, textContainer: textContainer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.delegate = self
        self.layer.borderWidth = borderWidth
        self.layer.borderColor = borderColor.CGColor
        self.layer.cornerRadius = cornerRadius
    }
    
    func setBorder(width : CGFloat, color: UIColor, radius: CGFloat ){
        borderColor = color
        borderWidth = width
        cornerRadius = radius
        self.layer.borderWidth = borderWidth
        self.layer.borderColor = borderColor.CGColor
        self.layer.cornerRadius = cornerRadius
    }
    
    
    func textViewDidChange(textView: UITextView) {
        alreadyEdited = true
    }
 
    func textViewDidBeginEditing(textView: UITextView) {
       if !alreadyEdited { self.text = "" }
        self.layer.borderColor = borderColorHightLighting.CGColor
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if !alreadyEdited && placeholder != nil {
            self.text = placeholder!
        }
        self.layer.borderColor = borderColor.CGColor
    }
}



