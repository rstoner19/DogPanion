//
//  Vaccines+CoreDataClass.swift
//  DogPanion
//
//  Created by Rick Stoner on 7/26/17.
//  Copyright © 2017 Rick Stoner. All rights reserved.
//
//

import Foundation
import CoreData


public class Vaccines: NSManagedObject {
    func getNotificationsIDs() -> [String] {
        var identifiers: [String] = []
        if self.reminder {
            if let identifier = self.notificationID {
                identifiers.append(identifier)
            }
            if let identifier = self.notificationIDTwo {
                identifiers.append(identifier)
            }
            if let identifier = self.notificationIDThree {
                identifiers.append(identifier)
            }
            if let identifier = self.notificationIDFour {
                identifiers.append(identifier)
            }
        }
        return identifiers
    }
    
    func populatVaccines(frequency: String, name: String, date: Date, timeOfDay: String, reminder: Bool, notificationIDs: [String]?) {
        self.dateGiven = date as NSDate
        self.name = name
        self.reminder = reminder
        self.frequency = frequency
        self.dateDue =  AddMedVac.timeToAdd(frequency: frequency, date: date) as NSDate
        if let notifications = notificationIDs {
            self.notificationID = notifications[0]
            self.notificationIDTwo = notifications.count > 1 ? notifications[1] : nil
            if notifications.count > 2 {
                self.notificationIDThree = notifications[2]
                self.notificationIDFour = notifications[3]
            }
        }
    }
}
