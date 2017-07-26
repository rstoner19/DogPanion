//
//  Medicine+CoreDataProperties.swift
//  DogPanion
//
//  Created by Rick Stoner on 7/26/17.
//  Copyright © 2017 Rick Stoner. All rights reserved.
//
//

import Foundation
import CoreData


extension Medicine {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Medicine> {
        return NSFetchRequest<Medicine>(entityName: "Medicine")
    }

    @NSManaged public var dateGiven: NSDate?
    @NSManaged public var name: String?
    @NSManaged public var notificationID: String?
    @NSManaged public var dateDue: NSDate?
    @NSManaged public var notificationIDTwo: String?
    @NSManaged public var notificationIDThree: String?
    @NSManaged public var notificationIDFour: String?
    @NSManaged public var reminder: Bool
    @NSManaged public var frequency: String?
    @NSManaged public var health: Health?

}
