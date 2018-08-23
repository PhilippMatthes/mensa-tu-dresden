//
//  Notification.swift
//  mensa-tu-dresden
//
//  Created by Philipp Matthes on 20.08.18.
//  Copyright © 2018 Philipp Matthes. All rights reserved.
//

import Foundation
import UserNotifications

struct AppNotification: Equatable {
    
    let title: String
    let subtitle: String
    let body: String
    let important: Bool
    
    private static var lastDispatchDate: Date? {
        get {
            guard let date = UserDefaults.standard.object(forKey: "lastDispatchDate") as? Date else {return nil}
            return date
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "lastDispatchDate")
        }
    }
    
    static func didDispatchToday() -> Bool {
        guard let lastDispatchDate = lastDispatchDate else {return false}
        let cal = Calendar.current
        let yearOfLastDispatch = cal.ordinality(of: .year, in: .year, for: lastDispatchDate)
        let yearOfToday = cal.ordinality(of: .year, in: .year, for: Date())
        let dayOfLastDispatch = cal.ordinality(of: .day, in: .year, for: lastDispatchDate)
        let dayOfToday = cal.ordinality(of: .day, in: .year, for: Date())
        return dayOfLastDispatch == dayOfToday && yearOfLastDispatch == yearOfToday
    }
    
    static func == (lhs: AppNotification, rhs: AppNotification) -> Bool {
        return lhs.title == rhs.title && lhs.subtitle == rhs.subtitle && lhs.body == rhs.body && lhs.important == rhs.important
    }
    
    init?(meal: Meal) {
        guard let similarity = meal.highestSimilarityToOneOfStoredMeals() else {return nil}
        important = similarity.score > 0.95
        if important {
            title = "Es gibt \(meal.name)!"
            subtitle = "Hier: \(meal.mensa)"
            body = "In der Mensa \(meal.mensa) gibt es heute \(meal.name)!\n" + ("Stichwörter: \(similarity.meal.tokens?.joined(separator: ", ") ?? "")")
        } else {
            return nil
        }
    }
    
    func dispatch() {
        AppNotification.lastDispatchDate = Date()
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
    }
    
}
