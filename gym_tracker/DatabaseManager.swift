import SQLite
import Foundation

class DatabaseManager {
    static let shared = DatabaseManager()
    
    let db: Connection?
    
    // Table definition
    let bodyPartsTable = Table("BodyParts")
    
    // Column definitions
    let bodyPartID = SQLite.Expression<Int64>("BodyPartID") // Use SQLite.Expression
    let bodyPart = SQLite.Expression<String>("BodyPart")   // Use SQLite.Expression
    
    private init() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let databaseURL = documentsDirectory.appendingPathComponent("gym_tracker.sqlite3")
        do {
            db = try Connection(databaseURL.path)
            createTables()
        } catch {
            db = nil
            print("Unable to open database: \(error)")
        }
    }
    
    private func createTables() {
        do {
            try db?.run(bodyPartsTable.create(ifNotExists: true) { table in
                table.column(bodyPartID, primaryKey: true) // Primary key
                table.column(bodyPart)                    // Text column
            })
            print("BodyParts table created or already exists.")
        } catch {
            print("Error creating BodyParts table: \(error)")
        }
    }
    
    func insertBodyParts() {
        let bodyParts = [
            (1, "Chest"),
            (2, "Biceps"),
            (3, "Shoulders"),
            (4, "Traps"),
            (5, "Forearms"),
            (6, "Quads"),
            (7, "Abs"),
            (8, "Oblique"),
            (9, "Leg"),
            (10, "Lats"),
            (11, "Upper Back"),
            (12, "Lower Back"),
            (13, "Traps"),
            (14, "Triceps"),
            (16, "Glutes"),
            (17, "Hamstring"),
            (18, "Calves")
        ]
        
        do {
            for part in bodyParts {
                // Check if the body part already exists in the table
                let existingBodyPart = bodyPartsTable.filter(bodyPartID == Int64(part.0))
                if try db?.pluck(existingBodyPart) == nil {
                    // If it doesn't exist, insert the new record
                    try db?.run(bodyPartsTable.insert(
                        bodyPartID <- Int64(part.0),
                        bodyPart <- part.1
                    ))
                } else {
                    // Optionally, print a message or handle the case where the body part exists
                    print("Body part with ID \(part.0) already exists.")
                }
            }
            print("Body parts inserted successfully.")
        } catch {
            print("Error inserting body parts: \(error)")
        }
    }

    func fetchAllBodyParts() -> [(Int64, String)] {
        var bodyPartsList = [(Int64, String)]()
        
        do {
            for element in try db!.prepare(bodyPartsTable) {
                let id = element[bodyPartID]
                let name = element[bodyPart]
                bodyPartsList.append((id, name))
            }
            print("Fetched all body parts.")
        } catch {
            print("Error fetching body parts: \(error)")
        }
        
        return bodyPartsList
    }

}
