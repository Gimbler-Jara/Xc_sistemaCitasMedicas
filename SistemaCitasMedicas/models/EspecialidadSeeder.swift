

import CoreData

struct EspecialidadSeeder {
    static func seedIfNeeded() {
        
        let ctx = CoreDataStack.shared.viewContext
        let req = NSFetchRequest<NSFetchRequestResult>(entityName: "EspecialidadLocal")
        req.fetchLimit = 1
        
        if let count = try? ctx.count(for: req), count > 0 {
            return
        }

        let items: [(String, String, Int16)] = [
            ("Medicina General", "medicinag", 1),
            ("Pediatría",        "pediatria", 2),
            ("Dermatología",     "dermatologia", 3),
            ("Cardiología",      "cardiologia", 4),
            ("Neurología",       "neurologia", 5),
            ("Ginecología",      "ginecologia", 6),
            ("Traumatología",    "traumatologia", 7),
            ("Oftalmología",     "oftalmologia", 8),
            ("Otorrino",         "otorrinolaringologia", 9)
        ]

        for (nombre, asset, orden) in items {
            let obj = NSEntityDescription.insertNewObject(forEntityName: "EspecialidadLocal", into: ctx)
            obj.setValue(UUID(), forKey: "id")
            obj.setValue(nombre, forKey: "nombre")
            obj.setValue(asset, forKey: "assetName")
            obj.setValue(orden, forKey: "orden")
        }
        do { try ctx.save() } catch { print("Seed error:", error) }
    }
}

