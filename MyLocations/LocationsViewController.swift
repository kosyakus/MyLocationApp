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
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath) as! LocationCell
        
        let location = locations[indexPath.row]
        cell.configure(for: location)
        
        return cell
    }
    
    
//connect the LocationsViewController to the Location Details screen, so that when tap a row in the table, it lets user edit that location’s description and category
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditLocation" {
            let navigationController = segue.destination as! UINavigationController
            let controller = navigationController.topViewController as! LocationDetailsViewController
            controller.managedObjectContext = managedObjectContext
            if let indexPath = tableView.indexPath(for: sender as! UITableViewCell) {
                let location = locations[indexPath.row]
                controller.locationToEdit = location
            }
        }
    }
    
    
}
