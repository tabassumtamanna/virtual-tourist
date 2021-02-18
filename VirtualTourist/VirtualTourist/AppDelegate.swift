//
//  AppDelegate.swift
//  VirtualTourist
//
//  Created by Tabassum Tamanna on 2/5/21.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {


    // MARK: UIApplicationDelegate
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Usually this is not overridden. Using the "did finish launching" method is more typical
        print("App Delegate: will finish launching")
        checkIfFirstLaunch()
        return true
    }

    
    func checkIfFirstLaunch() {
        if UserDefaults.standard.bool(forKey: "HasLaunchedBefore") {
            print("App has launched before")
        } else {
            print("This is the first launch ever!")
            UserDefaults.standard.set(true, forKey: "HasLaunchedBefore")
            UserDefaults.standard.set(0.0, forKey: "defaultZoomLevel")
            UserDefaults.standard.set(0.0, forKey: "defaultLatitude")
            UserDefaults.standard.set(0.0, forKey: "defaultLongitude")
            UserDefaults.standard.synchronize()
        }
    }


}

