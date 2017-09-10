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
    var managedObjectContext: NSManagedObjectContext! {
        didSet { //the didSet block tells the NotificationCenter to add an observer for the NSManagedObjectContextObjectsDidChange notification
            NotificationCenter.default.addObserver(forName:
                Notification.Name.NSManagedObjectContextObjectsDidChange,
                                                   object: managedObjectContext,
                                                   queue: OperationQueue.main) { notification in
                                                    if self.isViewLoaded {
                                                        self.updateLocations()
                                                    }
            }
        } //This notification is sent out by the managedObjectContext whenever the data store changes
    }
    
    
    @IBAction func showUser() {
        let region = MKCoordinateRegionMakeWithDistance(mapView.userLocation.coordinate, 1000, 1000)
        mapView.setRegion(mapView.regionThatFits(region), animated: true)
    }
    
    
    @IBAction func showLocations() {
        //This calls region(for) to calculate a reasonable region that fits all the Location objects and then sets that region on the map view
        let theRegion = region(for: locations)
        mapView.setRegion(theRegion, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateLocations() //This fetches the Location objects and shows them on the map when the view loads
        
        if !locations.isEmpty { //show the user’s locations the first time you switch to the Map tab
            showLocations()
        }
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
    
    
//looking at the highest and lowest values for the latitude and longitude of all the Location objects,  calculate a region and then tell the map view to zoom to that region
    func region(for annotations: [MKAnnotation]) -> MKCoordinateRegion {
        let region: MKCoordinateRegion
        
        switch annotations.count {
        case 0: //There are no annotations. Then center the map on the user’s current position
            region = MKCoordinateRegionMakeWithDistance(mapView.userLocation.coordinate, 1000, 1000)
        case 1: //There is only one annotation. Then center the map on that one annotation
            let annotation = annotations[annotations.count - 1]
            region = MKCoordinateRegionMakeWithDistance(annotation.coordinate, 1000, 1000)
        default: //There are two or more annotations
            var topLeftCoord = CLLocationCoordinate2D(latitude: -90, longitude: 180)
            var bottomRightCoord = CLLocationCoordinate2D(latitude: 90, longitude: -180)
            for annotation in annotations {
                topLeftCoord.latitude = max(topLeftCoord.latitude, annotation.coordinate.latitude)
                topLeftCoord.longitude = min(topLeftCoord.longitude, annotation.coordinate.longitude)
                bottomRightCoord.latitude = min(bottomRightCoord.latitude, annotation.coordinate.latitude)
                bottomRightCoord.longitude = max(bottomRightCoord.longitude, annotation.coordinate.longitude)
            }
            let center = CLLocationCoordinate2D(
                latitude: topLeftCoord.latitude -
                    (topLeftCoord.latitude - bottomRightCoord.latitude) / 2,
                longitude: topLeftCoord.longitude -
                    (topLeftCoord.longitude - bottomRightCoord.longitude) / 2)
            let extraSpace = 1.1
            let span = MKCoordinateSpan(
                latitudeDelta: abs(topLeftCoord.latitude -
                    bottomRightCoord.latitude) * extraSpace,
                longitudeDelta: abs(topLeftCoord.longitude -
                    bottomRightCoord.longitude) * extraSpace)
            region = MKCoordinateRegion(center: center, span: span)
        }
        return mapView.regionThatFits(region)
    }
    
    
    func showLocationDetails(_ sender: UIButton) {
        performSegue(withIdentifier: "EditLocation", sender: sender)
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditLocation" {
            let navigationController = segue.destination as! UINavigationController
            let controller = navigationController.topViewController
                as! LocationDetailsViewController
            controller.managedObjectContext = managedObjectContext
            let button = sender as! UIButton
            let location = locations[button.tag]
            controller.locationToEdit = location
        }
    }
    
    
}



extension MapViewController: MKMapViewDelegate { //This delegate is useful for creating your own annotation views
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // the special “is” type check operator to determine whether the annotation is really a Location object. If it isn’t, then return nil to signal that you’re not making an annotation for this other kind of object.
        guard annotation is Location else {
            return nil
        }
        // ask the map view to re-use an annotation view object. If it cannot find a recyclable annotation view, then create a new one.
        let identifier = "Location"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        if annotationView == nil {
            let pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            // This sets some properties to configure the look and feel of the annotation view. Previously the pins were red, but here make them green
            pinView.isEnabled = true
            pinView.canShowCallout = true
            pinView.animatesDrop = false
            pinView.pinTintColor = UIColor(red: 0.32, green: 0.82, blue: 0.4, alpha: 1)
            // create a new UIButton object that looks like a detail disclosure button (a blue circled i). Use the target-action pattern to hook up the button’s “Touch Up Inside” event with a new method showLocationDetails(), and add the button to the annotation view’s accessory view
            let rightButton = UIButton(type: .detailDisclosure)
            rightButton.addTarget(self,
                                  action: #selector(showLocationDetails),
                                  for: .touchUpInside)
            pinView.rightCalloutAccessoryView = rightButton
            annotationView = pinView
        }
        if let annotationView = annotationView {
            annotationView.annotation = annotation
            // Once the annotation view is constructed and configured, obtain a reference to that detail disclosure button again and set its tag to the index of the Location object in the locations array. That way then can find the Location object later in showLocationDetails() when the button is pressed.
            let button = annotationView.rightCalloutAccessoryView as! UIButton
            if let index = locations.index(of: annotation as! Location) {
                button.tag = index
            }
        }
        return annotationView
    }
    
    
}
