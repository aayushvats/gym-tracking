import SQLite
import Foundation

class DatabaseManager {
    static let shared = DatabaseManager()
    
    let db: Connection?
    
    // Tables
    let muscles = Table("Muscles")
    let exercises = Table("Exercises")
    let exerciseMuscles = Table("ExerciseMuscles")
    let workoutSessions = Table("WorkoutSessions")
    let workoutLogs = Table("WorkoutLogs")
    
    // Columns
    let id = SQLite.Expression<Int>("id")
    let name = SQLite.Expression<String>("name")
    
    // Exercise Columns
    let exerciseId = SQLite.Expression<Int>("exercise_id")
    let description = SQLite.Expression<String?>("description")
    
    // ExerciseMuscles Columns
    let muscleId = SQLite.Expression<Int>("muscle_id")
    
    // WorkoutSessions Columns
    let workoutDate = SQLite.Expression<Date>("workout_date")
    
    // WorkoutLogs Columns
    let sessionId = SQLite.Expression<Int>("session_id")
    let setNumber = SQLite.Expression<Int>("set_number")
    let reps = SQLite.Expression<Int>("reps")
    let weight = SQLite.Expression<Double>("weight")
    
    private init() {
        do {
            let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
            db = try Connection("\(path)/fitnessDB.sqlite3")
            createTables()
        } catch {
            db = nil
            print("Error initializing database: \(error)")
        }
    }
    
    // MARK: - Create Tables
    private func createTables() {
        do {
            try db?.run(muscles.create(ifNotExists: true) { t in
                t.column(id, primaryKey: true)
                t.column(name, unique: true)
            })
            
            try db?.run(exercises.create(ifNotExists: true) { t in
                t.column(id, primaryKey: .autoincrement)
                t.column(name, unique: true)
                t.column(description)
            })
            
            try db?.run(exerciseMuscles.create(ifNotExists: true) { t in
                t.column(exerciseId)
                t.column(muscleId)
                t.primaryKey(exerciseId, muscleId)
                t.foreignKey(exerciseId, references: exercises, id, delete: .cascade)
                t.foreignKey(muscleId, references: muscles, id, delete: .cascade)
            })
            
            try db?.run(workoutSessions.create(ifNotExists: true) { t in
                t.column(id, primaryKey: .autoincrement)
                t.column(workoutDate)
            })
            
            try db?.run(workoutLogs.create(ifNotExists: true) { t in
                t.column(id, primaryKey: .autoincrement)
                t.column(sessionId)
                t.column(exerciseId)
                t.column(setNumber)
                t.column(reps)
                t.column(weight)
                t.foreignKey(sessionId, references: workoutSessions, id, delete: .cascade)
                t.foreignKey(exerciseId, references: exercises, id, delete: .cascade)
            })
        } catch {
            print("Error creating tables: \(error)")
        }
    }
    
    // MARK: - Insert Functions
    
    func insertMuscle(id: Int, name: String) {
        do {
            try db?.run(muscles.insert(or: .ignore, self.id <- id, self.name <- name))
        } catch {
            print("Error inserting muscle: \(error)")
        }
    }
    
    func insertExercise(name: String, description: String?) -> Int? {
        do {
            let insert = exercises.insert(self.name <- name, self.description <- description)
            let rowId = try db?.run(insert)
            return Int(rowId ?? 0)
        } catch {
            print("Error inserting exercise: \(error)")
            return nil
        }
    }
    
    func linkExerciseToMuscle(exerciseId: Int, muscleId: Int) {
        do {
            try db?.run(exerciseMuscles.insert(self.exerciseId <- exerciseId, self.muscleId <- muscleId))
        } catch {
            print("Error linking exercise to muscle: \(error)")
        }
    }
    
    func insertWorkoutSession(date: Date) -> Int? {
        do {
            let insert = workoutSessions.insert(workoutDate <- date)
            let rowId = try db?.run(insert)
            return Int(rowId ?? 0)
        } catch {
            print("Error inserting workout session: \(error)")
            return nil
        }
    }
    
    func insertWorkoutLog(sessionId: Int, exerciseId: Int, setNumber: Int, reps: Int, weight: Double) {
        do {
            try db?.run(workoutLogs.insert(
                self.sessionId <- sessionId,
                self.exerciseId <- exerciseId,
                self.setNumber <- setNumber,
                self.reps <- reps,
                self.weight <- weight
            ))
        } catch {
            print("Error inserting workout log: \(error)")
        }
    }
    
    // MARK: - Fetch Functions
    
    func getAllMuscles() -> [String] {
        var muscleList: [String] = []
        do {
            for muscle in try db!.prepare(muscles) {
                muscleList.append(muscle[name])
            }
        } catch {
            print("Error fetching muscles: \(error)")
        }
        return muscleList
    }
    
    func getExercises() -> [(id: Int, name: String, description: String?)] {
        var exerciseList: [(Int, String, String?)] = []
        do {
            for exercise in try db!.prepare(exercises) {
                exerciseList.append((exercise[id], exercise[name], exercise[description]))
            }
        } catch {
            print("Error fetching exercises: \(error)")
        }
        return exerciseList
    }
    
    func getExercisesByMuscle(muscleId: Int) -> [String] {
        var exerciseList: [String] = []
        do {
            let query = exercises
                .join(exerciseMuscles, on: exercises[id] == exerciseMuscles[exerciseId])
                .filter(exerciseMuscles[self.muscleId] == muscleId)
            
            for exercise in try db!.prepare(query) {
                exerciseList.append(exercise[name])
            }
        } catch {
            print("Error fetching exercises by muscle: \(error)")
        }
        return exerciseList
    }
    
    func getWorkoutLogsByDate(date: Date) -> [(exercise: String, setNumber: Int, reps: Int, weight: Double)] {
        var logs: [(String, Int, Int, Double)] = []
        do {
            let query = workoutLogs
                .join(workoutSessions, on: workoutLogs[sessionId] == workoutSessions[id])
                .join(exercises, on: workoutLogs[exerciseId] == exercises[id])
                .filter(workoutSessions[workoutDate] == date)
            
            for log in try db!.prepare(query) {
                logs.append((log[exercises[name]], log[setNumber], log[reps], log[weight]))
            }
        } catch {
            print("Error fetching workout logs by date: \(error)")
        }
        return logs
    }
    
    // MARK: - Delete Functions
    
    func deleteExercise(exerciseId: Int) {
        do {
            let exercise = exercises.filter(id == exerciseId)
            try db?.run(exercise.delete())
        } catch {
            print("Error deleting exercise: \(error)")
        }
    }
    
    func deleteWorkoutSession(sessionId: Int) {
        do {
            let session = workoutSessions.filter(id == sessionId)
            try db?.run(session.delete())
        } catch {
            print("Error deleting workout session: \(error)")
        }
    }
}
