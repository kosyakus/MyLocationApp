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
    
    var locations = [Location]() // var to fetch the saved in CD locations and show on the screen
    
    @IBOutlet weak var mapView: MKMapView!
    var managedObjectContext: NSManagedObjectContext!
    
    
    @IBAction func showUser() {
        let region = MKCoordinateRegionMakeWithDistance(mapView.userLocation.coordinate, 1000, 1000)
        mapView.setRegion(mapView.regionThatFits(region), animated: true)
    }
    
    
    @IBAction func showLocations() {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateLocations() //This fetches the Location objects and shows them on the map when the view loads
    }
    
    
//will be executed every time there is a change in the data store
    func updateLocations() { // fetching the request
        mapView.removeAnnotations(locations) //the locations array may already exist and may contain Location objects. If so, first remove the pins for these old objects
        let entity = Location.entity()
        
        let fetchRequest = NSFetchRequest<Location>()
        fetchRequest.entity = entity
        
        locations = try! managedObjectContext.fetch(fetchRequest)
        mapView.addAnnotations(locations) //add a pin for each location on the map
    }
    
    
}



extension MapViewController: MKMapViewDelegate {
}
