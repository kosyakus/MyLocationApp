//
//  AppDelegate.swift
//  MyLocations
//
//  Created by Admin on 27.08.17.
//  Copyright © 2017 NS. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
//load the data model that was defined earlier, and connect it to an SQLite data store. The goal here is to create a so-called NSManagedObjectContext object. That is the object that is used to talk to Core Data
    //This code creates an instance variable persistentContainer of type NSPersistentContainer. To get the NSManagedObjectContext, simply ask the persistentContainer for its viewContext property.
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "DataModel") //instantiate a new NSPC with the name of the data model
        container.loadPersistentStores(completionHandler: { //to loadPersistentStores(), which loads the data from the database into memory and sets up the Core Data stack
            storeDescription, error in
            if let error = error {
                fatalError("Could load data store: \(error)")
            }
        })
        return container
    }()

    
    lazy var managedObjectContext: NSManagedObjectContext = self.persistentContainer.viewContext
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        //first have to find the UITabBarController and then look at its viewControllers array. Once it has a reference to the CurrentLocationViewController object, it gives it the managedObjectContext
        let tabBarController = window!.rootViewController as! UITabBarController
        if let tabBarViewControllers = tabBarController.viewControllers {
            let currentLocationViewController = tabBarViewControllers[0] as! CurrentLocationViewController
            currentLocationViewController.managedObjectContext = managedObjectContext
        }
        print(applicationDocumentsDirectory)
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

