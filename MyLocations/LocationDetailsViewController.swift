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
//import Dispatch //This imports the Grand Central Dispatch framework
import CoreData

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
    
    
    var managedObjectContext: NSManagedObjectContext!
    var date = Date() //need to store the current date in the new Location object and make that Date object once
    
    
    var coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0) //contains only the latitude and longitude from the CLLocation
    var placemark: CLPlacemark? // contains the address information – street name, city name, and so on
    
    var categoryName = "No Category" //temporarily store the chosen category
    
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var addPhotoLabel: UILabel!
    
    var image: UIImage? //If no photo is picked yet, image is nil, so this must be an optional
    
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    
    //The value of the new locationToEdit property determines whether the screen operates in “adding” mode or in “editing” mode
    var locationToEdit: Location? {
        didSet { //property observer
            if let location = locationToEdit {
                descriptionText = location.locationDescription
                categoryName = location.category
                date = location.date
                coordinate = CLLocationCoordinate2DMake(location.latitude, location.longitude)
                placemark = location.placemark
            }
        }
    }
    var descriptionText = ""
    
    
    func format(date: Date) -> String {
        return dateFormatter.string(from: date)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let location = locationToEdit {
            title = "Edit Location"
        }
        
        descriptionTextView.text = descriptionText
        categoryLabel.text = categoryName
        
        latitudeLabel.text = String(format: "%.8f", coordinate.latitude)
        longitudeLabel.text = String(format: "%.8f", coordinate.longitude)
        
        if let placemark = placemark {
            addressLabel.text = string(from: placemark)
        } else {
            addressLabel.text = "No Address Found"
        }
        dateLabel.text = format(date: date)
        
//keyboard will disappeare after tapping anywhere else on the screen
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        gestureRecognizer.cancelsTouchesInView = false
        tableView.addGestureRecognizer(gestureRecognizer)
        
        listenForBackgroundNotification()
    }
    
    func hideKeyboard(_ gestureRecognizer: UIGestureRecognizer) {
        let point = gestureRecognizer.location(in: tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        if indexPath != nil && indexPath!.section == 0 && indexPath!.row == 0 { //(If user taps inside the table view but not on a cell, for example somewhere in between two sections or on the section header. In that case indexPath will be nil)
            return
        }
        descriptionTextView.resignFirstResponder()
    }
    
    
    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            return 88
        case (1, _):
            return imageView.isHidden ? 44 : 280 // this is new for adding image
            //If the thing before the ? is true (imageView.isHidden) it returns the first value, 44. If false, it returns the second value, 280
        case (2, 2):
            addressLabel.frame.size = CGSize(
            width: view.bounds.size.width - 115,
            height: 10000)
            addressLabel.sizeToFit()
            addressLabel.frame.origin.x = view.bounds.size.width - addressLabel.frame.size.width - 15
            return addressLabel.frame.size.height + 20
        default:
            return 44
        }
    }
    
    
    
    func show(image: UIImage) {
        imageView.image = image //This puts the image into the image view
        imageView.isHidden = false //makes the image view visible
        imageView.frame = CGRect(x: 10, y: 10, width: 260, height: 260) //gives it the proper dimensions
        addPhotoLabel.isHidden = true //hides the Add Photo label not to overlap the image view
    }
    
    
