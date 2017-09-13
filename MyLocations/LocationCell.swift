//
//  LocationCell.swift
//  MyLocations
//
//  Created by Admin on 07.09.17.
//  Copyright © 2017 NS. All rights reserved.
//

import UIKit

class LocationCell: UITableViewCell {
    
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        
        // change the appearance of the actual cells. This method is invoked when UIKit loads the object from the storyboard
        backgroundColor = UIColor.black
        descriptionLabel.textColor = UIColor.white
        descriptionLabel.highlightedTextColor = descriptionLabel.textColor
        addressLabel.textColor = UIColor(white: 1.0, alpha: 0.4)
        addressLabel.highlightedTextColor = addressLabel.textColor
        
        //This creates a new UIView filled with a dark gray color. This new view is placed on top of the cell’s background when the user taps on the cell
        let selectionView = UIView(frame: CGRect.zero)
        selectionView.backgroundColor = UIColor(white: 1.0, alpha: 0.2)
        selectedBackgroundView = selectionView
        
        // make the thumbnails rounded
        photoImageView.layer.cornerRadius = photoImageView.bounds.size.width / 2
        photoImageView.clipsToBounds = true
        separatorInset = UIEdgeInsets(top: 0, left: 82, bottom: 0, right: 0)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func configure(for location: Location) {
        if location.locationDescription.isEmpty {
            descriptionLabel.text = "(No Description)"
        } else {
            descriptionLabel.text = location.locationDescription
        }
        if let placemark = location.placemark {
            /*var text = ""
            if let s = placemark.subThoroughfare {
                text += s + " "
            }
            if let s = placemark.thoroughfare {
                text += s + ", "
            }
            if let s = placemark.locality {
                text += s
            }
            addressLabel.text = text */
            var text = ""
            text.add(text: placemark.subThoroughfare)
            text.add(text: placemark.thoroughfare, separatedBy: " ")
            text.add(text: placemark.locality, separatedBy: ", ")
            addressLabel.text = text
        } else {
            addressLabel.text = String(format:
                "Lat: %.8f, Long: %.8f", location.latitude, location.longitude)
        }
        
        photoImageView.image = thumbnail(for: location)
    }
    
    //This returns either the image from the Location or an empty placeholder image
    func thumbnail(for location: Location) -> UIImage {
        if location.hasPhoto, let image = location.photoImage {
            return image.resizedImage(withBounds: CGSize(width: 52, height: 52)) // thanks to the extention of UIImage
        }
        return UIImage(named: "No Photo")!
    }

}
