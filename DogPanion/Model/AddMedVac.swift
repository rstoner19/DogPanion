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

    class func timeToAdd(frequency: String, date: Date) -> Date {
        let dueDate: Date
        switch frequency {
            case "Twice Daily":
            dueDate = date.addHalfDay()
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
    
    class func pickerComponents(frequency: String) -> Int {
        let component: Int
        switch frequency {
        case "Twice Daily":
            component = 0
        case "Daily":
            component = 1
        case "Weekly":
            component = 2
        case "Monthly":
            component = 3
        case "Quarterly":
            component = 4
        case "Semi-Annually":
            component = 5
        case "Annually":
            component = 6
        default:
            component = 0
        }
        return component
    }
}
