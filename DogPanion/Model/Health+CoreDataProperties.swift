//
//  Health+CoreDataProperties.swift
//  DogPanion
//
//  Created by Rick Stoner on 7/21/17.
//  Copyright © 2017 Rick Stoner. All rights reserved.
//
//

import Foundation
import CoreData


extension Health {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Health> {
        return NSFetchRequest<Health>(entityName: "Health")
    }

    @NSManaged public var birthday: NSDate?
    @NSManaged public var notifications: Bool
    @NSManaged public var pet: Pet?
    @NSManaged public var vaccines: NSSet?
    @NSManaged public var weight: NSSet?
    @NSManaged public var medicine: NSSet?

}

// MARK: Generated accessors for vaccines
extension Health {

    @objc(addVaccinesObject:)
    @NSManaged public func addToVaccines(_ value: Vaccines)

    @objc(removeVaccinesObject:)
    @NSManaged public func removeFromVaccines(_ value: Vaccines)

    @objc(addVaccines:)
    @NSManaged public func addToVaccines(_ values: NSSet)

    @objc(removeVaccines:)
    @NSManaged public func removeFromVaccines(_ values: NSSet)

}

// MARK: Generated accessors for weight
extension Health {

    @objc(addWeightObject:)
    @NSManaged public func addToWeight(_ value: Weight)

    @objc(removeWeightObject:)
    @NSManaged public func removeFromWeight(_ value: Weight)

    @objc(addWeight:)
    @NSManaged public func addToWeight(_ values: NSSet)

    @objc(removeWeight:)
    @NSManaged public func removeFromWeight(_ values: NSSet)

}

// MARK: Generated accessors for medicine
extension Health {

    @objc(addMedicineObject:)
    @NSManaged public func addToMedicine(_ value: Medicine)

    @objc(removeMedicineObject:)
    @NSManaged public func removeFromMedicine(_ value: Medicine)

    @objc(addMedicine:)
    @NSManaged public func addToMedicine(_ values: NSSet)

    @objc(removeMedicine:)
    @NSManaged public func removeFromMedicine(_ values: NSSet)

}