//used the notification center to listen for the UIApplicationDidEnterBackground notification. adds an observer
    func listenForBackgroundNotification() {
        NotificationCenter.default.addObserver(
            forName: Notification.Name.UIApplicationDidEnterBackground,
            object: nil, queue: OperationQueue.main) { _ in
                
                if self.presentedViewController != nil {
                    self.dismiss(animated: false, completion: nil) //If there is an active image picker or action sheet, then dismiss it. Also hide the keyboard if the text view was active.
                }
                self.descriptionTextView.resignFirstResponder()
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
    
    
    // MARK: - UITableViewDelegate
    //When the user taps anywhere inside that first cell, the text view should activate, even if the tap wasn’t on the text view itself.
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath.section == 0 || indexPath.section == 1 {
            return indexPath
        } else {
            return nil
        }
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            descriptionTextView.becomeFirstResponder()
        } else if indexPath.section == 1 && indexPath.row == 0 {
            //takePhotoWithCamera()
            tableView.deselectRow(at: indexPath, animated: true) // when selecting the row it stays gray only for a while. background quickly fades from gray back to white
            pickPhoto()
        }
    }
    
    
    
    @IBAction func done() {
        //dismiss(animated: true, completion: nil)
        
        let hudView = HudView.hud(inView: navigationController!.view, animated: true) //create a HudView object and adds it to the navigation controller’s view with an animation
        
        let location: Location //create a new Location instance
        if let temp = locationToEdit {
            hudView.text = "Updated" //set the text property on the hudView
            location = temp
        } else { //ask Core Data for a new Location object if it doesn’t already have one
            hudView.text = "Tagged" //set the text property on the hudView
            location = Location(context: managedObjectContext)
        }
        
       /* let delayInSeconds = 0.6
    //these incantations tells the app to close the Tag Location screen after 0.6 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + delayInSeconds, execute:
            {
                self.dismiss(animated: true, completion: nil)
        })
        //DispatchQueue.main.asyncAfter() uses the time given by .now() + delayInSeconds to schedule the closure for some point in the future. After 0.6 seconds, the code from the closure finally runs and the screen closes */
        
        
        // create a new Location instance
        //let location = Location(context: managedObjectContext)
        
        // set its properties to whatever the user entered in the screen
        location.locationDescription = descriptionTextView.text
        location.category = categoryName
        location.latitude = coordinate.latitude
        location.longitude = coordinate.longitude
        location.date = date
        location.placemark = placemark
        // save the context
        do {
            try managedObjectContext.save()
            afterDelay(0.6) {
                self.dismiss(animated: true, completion: nil)
            }
        } catch {
            fatalCoreDataError(error)
        }
        
    }
    
    
    @IBAction func cancel() {
        dismiss(animated: true, completion: nil)
    }
    
    
//This sets the selectedCategoryName property of the category picker
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PickCategory" {
            let controller = segue.destination as! CategoryPickerViewController
            controller.selectedCategoryName = categoryName
        }
    }
    
    @IBAction func categoryPickerDidPickCategory(_ segue: UIStoryboardSegue) { //in order to make an unwind segue you need to define an action method that takes a UIStoryboardSegue parameter
        let controller = segue.source as! CategoryPickerViewController //look at the view controller that sent the segue (the source)
        categoryName = controller.selectedCategoryName //read the value of its selectedCategoryName property
        categoryLabel.text = categoryName
    }
    
}


extension LocationDetailsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
//The UIImagePickerController is a view controller like any other, but it is built into UIKit and it takes care of the entire process of taking new photos and picking them from the user’s photo library
    func takePhotoWithCamera() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    //This is the method that gets called when the user has selected a photo in the image picker
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        image = info[UIImagePickerControllerEditedImage] as? UIImage //The info dictionary contains a variety of data describing the image that the user picked
        
        if let theImage = image {
            show(image: theImage)
        }
        
        tableView.reloadData() //This refreshes the table view and sets the photo row to the proper height
        dismiss(animated: true, completion: nil)
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
    func choosePhotoFromLibrary() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    
    func pickPhoto() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            showPhotoMenu()
        } else {
            choosePhotoFromLibrary()
        }
    }
    
    
    func showPhotoMenu() {
        let alertController = UIAlertController(title: nil, message: nil,
                                                preferredStyle: .actionSheet)
        //The handler: parameter determines what happens when you press the corresponding button in the action sheet
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        let takePhotoAction = UIAlertAction(title: "Take Photo", style: .default,
                                            handler: { _ in self.takePhotoWithCamera() })
        alertController.addAction(takePhotoAction)
        let chooseFromLibraryAction = UIAlertAction(title: "Choose From Library", style: .default,
                                                    handler: { _ in self.choosePhotoFromLibrary() })
        //This gives handler: a closure that calls the corresponding method from the extension. Use the _ wildcard to ignore the parameter that is passed to this closure
        
        alertController.addAction(chooseFromLibraryAction)
        present(alertController, animated: true, completion: nil)
    }
    
}





