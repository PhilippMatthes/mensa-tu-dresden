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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        let loginController = LoginController()
        
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
    
    
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        Meal.thisWeek() {
            meals in
            for meal in meals {
                
                guard let similarity = meal.highestSimilarityToOneOfStoredMeals() else {return}
                
                var title: String
                var subtitle: String
                var body: String
                let important = similarity.score > 0.95
                let lessImportant = similarity.score > 0.5
                if important {
                    title = "Es gibt \(meal.name)!"
                    subtitle = "Hier: \(meal.mensa)"
                    body = "In der Mensa \(meal.mensa) gibt es heute \(meal.name)!\n" + (" Stichwörter: \(similarity.meal.tokens?.joined(separator: ", ") ?? "")")
                } else if lessImportant {
                    title = "Dieses Essen könnte dir schmecken!"
                    subtitle = "\(meal.name)"
                    body = "In der Mensa \(meal.mensa) gibt es heute \(meal.name).\n" + (" Stichwörter: \(similarity.meal.tokens?.joined(separator: ", ") ?? "")")
                } else {
                    continue
                }
                
                if #available(iOS 10.0, *) {
                
                    let content = UNMutableNotificationContent()
                    content.title = title
                    content.subtitle = subtitle
                    content.body = body
                    if #available(iOS 12.0, *) {
                        content.sound = important ? UNNotificationSound.defaultCritical : UNNotificationSound.default
                    } else {
                        content.sound = important ? UNNotificationSound.default : nil
                    }
                    content.categoryIdentifier = important ? "important" : "unimportant"
                    
                    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
                
                    let requestIdentifier = "notificationIdentifier"
                    let request = UNNotificationRequest(identifier: requestIdentifier, content: content, trigger: trigger)
                    UNUserNotificationCenter.current().add(request) {
                        error in
                    }
                } else {
                    // Fallback on earlier versions
                }
            }
        }
    }

}

