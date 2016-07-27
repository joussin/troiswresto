//
//  MapViewController.swift
//  troiswresto
//
//  Created by etudiant-02 on 06/07/2016.
//  Copyright © 2016 etudiant-02. All rights reserved.
//

import UIKit
import MapKit


class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    var locationFixAchieved: Bool!
    var locationManager: CLLocationManager!
    var firstPlacement = true
    var userLocation : CLLocation!
    var restoSelected : Resto!
    
    @IBOutlet var mapView : MKMapView!
    @IBOutlet var addressLabel : UILabel!
    var currentLocation : CLLocation!
    
    var restos = [Resto]()
    
    @IBAction func centerToUserLocation(){
        if userLocation != nil {
            let coordinateRegion = MKCoordinateRegionMakeWithDistance(userLocation.coordinate,450 * 2.0, 450 * 2.0)
            mapView.setRegion(coordinateRegion, animated: true)
        }
    }
    
    
    func addPins(){
         let mapCenterPosition = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
        mapView.removeAnnotations(mapView.annotations)
        for resto in restos {
            if resto.location.distanceFromLocation(mapCenterPosition) < 500 {
                var annotation: Pin
                annotation = Pin(title: resto.name, resto: resto)
                mapView.addAnnotation(annotation)
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        locationFixAchieved = false
        initMap()
        centerToUserLocation()
        addPins()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initMap(){
        mapView.showsUserLocation = true
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if (locationFixAchieved == false) {
            //locationFixAchieved = true
            var locationArray = locations as NSArray
            var locationObj = locationArray.lastObject as! CLLocation
            userLocation = locationObj
            //locationManager.stopUpdatingLocation()
            if firstPlacement {
                firstPlacement = false
                centerToUserLocation()
            }
        }
    }
    
    
    
    
    
    func updateAddressLabel() {
        let centerCoordinates = mapView.centerCoordinate
        let location = CLLocation(latitude: centerCoordinates.latitude, longitude: centerCoordinates.longitude)
        Utils.getAdressFromLocation (location) { output in
            if output != "" {
                self.currentLocation = location
                self.addressLabel.text = String(output)
            }
        }
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String,sender: AnyObject?) -> Bool {
        if currentLocation != nil {
            return true
        } else {
            return false
        }
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "toAddResto" ) {
            if let detailVC  = segue.destinationViewController as? AddRestoViewController {
                if self.addressLabel.text != "" {
                    detailVC.address = self.addressLabel.text
                    detailVC.location = self.currentLocation
                }
            }
        }
    }

}


extension MapViewController {
    
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
                view.image = UIImage(named: "resto_pin")
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
            }
            return view
        }
        return nil
    }
    

    
    
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        updateAddressLabel()
        addPins()
    }
    
}


