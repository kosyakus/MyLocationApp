//
//  LocationDetailsViewController.swift
//  MyLocations
//
//  Created by Admin on 01.09.17.
//  Copyright © 2017 NS. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

//private global constant. Lives outside of the LocationDetailsViewController class (global) but it is only visible inside the LocationDetailsViewController.swift file (private).
private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter
}()
// Note: If you leave out the (), Swift thinks you’re assigning the closure itself to dateFormatter – in other words, dateFormatter will contain a block of code, not an actual DateFormatter object. That’s not what you want. 
// Instead you want to assign the result of that closure to dateFormatter. To make that happen, you use the () to perform or evaluate the closure – this runs the code inside the closure and returns the DateFormatter object.

class LocationDetailsViewController: UITableViewController {
    
    
    var coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0) //contains only the latitude and longitude from the CLLocation
    var placemark: CLPlacemark? // contains the address information – street name, city name, and so on
    
    
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    
    func format(date: Date) -> String {
        return dateFormatter.string(from: date)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        descriptionTextView.text = ""
        categoryLabel.text = ""
        
        latitudeLabel.text = String(format: "%.8f", coordinate.latitude)
        longitudeLabel.text = String(format: "%.8f", coordinate.longitude)
        
        if let placemark = placemark {
            addressLabel.text = string(from: placemark)
        } else {
            addressLabel.text = "No Address Found"
        }
        dateLabel.text = format(date: Date())
    }
    
    
    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 && indexPath.row == 0 {
            return 88
        } else if indexPath.section == 2 && indexPath.row == 2 {
            addressLabel.frame.size = CGSize(width: view.bounds.size.width - 115, height: 10000)
            addressLabel.sizeToFit()
            addressLabel.frame.origin.x = view.bounds.size.width - addressLabel.frame.size.width - 15
            return addressLabel.frame.size.height + 20
        } else {
            return 44
        }
    }
    
    
    
    func string(from placemark: CLPlacemark) -> String {
        var text = ""
        if let s = placemark.subThoroughfare {
            text += s + " "
        }
        if let s = placemark.thoroughfare {
            text += s + ", "
        }
        if let s = placemark.locality {
            text += s + ", "
        }
        if let s = placemark.administrativeArea {
            text += s + " "
        }
        if let s = placemark.postalCode {
            text += s + ", "
        }
        if let s = placemark.country {
            text += s
        }
        return text
    }
    
    
    @IBAction func done() {
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func cancel() {
        dismiss(animated: true, completion: nil)
    }
    
}
