//
//  DataController.swift
//  VirtualTourist
//
//  Created by Tabassum Tamanna on 2/22/21.
//

import Foundation
import CoreData

// MARK: - Data Controller
class DataController {
    let persistentContainer: NSPersistentContainer
    
    var viewContext:NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    // MARK: - init
    init(modelName: String) {
        persistentContainer = NSPersistentContainer(name: modelName)
    }
    
    // MARK: - Load
    func load (completion: (() -> Void )? = nil) {
        
        persistentContainer.loadPersistentStores{ storeDescription, error in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            completion?()
        }
    }
}
