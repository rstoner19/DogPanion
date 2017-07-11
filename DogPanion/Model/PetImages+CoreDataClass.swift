//
//  PetImages+CoreDataClass.swift
//  DogPanion
//
//  Created by Rick Stoner on 7/11/17.
//  Copyright © 2017 Rick Stoner. All rights reserved.
//
//

import UIKit
import CoreData


public class PetImages: NSManagedObject {
    
    class func orderImagesByDate(images: NSSet) -> [PetImages] {
        var petImages = images.allObjects as! [PetImages]
        petImages.sort(by: { ($0.date).compare(($1.date as Date)) == .orderedDescending })
        return petImages
    }
    
    class func renderImage(imageDate: [PetImages]) -> [UIImage] {
        var images: [UIImage] = []
        for image in imageDate {
            images.append(UIImage(data: image.image as Data)!)
        }
        return images
    }
    
}
