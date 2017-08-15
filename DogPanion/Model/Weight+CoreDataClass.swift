//
//  Weight+CoreDataClass.swift
//  DogPanion
//
//  Created by Rick Stoner on 7/21/17.
//  Copyright © 2017 Rick Stoner. All rights reserved.
//
//

import Foundation
import CoreData


public class Weight: NSManagedObject {
    
    class func orderWeightByDate(weights: inout [Weight]) {
        weights.sort(by: { ($0.dateMeasured)?.compare(($1.dateMeasured! as Date)) == .orderedAscending })
    }
    
}
