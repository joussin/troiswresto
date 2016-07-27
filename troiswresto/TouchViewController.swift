//
//  TouchViewController.swift
//  troiswresto
//
//  Created by etudiant-02 on 22/07/2016.
//  Copyright © 2016 etudiant-02. All rights reserved.
//

import UIKit

class TouchViewController: UIViewController {
    
    
    var colors = [UIColor.redColor(),UIColor.blueColor(),UIColor.greenColor(),UIColor.darkGrayColor()]
    
    
    var r = M_PI
    
    
    var transforms = CGAffineTransformIdentity
    
    @IBOutlet var rectangle : UIView!
    
    
    @IBAction func simpleTouchSent () {
        
        
    }
    @IBAction func longTouchSent () {
        
        let color = colors[rand(0,upper: colors.count-1)]
        rectangle.backgroundColor = color
    }
    
    
    
    @IBAction func pinchSent(recognizer:UIPinchGestureRecognizer) {
        
        let scale = recognizer.scale
        self.transforms = CGAffineTransformMakeScale(scale, scale)
        
        update()
    }
    
    @IBAction func rotationSent (recognizer: UIRotationGestureRecognizer) {
        let rotation  = recognizer.rotation
        self.transforms = CGAffineTransformMakeRotation(rotation)
        update()
    }
    
    @IBAction func swipeSent() {
        print("swipe")
        
      
        
        UIView.animateWithDuration(1.0,
                                   delay: 0.0,
                                   options: .CurveEaseInOut ,
                                   animations: {
                                    
                                        self.rectangle.transform = CGAffineTransformMakeRotation(CGFloat(self.r))
                                   

            },
                                   completion: { finished in
                                    self.r +=  M_PI
                                    
        })
    }
    
    
    func update () {
        self.rectangle.transform = transforms
    }
    
    func rand (lower: Int,upper: Int ) -> Int {
        let upper_ = UInt32(upper)
        let lower_ = UInt32(lower)
        let randomNumber = arc4random_uniform(upper_ - lower_) + lower_
        return Int(randomNumber)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
}
