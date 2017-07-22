//
//  Medicine+CoreDataProperties.swift
//  DogPanion
//
//  Created by Rick Stoner on 7/21/17.
//  Copyright © 2017 Rick Stoner. All rights reserved.
//
//

import Foundation
import CoreData


extension Medicine {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Medicine> {
        return NSFetchRequest<Medicine>(entityName: "Medicine")
    }

    @NSManaged public var notificationIdentifier: String?
    @NSManaged public var name: String?
    @NSManaged public var dateGiven: NSDate?
    @NSManaged public var health: Health?

}
