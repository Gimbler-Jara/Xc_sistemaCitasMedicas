//
//  CoreDataStack.swift
//  SistemaCitasMedicas
//
//  Created by Emerson Jara Gamarra on 17/08/25.
//

import UIKit

import CoreData

final class CoreDataStack {
    static let shared = CoreDataStack()
    private init() {}

    lazy var container: NSPersistentContainer = {
        let c = NSPersistentContainer(name: "SistemaCitasMedicas")
        c.loadPersistentStores { _, error in
            if let error = error { fatalError("CD load error: \(error)") }
        }
        return c
    }()

    var viewContext: NSManagedObjectContext { container.viewContext }

    func saveIfNeeded() {
        let ctx = viewContext
        if ctx.hasChanges {
            do { try ctx.save() } catch { print("CD save error:", error) }
        }
    }
}
