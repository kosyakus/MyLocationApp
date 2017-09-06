//
//  LocationsViewController.swift
//  MyLocations
//
//  Created by Admin on 06.09.17.
//  Copyright © 2017 NS. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CoreLocation


class LocationsViewController: UITableViewController {
    
    var managedObjectContext: NSManagedObjectContext!
    
    var locations = [Location]() //array contains the list of Location objects
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//ask the managed object context for a list of all Location objects in the data store, sorted by date
        
        // the object that describes which objects going to fetch from the data store
        let fetchRequest = NSFetchRequest<Location>() //The < > mean that NSFetchRequest is a generic
        // tell the fetch request you’re looking for Location entities
        let entity = Location.entity()
        fetchRequest.entity = entity
    // The NSSortDescriptor tells the fetch request to sort on the date attribute, in ascending order
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        do {
            // have the fetch request, then can tell the context to execute it. The fetch() method returns an array with the sorted objects, or throws an error in case smth went wrong
            locations = try managedObjectContext.fetch(fetchRequest) //assign the results of the fetch to the locations instance variable
        } catch {
            fatalCoreDataError(error)
        }
    }
    
    // MARK: - UITableViewDataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath)
        
        let location = locations[indexPath.row]
        
        let descriptionLabel = cell.viewWithTag(100) as! UILabel
        descriptionLabel.text = location.locationDescription
        
        let addressLabel = cell.viewWithTag(101) as! UILabel
        if let placemark = location.placemark {
            var text = ""
            if let s = placemark.subThoroughfare {
                text += s + " "
            }
            if let s = placemark.thoroughfare {
                text += s + ", "
            }
            if let s = placemark.locality {
                text += s
            }
            addressLabel.text = text
        } else {
            addressLabel.text = ""
        }
        
        return cell
    }
    
    
    
}
