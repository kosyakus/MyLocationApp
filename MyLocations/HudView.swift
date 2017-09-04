//
//  HudView.swift
//  MyLocations
//
//  Created by Admin on 04.09.17.
//  Copyright © 2017 NS. All rights reserved.
//

import Foundation
import UIKit


class HudView: UIView {
    
    var text = ""
    class func hud(inView view: UIView, animated: Bool) -> HudView { //a convenience constructor. It creates and returns a new HudView instance. CC is always a class method!
        
        let hudView = HudView(frame: view.bounds) //create a new HudView object using conv constr
        hudView.isOpaque = false
        view.addSubview(hudView)
        view.isUserInteractionEnabled = false
        //hudView.backgroundColor = UIColor(red: 1, green: 0, blue: 0, alpha: 0.5)
        
        hudView.show(animated: animated)
        return hudView
    }
    //This method adds the new HudView object as a subview on top of the “parent” view object. This is the navigation controller’s view so the HUD will cover the entire screen.
    //It also sets view’s isUserInteractionEnabled property to false. While the HUD is showing user can't interact with the screen anymore. The user has already pressed the Done button and the screen is in the process of closing.
    
    override func draw(_ rect: CGRect) {
        let boxWidth: CGFloat = 96
        let boxHeight: CGFloat = 96
    //The HUD rectangle should be centered horizontally and vertically on the screen. The size of the screen is given by bounds.size
        let boxRect = CGRect( 
            x: round((bounds.size.width - boxWidth) / 2),
            y: round((bounds.size.height - boxHeight) / 2),
            width: boxWidth,
            height: boxHeight)
    //UIBezierPath is an object for drawing rectangles with rounded corners. Just tell it how large the rectangle is and how round the corners should be. Then fill it with an 80% opaque dark gray color
        let roundedRect = UIBezierPath(roundedRect: boxRect, cornerRadius: 10)
        UIColor(white: 0.3, alpha: 0.8).setFill()
        roundedRect.fill()
        
    //This loads the checkmark image into a UIImage object. Then it calculates the position for that image based on the center coordinate of the HUD view (center) and the dimensions of the image (image.size)
        if let image = UIImage(named: "Checkmark") { //failable initializer
            let imagePoint = CGPoint(
                x: center.x - round(image.size.width / 2),
                y: center.y - round(image.size.height / 2) - boxHeight / 8)
            image.draw(at: imagePoint)
        }
        
        let attribs = [ NSFontAttributeName: UIFont.systemFont(ofSize: 16),//create UIFont obj for text
                        NSForegroundColorAttributeName: UIColor.white ] //choose a color for text
        let textSize = text.size(attributes: attribs)
        let textPoint = CGPoint( //calculate where to draw the text (textPoint), and then draw it
            x: center.x - round(textSize.width / 2),
            y: center.y - round(textSize.height / 2) + boxHeight / 4)
        text.draw(at: textPoint, withAttributes: attribs)
    }
    
    
    func show(animated: Bool) {
        if animated {
            // Set up the initial state of the view before the animation starts
            alpha = 0 //making the view fully transparent
            transform = CGAffineTransform(scaleX: 1.3, y: 1.3) //this means the view is initially stretched out
            // set up an animation with closure which describes it
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7,
                           initialSpringVelocity: 0.5, options: [], animations: {
            // set up the new state of the view that it should have after the animation completes
            self.alpha = 1 //the HudView is now fully opaque
            self.transform = CGAffineTransform.identity //restoring the scale back to normal
            },
                completion: nil)
        }
    }
    
    
    
}
