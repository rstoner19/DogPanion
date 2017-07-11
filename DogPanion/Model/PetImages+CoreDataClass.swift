//
//  PetImages+CoreDataClass.swift
//  DogPanion
//
//  Created by Rick Stoner on 7/10/17.
//  Copyright © 2017 Rick Stoner. All rights reserved.
//
//

import Foundation
import CoreData


public class PetImages: NSManagedObject {
    
    class func orderImagesByDate(images: NSSet) -> [PetImages] {
        var petImages = images.allObjects as! [PetImages]
        petImages.sort(by: { ($0.date)!.compare(($1.date! as Date)) == .orderedDescending })
        return petImages
    }

}
