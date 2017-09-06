//
//  Functions.swift
//  MyLocations
//
//  Created by Admin on 05.09.17.
//  Copyright © 2017 NS. All rights reserved.
//

import Foundation
import Dispatch


//The annotation @escaping is necessary for closures that are not performed immediately, so that Swift knows that it should hold on to this closure for a while
func afterDelay(_ seconds: Double, closure: @escaping () -> ()) {
    DispatchQueue.main.asyncAfter(deadline: .now() + seconds,
                                  execute: closure)
}


let applicationDocumentsDirectory: URL = {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask) //updated!
    return paths[0]
}()
