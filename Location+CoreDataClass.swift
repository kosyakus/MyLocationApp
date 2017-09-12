//
//  Location+CoreDataClass.swift
//  MyLocations
//
//  Created by Admin on 05.09.17.
//  Copyright © 2017 NS. All rights reserved.
//

import Foundation
import CoreData
import MapKit

@objc(Location)
public class Location: NSManagedObject, MKAnnotation {

    
    public var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2DMake(latitude, longitude)
    }
    public var title: String? {
        if locationDescription.isEmpty {
            return "(No Description)"
        } else {
            return locationDescription
        }
    }
    public var subtitle: String? {
        return category
    }
    
    
    //This determines whether the Location object has a photo associated with it or not.
    var hasPhoto: Bool {
        return photoID != nil
    }
    
    //This property computes the full URL to the JPEG file for the photo
    var photoURL: URL {
        assert(photoID != nil, "No photo ID set") //An assertion is a special debugging tool that is used to check that code always does something valid
        let filename = "Photo-\(photoID!.intValue).jpg"
        return applicationDocumentsDirectory.appendingPathComponent(filename) //save these JPEG files inside the app’s Documents directory.it uses the global variable applicationDocumentsDirectory that was added to Functions.swift earlier
    }
    
    //This method returns a UIImage object by loading the image file.
    var photoImage: UIImage? {
        return UIImage(contentsOfFile: photoURL.path)
    }
    
    //some way to generate a unique ID for each Location object
    class func nextPhotoID() -> Int {
        let userDefaults = UserDefaults.standard
        let currentID = userDefaults.integer(forKey: "PhotoID")
        userDefaults.set(currentID + 1, forKey: "PhotoID")
        userDefaults.synchronize()
        return currentID
    }
    
    
    // method to remove the photo file when the Location object is deleted
    func removePhotoFile() {
        if hasPhoto {
            do {
                try FileManager.default.removeItem(at: photoURL)
            } catch {
                print("Error removing file: \(error)")
            }
        }
    }
    
}
