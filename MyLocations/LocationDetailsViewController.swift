//
//  LocationDetailsViewController.swift
//  MyLocations
//
//  Created by Admin on 01.09.17.
//  Copyright © 2017 NS. All rights reserved.
//

import Foundation
import UIKit

class LocationDetailsViewController: UITableViewController {
    
    
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    
    @IBAction func done() {
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func cancel() {
        dismiss(animated: true, completion: nil)
    }
    
}
