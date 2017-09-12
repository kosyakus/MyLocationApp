//
//  Location+CoreDataProperties.swift
//  MyLocations
//
//  Created by Admin on 05.09.17.
//  Copyright © 2017 NS. All rights reserved.
//

import Foundation
import CoreData
import CoreLocation // added to change the placemark type

//!!!!! It is better not to change anything in this file, it could be updated if change DataModel

extension Location {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Location> {
        return NSFetchRequest<Location>(entityName: "Location")
    }

    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var date: Date // changed the type, remove the ?
    @NSManaged public var locationDescription: String // remove the ?
    @NSManaged public var category: String
    @NSManaged public var placemark: CLPlacemark? // changed the type
    @NSManaged var photoID: NSNumber?

}
