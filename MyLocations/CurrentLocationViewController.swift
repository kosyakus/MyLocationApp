//
//  FirstViewController.swift
//  MyLocations
//
//  Created by Admin on 27.08.17.
//  Copyright © 2017 NS. All rights reserved.
//

import UIKit
import CoreLocation

class CurrentLocationViewController: UIViewController, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager() // The CLLocationManager is the object that will give the GPS coordinates
    
    var location: CLLocation?
    
    // variables for error handling
    var updatingLocation = false
    var lastLocationError: Error?
    
    // variables for converting coordinates into text place
    let geocoder = CLGeocoder() //is the object that will perform the geocoding
    var placemark: CLPlacemark? //is the object that contains the address results
    var performingReverseGeocoding = false //set to true when a geocoding operation is taking place
    var lastGeocodingError: Error? //will contain an Error object if something went wrong
    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var tagButton: UIButton!
    @IBOutlet weak var getButton: UIButton!
    
    
    @IBAction func getLocation() {
        // ask for user permission
        let authStatus = CLLocationManager.authorizationStatus()
        if authStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
            return
        }
        
        // if user denied for the first time it will show the message to activate in settings. This shows the alert if the authorization status is denied or restricted
        if authStatus == .denied || authStatus == .restricted {
            showLocationServicesDeniedAlert()
            return
        }
        
       /* locationManager.delegate = self //It tells the location manager that the view controller is its delegate
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.startUpdatingLocation() //start the location manager
        
        // From that moment on the CLLocationManager object will send location updates to its delegate, i.e. the view controller */
        //startLocationManager()
        
        
        // changes the state of the button: If the button is pressed while the app is already doing the location fetching, then it stops the location manager
        if updatingLocation {
            stopLocationManager()
        } else {
            location = nil
            lastLocationError = nil
            placemark = nil
            lastGeocodingError = nil
            startLocationManager()
        }
        
        updateLabels()
        configureGetButton()
        
    }
    
    
    
    // MARK: CLLocationManagerDelegate methods
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("didFailWithError \(error)")
        
    // When you get this error, you will simply keep trying until you do find a location or receive a more serious error
        if (error as NSError).code == CLError.locationUnknown.rawValue {
            return
        }
        lastLocationError = error //In case of more serious error, store the error in a new var
        stopLocationManager() //If obtaining a location is impossible then location manager should stop
        updateLabels()
        configureGetButton()
        
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLocation = locations.last!
        print("didUpdateLocations \(newLocation)")
        
        /*location = newLocation //store the CLLocation object into the instance variable
        lastLocationError = nil //This clears out the old error state
        updateLabels()*/
        
// If we don't want to update every second:
        // give the most recently found location under the assumption that you might not have moved much in the last few seconds
        if newLocation.timestamp.timeIntervalSinceNow < -5 {
            return
        }
        // To determine whether new readings are more accurate than previous ones
        if newLocation.horizontalAccuracy < 0 {
            return
        }
        // if this is the very first location reading (location is nil) or the new location is more accurate than the previous reading, you continue to step 4. Otherwise you ignore this location update
        if location == nil || location!.horizontalAccuracy > newLocation.horizontalAccuracy {
            // It clears out any previous error if there was one and stores the new CLLocation object into the location variable
            lastLocationError = nil
            location = newLocation
            updateLabels()
            // If the new location’s accuracy is equal to or better than the desired accuracy, then stop asking the location manager for updates (accuracy was set up to 10m)
            if newLocation.horizontalAccuracy <=
                locationManager.desiredAccuracy {
                print("*** We're done!")
                stopLocationManager()
                configureGetButton()
            }
            
            // check whether it is not busy by looking at the performingReverseGeocoding variable
            if !performingReverseGeocoding {
                print("*** Going to geocode")
                performingReverseGeocoding = true
                geocoder.reverseGeocodeLocation(newLocation, completionHandler: {
                    placemarks, error in //closure only performed after CLGeocoder finds an address or encounters an error
                    print("*** Found placemarks: \(placemarks), error: \(error)")
                    
                    self.lastGeocodingError = error
                    if error == nil, let p = placemarks, !p.isEmpty { //if there’s no error and the unwrapped placemarks array is not empty
                        self.placemark = p.last!
                    } else {
                        self.placemark = nil // in case of error-set to nil
                    }
                    self.performingReverseGeocoding = false
                    self.updateLabels()
                })
            }
        }
    }
    
    
    func updateLabels() {
        if let location = location {
            latitudeLabel.text = String(format: "%.8f", location.coordinate.latitude)
            longitudeLabel.text = String(format: "%.8f", location.coordinate.longitude)
            tagButton.isHidden = false
            messageLabel.text = ""
            
            //If it found an address, it shows that to the user, otherwise it shows a status message
            if let placemark = placemark {
                addressLabel.text = string(from: placemark)
            } else if performingReverseGeocoding {
                addressLabel.text = "Searching for Address..."
            } else if lastGeocodingError != nil {
                addressLabel.text = "Error Finding Address"
            } else {
                addressLabel.text = "No Address Found"
            }
            
        } else {
            latitudeLabel.text = ""
            longitudeLabel.text = ""
            addressLabel.text = ""
            tagButton.isHidden = true
            messageLabel.text = "Tap 'Get My Location' to Start"
        }
        
        let statusMessage: String
        if let error = lastLocationError as? NSError {
            if error.domain == kCLErrorDomain && error.code == CLError.denied.rawValue {
                statusMessage = "Location Services Disabled"
            } else {
                statusMessage = "Error Getting Location"
            }
        } else if !CLLocationManager.locationServicesEnabled() {
            statusMessage = "Location Services Disabled"
        } else if updatingLocation {
            statusMessage = "Searching..."
        } else {
            statusMessage = "Tap 'Get My Location' to Start"
        }
        messageLabel.text = statusMessage
    
    }


    func startLocationManager() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            updatingLocation = true
        }
    }

    func stopLocationManager() {
        if updatingLocation {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            updatingLocation = false
        }
    }
    
    
    // This pops up an alert with a helpful hint
    func showLocationServicesDeniedAlert() {
        let alert = UIAlertController(title: "Location Services Disabled", message:
            "Please enable location services for this app in Settings.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        updateLabels()
        configureGetButton()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
// if the app is currently updating the location then the button’s title becomes Stop, otherwise it is Get My Location. Should be called anywhere where was called updateLabels()
    func configureGetButton() {
        if updatingLocation {
            getButton.setTitle("Stop", for: .normal)
        } else {
            getButton.setTitle("Get My Location", for: .normal)
        }
    }
    
//The func to format the CLPlacemark object into a string:
    func string(from placemark: CLPlacemark) -> String {
        // Create new string variable for the first line of text
        var line1 = ""
        // If the placemark has a subThoroughfare(house number), add it to the string
        if let s = placemark.subThoroughfare {
            line1 += s + " "
        }
        // -/- (street name)
        if let s = placemark.thoroughfare {
            line1 += s
        }
        // This adds the locality (the city), administrative area (the state or province), and postal code (or zip code), with spaces between them where appropriate
        var line2 = ""
        if let s = placemark.locality {
            line2 += s + " "
        }
        if let s = placemark.administrativeArea {
            line2 += s + " "
        }
        if let s = placemark.postalCode {
            line2 += s
        }
        // adds both lines together
        return line1 + "\n" + line2
    }


}

