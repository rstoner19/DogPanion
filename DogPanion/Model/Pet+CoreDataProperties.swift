//
//  Pet+CoreDataProperties.swift
//  DogPanion
//
//  Created by Rick Stoner on 7/10/17.
//  Copyright © 2017 Rick Stoner. All rights reserved.
//
//

import Foundation
import CoreData


extension Pet {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Pet> {
        return NSFetchRequest<Pet>(entityName: "Pet")
    }

    @NSManaged public var breed: String?
    @NSManaged public var name: String?
    @NSManaged public var images: NSSet?

}

// MARK: Generated accessors for images
extension Pet {

    @objc(addImagesObject:)
    @NSManaged public func addToImages(_ value: PetImages)

    @objc(removeImagesObject:)
    @NSManaged public func removeFromImages(_ value: PetImages)

    @objc(addImages:)
    @NSManaged public func addToImages(_ values: NSSet)

    @objc(removeImages:)
    @NSManaged public func removeFromImages(_ values: NSSet)

}
