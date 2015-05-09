//
//  ViewController.swift
//  Project19
//
//  Created by Vinny DeGenova on 5/9/15.
//  Copyright (c) 2015 Vinny DeGenova. All rights reserved.
//

import MapKit
import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let london = Capital(title: "London", coordinate: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275), info: "Home to the 2012 Summer Olympics.")
        let oslo = Capital(title: "Oslo", coordinate: CLLocationCoordinate2D(latitude: 59.95, longitude: 10.75), info: "Founded over a thousand years ago.")
        let paris = Capital(title: "Paris", coordinate: CLLocationCoordinate2D(latitude: 48.8567, longitude: 2.3508), info: "Often called the City of Light.")
        let rome = Capital(title: "Rome", coordinate: CLLocationCoordinate2D(latitude: 41.9, longitude: 12.5), info: "Has a whole country inside it.")
        let washington = Capital(title: "Washington DC", coordinate: CLLocationCoordinate2D(latitude: 38.895111, longitude: -77.036667), info: "Named after George himself.")
        
        mapView.addAnnotations([london, oslo, paris, rome, washington])
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Action, target: self, action: "mapType")
    }
    
    func mapType() {
        let ac = UIAlertController(title: "Select Map Type", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        ac.addAction(UIAlertAction(title: "Satellite", style: UIAlertActionStyle.Default, handler: setMapType))
        ac.addAction(UIAlertAction(title: "Hybrid", style: UIAlertActionStyle.Default, handler: setMapType))
        ac.addAction(UIAlertAction(title: "Map", style: UIAlertActionStyle.Default, handler: setMapType))
        presentViewController(ac, animated: true, completion: nil)
        
    }
    
    func setMapType(action: UIAlertAction!) {
        let title = action.title
        
        if title == "Hybrid" {
            mapView.mapType = MKMapType.Hybrid
        }
        else if title == "Satellite" {
            mapView.mapType = MKMapType.Satellite
        }
        else if title == "Map" {
            mapView.mapType = MKMapType.Standard
        }

    }
    
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        
        let identifier = "Capital"
        
        if annotation.isKindOfClass(Capital.self) {
            var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
            
            if annotationView == nil {
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView.canShowCallout = true
                
                let btn = UIButton.buttonWithType(UIButtonType.DetailDisclosure) as! UIButton
                annotationView.rightCalloutAccessoryView = btn
                
            } else {
                annotationView.annotation = annotation
            }
            
            return annotationView
        }
        
        return nil
    }
    
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
        let capital = view.annotation as! Capital
        let placeName = capital.title
        let placeInfo = capital.info
        
        let ac = UIAlertController(title: placeName, message: placeInfo, preferredStyle: UIAlertControllerStyle.Alert)
        ac.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        presentViewController(ac, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

