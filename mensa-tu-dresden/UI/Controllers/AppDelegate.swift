//
//  AppDelegate.swift
//  mensa-tu-dresden
//
//  Created by Philipp Matthes on 10.08.18.
//  Copyright © 2018 Philipp Matthes. All rights reserved.
//

import UIKit
import Firebase
import Material
import Motion

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        
        let rootViewController = MealTableController()
        let searchController = SearchBarController(rootViewController: rootViewController)
        
        window = UIWindow(frame: Screen.bounds)
        window!.rootViewController = searchController
        window!.makeKeyAndVisible()
        
        return true
    }


}

