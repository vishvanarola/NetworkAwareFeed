//
//  CoreDataManager.swift
//  NetworkAwareFeed
//
//  Created by apple on 06/06/25.
//

import Foundation
import UIKit
import CoreData

final class CoreDataManager {
    
    // MARK: - Singleton
    static let shared = CoreDataManager()
    private init() {}
    
    // MARK: - Persistent Container
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "NetworkAwareFeed")
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    // MARK: - Contexts
    var mainContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    func newBackgroundContext() -> NSManagedObjectContext {
        return persistentContainer.newBackgroundContext()
    }
    
    // MARK: - Save Helper
    func saveContext(context: NSManagedObjectContext? = nil) {
        let contextToSave = context ?? mainContext
        if contextToSave.hasChanges {
            do {
                try contextToSave.save()
                print("✅ CoreDataManager: Context saved successfully.")
            } catch {
                print("❌ CoreDataManager: Failed to save context - \(error.localizedDescription)")
            }
        }
    }
}
