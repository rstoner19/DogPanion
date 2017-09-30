//
//  Health+CoreDataClass.swift
//  DogPanion
//
//  Created by Rick Stoner on 7/21/17.
//  Copyright © 2017 Rick Stoner. All rights reserved.
//
//

import Foundation
import CoreData


public class Health: NSManagedObject {
    
    func deleteNotifications() {
        if let vaccines = self.vaccines?.allObjects as? [Vaccines] {
            for vaccine in vaccines {
                if vaccine.reminder {
                    vaccine.reminder = false
                    NotificationManager.deleteNotication(identifiers: vaccine.getNotificationsIDs())
                }
            }
        }
        if let medicines = self.medicine?.allObjects as? [Medicine] {
            for medicine in medicines {
                if medicine.reminder {
                    medicine.reminder = false
                    NotificationManager.deleteNotication(identifiers: medicine.getNotificationsIDs())
                }
            }
        }
    }

}
