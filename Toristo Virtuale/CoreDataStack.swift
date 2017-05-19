//
//  CoreDataStack.swift
//  Toristo Virtuale
//
//  Created by Petr Stenin on 10/05/2017.
//  Copyright © 2017 Petr Stenin. All rights reserved.
//

import Foundation
import CoreData

struct CoreDataStack {
    
    // MARK: Properties
    // Managed Object Model with its URL
    private let modelURL: URL
    private let touristModel: NSManagedObjectModel
    
    // Store Coordinator
    internal let storeCoordinator: NSPersistentStoreCoordinator
    
    // Contexts
    // Scheme: persistingContext -> mainContext -> backgroundContext
    internal let persistingContext: NSManagedObjectContext
    internal let backgroundContext: NSManagedObjectContext
    let mainContext: NSManagedObjectContext
    
    // Store (URL)
    internal let dbURL: URL
    
    // MARK: Initializers
    // Failable - returns nil if something goes wrong
    init?(modelName: String) {
        
        // The model is in the MAIN bundle - set the modelURL property
        guard let mainBundleModelURL = Bundle.main.url(forResource: modelName, withExtension: Constants.modelExtension) else {
            // TODO: Give alert - unable to find MODEL in the main bundle
            return nil
        }
        modelURL = mainBundleModelURL
        
        // Create a model from the URL
        guard let modelFromURL = NSManagedObjectModel(contentsOf: modelURL) else {
            // TODO: Give alert - unable to create MODEL from the URL
            return nil
        }
        touristModel = modelFromURL
        
        // Create Store Coordinator
        storeCoordinator = NSPersistentStoreCoordinator(managedObjectModel: touristModel)
        
        // Create contexts: persisting (private queue) and main (child of persisting, main queue)
        // Add to coordinator
        persistingContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        persistingContext.persistentStoreCoordinator = storeCoordinator
        mainContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        mainContext.parent = persistingContext
        
        // Create a background context (child of main)
        backgroundContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        backgroundContext.parent = mainContext
        
        // SQLite store (in the Documents folder)
        let fileManager = FileManager.default
        
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            // TODO: Give alert - unable to reach the Documents folder
            return nil
        }
        dbURL = documentsURL.appendingPathComponent(Constants.sqliteStoreName)
        
        // Add persistent store to the coordinator
        do {
            try storeCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: dbURL, options: Constants.optionsForMigration as [NSObject: AnyObject])
        } catch {
            // TODO: Give alert - Unable to add store at 'dbURL'
        }
    }
}

// MARK: Removing Data
internal extension CoreDataStack {
    
    // Empty tables in the database
    func dropAllData() throws {
        try storeCoordinator.destroyPersistentStore(at: dbURL, ofType: NSSQLiteStoreType, options: nil)
        try storeCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: dbURL, options: Constants.optionsForMigration as [NSObject: AnyObject])
    }
}

// MARK: Batch processing in the background
extension CoreDataStack {
    typealias Batch = (_ workerContext: NSManagedObjectContext) -> ()
    
    func performBackgroundBatchOperation(_ batch: @escaping Batch) {
        backgroundContext.perform() {
            batch(self.backgroundContext)
            
            // Save it to the parent context so normal saving can work
            do {
                try self.backgroundContext.save()
            } catch {
                fatalError("Error while saving backgroundContext: \(error)")
            }
        }
    }
    
}

// MARK: Save data
extension CoreDataStack {
    func save() {
        mainContext.performAndWait() {
            if self.mainContext.hasChanges {
                do {
                    try self.mainContext.save()
                } catch {
                    fatalError("Error while saving the main context: \(error)")
                }
                
                // Save in the background
                self.persistingContext.perform() {
                    do {
                        try self.persistingContext.save()
                    } catch {
                        fatalError("Error while saving persisting context: \(error)")
                    }
                }
            }
        }
    }
}
