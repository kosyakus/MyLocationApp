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
    
    //var locations = [Location]() //array contains the list of Location objects
    
    lazy var fetchedResultsController: NSFetchedResultsController<Location> = { // replaced locations
            let fetchRequest = NSFetchRequest<Location>()
            let entity = Location.entity()
            fetchRequest.entity = entity
            let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
            fetchRequest.sortDescriptors = [sortDescriptor]
            fetchRequest.fetchBatchSize = 20 //how many objects will be fetched at a time
            let fetchedResultsController = NSFetchedResultsController(
                fetchRequest: fetchRequest,
                managedObjectContext: self.managedObjectContext,
                sectionNameKeyPath: nil,
                cacheName: "Locations") //needs to be a unique name that NSFetchedResultsController uses to cache the search results
            fetchedResultsController.delegate = self
            return fetchedResultsController
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        performFetch() // simolify the line below
        
   /*
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
        }*/
    }
    
    
    func performFetch() {
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalCoreDataError(error)
        }
    }
    
//set the delegate to nil when no longer need the NSFetchedResultsController, just don’t get any more notifications that were still pending
    deinit {
        fetchedResultsController.delegate = nil
    }
    
    // MARK: - UITableViewDataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return locations.count
        let sectionInfo = fetchedResultsController.sections![section] //returns an array
        return sectionInfo.numberOfObjects
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath) as! LocationCell
        
        /*let location = locations[indexPath.row]
        cell.configure(for: location)*/
        
        //ask the fetchedResultsController for the object at the requested index-path
        let location = fetchedResultsController.object(at: indexPath)
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
                //let location = locations[indexPath.row]
                let location = fetchedResultsController.object(at: indexPath)
                controller.locationToEdit = location
            }
        }
    }
    
    
}



    //implement the delegate methods for NSFetchedResultsController
// NSFetchedResultsController will invoke these methods to let you know that certain objects were inserted, removed, or just updated. In response, you call the corresponding methods on the UITableView to insert, remove or update rows. That’s all there is to it.
extension LocationsViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller:
        NSFetchedResultsController<NSFetchRequestResult>) {
        print("*** controllerWillChangeContent")
        tableView.beginUpdates()
    }
    
    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any, at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            print("*** NSFetchedResultsChangeInsert (object)")
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            print("*** NSFetchedResultsChangeDelete (object)")
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            print("*** NSFetchedResultsChangeUpdate (object)")
            if let cell = tableView.cellForRow(at: indexPath!)
                as? LocationCell {
                let location = controller.object(at: indexPath!) as! Location
                cell.configure(for: location)
            }
        case .move:
            print("*** NSFetchedResultsChangeMove (object)")
            tableView.deleteRows(at: [indexPath!], with: .fade)
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        }
    }
    
    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange sectionInfo: NSFetchedResultsSectionInfo,
        atSectionIndex sectionIndex: Int,
        for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            print("*** NSFetchedResultsChangeInsert (section)")
            tableView.insertSections(IndexSet(integer: sectionIndex),
                                     with: .fade)
        case .delete:
            print("*** NSFetchedResultsChangeDelete (section)")
            tableView.deleteSections(IndexSet(integer: sectionIndex),
                                     with: .fade)
        case .update:
            print("*** NSFetchedResultsChangeUpdate (section)")
        case .move:
            print("*** NSFetchedResultsChangeMove (section)")
        }
    }
    
    func controllerDidChangeContent(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("*** controllerDidChangeContent")
        tableView.endUpdates()
    }
    
}
