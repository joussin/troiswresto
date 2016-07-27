//
//  MapDetailViewController.swift
//  troiswresto
//
//  Created by etudiant-02 on 12/07/2016.
//  Copyright © 2016 etudiant-02. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit


class MapDetailViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    
    
    
    var parent: RestoDetailViewController!
    
    var resto : Resto!
    var restos = [Resto]()
    
    var locationFixAchieved = false
    var userLocation : CLLocation!
    var locationManager : CLLocationManager!
    
    @IBOutlet var mapView: MKMapView!
    
    
    @IBAction func centerToUserLocation(){
        if userLocation != nil {
            let coordinateRegion = MKCoordinateRegionMakeWithDistance(userLocation.coordinate,450 * 2.0, 450 * 2.0)
            mapView.setRegion(coordinateRegion, animated: true)
        }
    }
    
    func loadData () {
    
        FirebaseHelper.getAllRestos({ restos in
            self.restos = restos

            },completionWithImage: { index in
                if index == self.restos.count {
                    self.addPins()
                }
        })
        
    }
    
    func addPins(){
       // let mapCenterPosition = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
        mapView.removeAnnotations(mapView.annotations)
        for resto in restos {
            //if resto.location.distanceFromLocation(mapCenterPosition) < 2500 {
                var annotation: Pin
                annotation = Pin(title: resto.name, resto: resto)
                mapView.addAnnotation(annotation)
            //}
        }
    }
    
    
    func initMap(){
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if (locationFixAchieved == false) {
            locationFixAchieved = true
            let locationArray = locations as NSArray
            let locationObj = locationArray.lastObject as! CLLocation
            userLocation = locationObj
            locationManager.stopUpdatingLocation()
             centerToUserLocation()
            
        }
    }
    

    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        mapView.showsUserLocation = true
        
        if resto != nil {
            navigationItem.title = resto.name
        } else {
            navigationItem.title = "All restos"
        }
        initMap()
        loadData()

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



extension MapDetailViewController {

    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? Pin {
            let identifier = "pin"
            var view: MKAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
                as? MKPinAnnotationView { // 2
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                view = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: 0, y: -5)//position du popup par rapport à l'image
                
                //pour bien placer le pin
                view.centerOffset = CGPoint(x: 0, y: -22)
                
                
                if resto != nil && annotation.resto.restoId == resto.restoId {
                    view.image = UIImage(named: "resto_selected_pin")
                } else {
                    view.image = UIImage(named: "resto_pin")
                }
                
                view.frame.size = CGSize(width: 45, height: 60)
                
                var label = UILabel(frame: CGRect(origin: CGPoint(x: 11,y:-7), size: CGSize(width: 50, height: 50 )))
                label.text = "\( ceil(annotation.resto.rating!*10)/10 )"
                label.font = UIFont(name: "Arial", size: 12)
                
                view.addSubview(label)
                
                if annotation.resto.image != nil {
                    let imageView = UIImageView(image: annotation.resto.image)
                    imageView.frame.size = CGSize(width: 50, height: 50)
                    view.leftCalloutAccessoryView = imageView
                }
                
                // btn star
                let rightButton = UIButton()
                rightButton.frame = CGRectMake(0, 0, 30, 30)
                rightButton.titleLabel?.font = UIFont(name: "FontAwesome", size: 20)
                rightButton.setTitleColor( UIColor.blackColor(), forState: .Normal)
                rightButton.setTitle("\u{f06e}", forState: .Normal)
                
             
                view.rightCalloutAccessoryView = rightButton

                
                
            }
            return view
        }
        return nil
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView,calloutAccessoryControlTapped control: UIControl) {
        let pin = view.annotation as! Pin
        let rightButton = view.rightCalloutAccessoryView as! UIButton

        parent.resto = pin.resto
        self.navigationController?.popViewControllerAnimated(true)
    }

    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {

       // addPins()
    }
    
}


