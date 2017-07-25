//
//  CoreDataManager.swift
//  DogPanion
//
//  Created by Rick Stoner on 7/10/17.
//  Copyright © 2017 Rick Stoner. All rights reserved.
//

import UIKit
import CoreData

class CoreDataManager {
    
    static let shared = CoreDataManager()
    lazy var appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    func fetchPets() -> [Pet]? {
        let context = appDelegate.persistentContainer.viewContext
        let request: NSFetchRequest = Pet.fetchRequest()
        do {
            let results = try context.fetch(request)
            return results
        } catch {
            print("Error fetching cagtegories")
            return nil
        }
    }
    
    func fetchImages(context: NSManagedObjectContext) -> [PetImages]? {
        let request: NSFetchRequest = PetImages.fetchRequest()
        do {
            let results = try context.fetch(request)
            return results
        } catch {
            print("Error fetching cagtegories")
            return nil
        }
    }
    
    func saveItem(context: NSManagedObjectContext, saveItem: String) {
        do {
            try context.save()
        } catch {
            print("Error saving " + saveItem + ". ", error.localizedDescription)
        }
    }
}
