//
//  AddMedVac.swift
//  DogPanion
//
//  Created by Rick Stoner on 7/27/17.
//  Copyright © 2017 Rick Stoner. All rights reserved.
//

import Foundation

struct MedVacElements {
    
    var date: Date?
    var name: String?
    var notificationID: String?
    var notifcationIDTwo: String?
    var notifcationIDThree: String?
    var notifcationIDFour: String?
    var reminder: Bool?
    var frequency: String?
}

class AddMedVac {
//    class func setNotifications(reminder: Bool, frequency: String, dateGiven: Date) -> (dueDate: Date, notifcationID: String?, notifcationIDTwo: String, notifcationIDThree: String?, notifcationIDFour: String?) {
//        
//        
//        
//    }
    //TODO: Modify for components
    class func timeToAdd(frequency: String, date: Date) -> Date {
        let dueDate: Date
        switch frequency {
            case "Daily":
            dueDate = date.addDay()
            case "Weekly":
            dueDate = date.addWeek()
            case "Monthly":
            dueDate = date.addMonth()
            case "Quarterly":
            dueDate = date.addQuarter()
            case "Semi-Annually":
            dueDate = date.addHalfYear()
            default:
            dueDate = date.addYear()
        }
        return dueDate
    }
}
