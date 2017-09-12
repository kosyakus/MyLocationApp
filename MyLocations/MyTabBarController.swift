//
//  MyTabBarController.swift
//  MyLocations
//
//  Created by Admin on 12.09.17.
//  Copyright © 2017 NS. All rights reserved.
//

import Foundation
import UIKit

//make the status bar white for all view controllers in the entire app
class MyTabBarController: UITabBarController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    override var childViewControllerForStatusBarStyle: UIViewController? {
        return nil
    }
}
