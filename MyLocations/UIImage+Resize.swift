//
//  UIImage+Resize.swift
//  MyLocations
//
//  Created by Admin on 12.09.17.
//  Copyright © 2017 NS. All rights reserved.
//

import Foundation
import UIKit


extension UIImage {
    
    func resizedImage(withBounds bounds: CGSize) -> UIImage {
        //This method first calculates how big the image can be in order to fit inside the bounds rectangle
        let horizontalRatio = bounds.width / size.width
        let verticalRatio = bounds.height / size.height
        let ratio = min(horizontalRatio, verticalRatio)
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        
        //Then it creates a new image context and draws the image into that
        UIGraphicsBeginImageContextWithOptions(newSize, true, 0)
        draw(in: CGRect(origin: CGPoint.zero, size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    
}
