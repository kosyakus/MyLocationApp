//
//  MapViewController.swift
//  MyLocations
//
//  Created by Admin on 09.09.17.
//  Copyright © 2017 NS. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreData


class MapViewController: UIViewController {
    
    
    @IBOutlet weak var mapView: MKMapView!
    var managedObjectContext: NSManagedObjectContext!
    
    
    @IBAction func showUser() {
        let region = MKCoordinateRegionMakeWithDistance(mapView.userLocation.coordinate, 1000, 1000)
        mapView.setRegion(mapView.regionThatFits(region), animated: true)
    }
    
    
    @IBAction func showLocations() {
    }
    
    
}



extension MapViewController: MKMapViewDelegate {
}
