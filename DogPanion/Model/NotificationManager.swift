//
//  NotificationManager.swift
//  DogPanion
//
//  Created by Rick Stoner on 7/25/17.
//  Copyright © 2017 Rick Stoner. All rights reserved.
//

import UIKit
import UserNotifications

class NotificationManager {
    
    class func scheduleNotification(title: String, body: String, identifier: String, dateCompenents: DateComponents, repeatNotifcation: Bool) {
        let content = UNMutableNotificationContent()
        content.title = NSString.localizedUserNotificationString(forKey: title, arguments: nil)
        content.body = NSString.localizedUserNotificationString(forKey: body, arguments: nil)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateCompenents, repeats: repeatNotifcation)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        let center = UNUserNotificationCenter.current()
        center.add(request, withCompletionHandler: nil)
    }
    
    class func getDateComponents(startDate: Date, frequency: String, timeofDay: String) -> [DateComponents] {
        var dateComponents: [DateComponents] = []
        var components = DateComponents()
        let startComponents = Calendar.current.dateComponents([.weekday,.day,.month], from: startDate)
        
        switch timeofDay {
        case "Morning":
            components.hour = 9
        case "Afternoon":
            components.hour = 12
        case "Evening":
            components.hour = 17
        default:
            components.hour = 18
        }
        
        switch frequency {
        case "Daily":
            break
        case "Weekly":
            components.weekday = startComponents.weekday
        case "Monthly":
            components.day = (startComponents.day ?? 1) > 28 ? 28 : startComponents.day
        case "Quarterly":
            components.day = (startComponents.day ?? 1) > 28 ? 28 : startComponents.day
            components.month = startComponents.month
            for count in 0...2 {
                var newComponent = DateComponents()
                newComponent.day = (startComponents.day ?? 1) > 28 ? 28 : startComponents.day
                newComponent.month = startComponents.month! + ((count + 1) * 3)
                dateComponents.append(newComponent)
            }
        case "Semi-Annually":
            components.day = (startComponents.day ?? 1) > 28 ? 28 : startComponents.day
            components.month = startComponents.month
            var newComponent = DateComponents()
            newComponent.day = (startComponents.day ?? 1) > 28 ? 28 : startComponents.day
            newComponent.month = startComponents.month! + 6
        case "Annually":
            components.day = (startComponents.day ?? 1) > 28 ? 28 : startComponents.day
            components.month = startComponents.month
        default:
            print("Error, unrecognized case.")
        }
        dateComponents.insert(components, at: 0)
        return dateComponents
    }
    
    class func deleteNotication(identifiers: [String]) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }
    
    class func deleteAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
}
