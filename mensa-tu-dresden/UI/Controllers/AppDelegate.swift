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
import UserNotifications
import GoogleSignIn
import FBSDKLoginKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        // FBSDKApplicationDelegate.sharedInstance()?.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        let loginController = LoginController.fromStoryboard()
        
        window = UIWindow(frame: Screen.bounds)
        window!.rootViewController = loginController
        window!.makeKeyAndVisible()
        
        UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplication.backgroundFetchIntervalMinimum)
        
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) {
                (permissionGranted, error) in
            }
            UNUserNotificationCenter.current().delegate = self
        } else {
            // Fallback on earlier versions
        }
        
        return true
    }
    
    /*
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        var handled = FBSDKApplicationDelegate.sharedInstance()?.application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
        handled = handled ?? GIDSignIn.sharedInstance()?.handle(url, sourceApplication: sourceApplication, annotation: annotation)
        handled = handled ?? false
        return handled!
    }
    */
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if AppNotification.didDispatchToday() {
            completionHandler(.noData)
            return
        }
        Meal.thisWeek() {
            meals in
            for meal in meals {
                guard let notification = AppNotification(meal: meal) else {continue}
                notification.dispatch()
            }
            completionHandler(.newData)
        }
    }

}

