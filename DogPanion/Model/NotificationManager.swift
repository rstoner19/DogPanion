//
//  NotificationManager.swift
//  DogPanion
//
//  Created by Rick Stoner on 7/25/17.
//  Copyright © 2017 Rick Stoner. All rights reserved.
//

import Foundation
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
    
     //TODO: Need to delete at some point
    class func printPendingNotificationRequests() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { (requests) in
            for request in requests {
                print(request.identifier)
            }
        }
    }
}
