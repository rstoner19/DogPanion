//
//  Medicine+CoreDataClass.swift
//  DogPanion
//
//  Created by Rick Stoner on 7/26/17.
//  Copyright © 2017 Rick Stoner. All rights reserved.
//
//

import Foundation
import CoreData


public class Medicine: NSManagedObject {
    
    func getNotificationsIDs() -> [String] {
        var identifiers: [String] = []
        if let identifier = self.notificationID {
            identifiers.append(identifier)
        }
        if let identifier = self.notificationIDTwo {
            identifiers.append(identifier)
        }
        if let identifier = self.notificationIDThree {
            identifiers.append(identifier)
        }
        if let identifier = self.notificationIDFour {
               identifiers.append(identifier)
        }
        return identifiers
    }

}
