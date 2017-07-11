//
//  PetImages+CoreDataProperties.swift
//  DogPanion
//
//  Created by Rick Stoner on 7/11/17.
//  Copyright © 2017 Rick Stoner. All rights reserved.
//
//

import Foundation
import CoreData


extension PetImages {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PetImages> {
        return NSFetchRequest<PetImages>(entityName: "PetImages")
    }

    @NSManaged public var date: NSDate
    @NSManaged public var image: NSData
    @NSManaged public var pet: Pet?

}
