//
//  CaloriesViewModel.swift
//  CONpanion
//
//  Created by jake mccarthy on 10/05/2024.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine

final class CaloriesViewModel: ObservableObject {
    static let shared = CaloriesViewModel()
    public init() { }

    @Published var breakfasts: [(String, Double)] = [] // (foodName, weight):
    @Published var lunches: [(String, Double)] = []
    @Published var dinners: [(String, Double)] = []
    @Published var otherFoods: [(String, Double)] = []

    @Published var currentCalories: Int = 0
    @Published var currentProtein: Int = 0
    @Published var currentCarbs: Int = 0
    @Published var currentFat: Int = 0
    @Published var caloriesBurned: Int = 0 // Calories burned today:

    private var macrosRef = Firestore.firestore().collection("dailyMacros")
    private var foodIntakeRef = Firestore.firestore().collection("foodIntake")
    private var goalsRef = Firestore.firestore().collection("goals")
    
    // Fetch food name by foodId from Firestore:
    private func fetchFoodNameById(_ foodId: String) async -> String? {
        do {
            let document = try await Firestore.firestore().collection("food").document(foodId).getDocument()
            let food = try document.data(as: Food.self)
            return food.name
        } catch {
            print("Error fetching food name for \(foodId): \(error)")
            return nil
        }
    }

    // Fetch foodId by foodName from Firestore:
    private func fetchFoodIdByName(_ foodName: String) async throws -> String {
        do {
            let snapshot = try await Firestore.firestore().collection("food")
                .whereField("name", isEqualTo: foodName)
                .getDocuments()
            
            if let document = snapshot.documents.first {
                return document.documentID
            } else {
                throw NSError(domain: "com.example.app", code: 404, userInfo: [NSLocalizedDescriptionKey: "No matching food found"])
            }
        } catch {
            throw error
        }
    }

    // Fetch goal calories from Firestore:
    func fetchGoalCalories() async -> Int? {
        guard let userId = Auth.auth().currentUser?.uid else {
            return nil
        }

        do {
            let document = try await goalsRef.document(userId).getDocument()
            if let data = document.data(), let goalCalories = data["goalCalories"] as? Int {
                return goalCalories
            } else {
                print("No goalCalories found in goals document")
                return nil
            }
        } catch {
            print("Error fetching goalCalories: \(error.localizedDescription)")
            return nil
        }
    }

    // Fetch calories burned today from Firestore:
    func fetchTodayWorkoutCalories() async {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User not logged in")
            return
        }

        let db = Firestore.firestore()
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!

        do {
            let snapshot = try await db.collection("user_workout_sessions")
                .whereField("User", isEqualTo: userId)
                .whereField("timestamp", isGreaterThanOrEqualTo: startOfDay)
                .whereField("timestamp", isLessThan: endOfDay)
                .getDocuments()

            self.caloriesBurned = snapshot.documents.compactMap { document in
                return document.data()["CaloriesBurned"] as? Int
            }.reduce(0, +)
            
            print("Total Calories Burned Today: \(self.caloriesBurned)")
        } catch {
            print("Error fetching today's workout sessions: \(error)")
        }
    }

    // Create food intake document in Firestore:
    func createIntakeDocument(userId: String, date: Date) async throws -> String {
        let newIntake = FoodIntake(id: nil, date: date, userId: userId, food: [])
        do {
            let documentRef = try await Firestore.firestore().collection("foodIntake").addDocument(from: newIntake)
            return documentRef.documentID
        } catch {
            throw error
        }
    }

    // Update food intake in Firestore:
    func updateFoodIntake(userId: String, date: Date, food: Food, weight: Double, mealType: MealType) async throws {
        let startOfDay = Calendar.current.startOfDay(for: date)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!

        let snapshot = try await Firestore.firestore().collection("foodIntake")
            .whereField("userId", isEqualTo: userId)
            .whereField("date", isGreaterThanOrEqualTo: startOfDay)
            .whereField("date", isLessThanOrEqualTo: endOfDay)
            .getDocuments()

        guard let document = snapshot.documents.first else {
            throw NSError(domain: "com.example.app", code: 404, userInfo: [NSLocalizedDescriptionKey: "No matching document found"])
        }

        let documentID = document.documentID
        let intakeRef = Firestore.firestore().collection("foodIntake").document(documentID)

        let newFoodEntry = [
            "foodId": food.id,
            "weight": weight,
            "mealType": mealType.rawValue
        ] as [String: Any]

        // Add new food entry to the array in the foodIntake document:
        try await intakeRef.updateData([
            "food": FieldValue.arrayUnion([newFoodEntry])
        ])
    }

    // Fetch today's food intake from Firestore:
    func fetchTodayFoodIntake() async {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User not logged in")
            return
        }

        let today = Date()
        let startOfDay = Calendar.current.startOfDay(for: today)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!

        do {
            let snapshot = try await Firestore.firestore().collection("foodIntake")
                .whereField("userId", isEqualTo: userId)
                .whereField("date", isGreaterThanOrEqualTo: startOfDay)
                .whereField("date", isLessThan: endOfDay)
                .getDocuments()

            if let document = snapshot.documents.first {
                let intake = try document.data(as: FoodIntake.self)
                await fetchFoodDetails(for: intake.food ?? [])
            } else {
                print("No food intake recorded for today.")
            }
        } catch {
            print("Error fetching today's food intake: \(error)")
        }
    }

    // Fetch food details for given food array:
    private func fetchFoodDetails(for foodArray: [FoodArray]) async {
        var breakfasts: [(String, Double)] = []
        var lunches: [(String, Double)] = []
        var dinners: [(String, Double)] = []
        var otherFoods: [(String, Double)] = []

        for item in foodArray {
            if let foodName = await fetchFoodNameById(item.foodId) {
                // Debug log for each food item:
                print("Food ID: \(item.foodId), Food Name: \(foodName), Weight: \(item.weight), Meal Type: \(item.mealType), Selection ID: \(item.selectionId ?? "No ID")")

                switch item.mealType {
                case .breakfast:
                    breakfasts.append((foodName, item.weight))
                case .lunch:
                    lunches.append((foodName, item.weight))
                case .dinner:
                    dinners.append((foodName, item.weight))
                case .other:
                    otherFoods.append((foodName, item.weight))
                }
            }
        }

        DispatchQueue.main.async {
            self.breakfasts = breakfasts
            self.lunches = lunches
            self.dinners = dinners
            self.otherFoods = otherFoods

            // Debug logs to confirm state update:
            print("Updated Breakfasts: \(self.breakfasts)")
            print("Updated Lunches: \(self.lunches)")
            print("Updated Dinners: \(self.dinners)")
            print("Updated OtherFoods: \(self.otherFoods)")
        }
    }

    // Check if macros document exists for given user and date:
    func doesMacrosDocumentExist(userId: String, date: Date) async -> Bool {
        let startOfDay = Calendar.current.startOfDay(for: date)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!

        do {
            let snapshot = try await Firestore.firestore().collection("dailyMacros")
                .whereField("userId", isEqualTo: userId)
                .whereField("date", isGreaterThanOrEqualTo: startOfDay)
                .whereField("date", isLessThanOrEqualTo: endOfDay)
                .getDocuments()
            return !snapshot.documents.isEmpty
        } catch {
            print("Error checking dailyMacros document: \(error)")
            return false
        }
    }

    // Check if food intake document exists for given user and date:
    func doesFoodIntakeDocumentExist(userId: String, date: Date) async -> Bool {
        let startOfDay = Calendar.current.startOfDay(for: date)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!

        do {
            let snapshot = try await Firestore.firestore().collection("foodIntake")
                .whereField("userId", isEqualTo: userId)
                .whereField("date", isGreaterThanOrEqualTo: startOfDay)
                .whereField("date", isLessThanOrEqualTo: endOfDay)
                .getDocuments()
            return !snapshot.documents.isEmpty
        } catch {
            print("Error checking foodIntake document: \(error)")
            return false
        }
    }

    // Fetch today's macros from Firestore:
    func fetchTodayMacros() async {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User not logged in")
            return
        }

        let today = Date()
        let startOfDay = Calendar.current.startOfDay(for: today)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!

        do {
            let snapshot = try await macrosRef
                .whereField("userId", isEqualTo: userId)
                .whereField("date", isGreaterThanOrEqualTo: startOfDay)
                .whereField("date", isLessThan: endOfDay)
                .getDocuments()

            if let document = snapshot.documents.first { // Assuming there is only one document for this day:
                let macros = try document.data(as: DailyMacros.self)
                DispatchQueue.main.async {
                    self.currentCalories = macros.calories
                    self.currentProtein = macros.protein
                    self.currentCarbs = macros.carbs
                    self.currentFat = macros.fat
                }
            } else {
                print("No macros recorded for today.")
                resetMacros()
            }
        } catch {
            print("Error fetching today's macros: \(error)")
            resetMacros()
        }
    }

    // Reset macros values:
    private func resetMacros() {
        currentCalories = 0
        currentProtein = 0
        currentCarbs = 0
        currentFat = 0
    }

    // Add food to daily macros in Firestore:
    func addFoodToDailyMacros(for userId: String, date: Date, food: Food, weight: Double) async throws {
        let dailyMacrosRef = macrosRef.document("\(date.formatted(.iso8601))")
        let foodMacros = calculateMacros(for: food, weight: weight)

        do {
            try await dailyMacrosRef.setData(foodMacros, merge: true)
        } catch {
            throw error
        }
    }

    // Add food intake and update macros in Firestore:
    func addFoodIntakeAndUpdateMacros(userId: String, date: Date, food: Food, weight: Double, mealType: MealType) async throws {
        let startOfDay = Calendar.current.startOfDay(for: date)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!

        // Check if food intake document exists:
        let intakeSnapshot = try await Firestore.firestore().collection("foodIntake")
            .whereField("userId", isEqualTo: userId)
            .whereField("date", isGreaterThanOrEqualTo: startOfDay)
            .whereField("date", isLessThanOrEqualTo: endOfDay)
            .getDocuments()

        // Check if there is an existing intake document:
        let intakeDocumentID: String
        if let intakeDocument = intakeSnapshot.documents.first {
            intakeDocumentID = intakeDocument.documentID
        } else {
            // Create a new intake document if not exists:
            intakeDocumentID = try await createIntakeDocument(userId: userId, date: date)
        }
        
        // Insert food array to the new/existing intake document:
        let intakeRef = Firestore.firestore().collection("foodIntake").document(intakeDocumentID)
        let newFoodEntry = [
            "selectionId": UUID().uuidString, // Generate a unique ID for each entry:
            "foodId": food.id,
            "weight": weight,
            "mealType": mealType.rawValue
        ] as [String: Any]

        // Add new food entry to the array in the foodIntake document:
        try await intakeRef.updateData([
            "food": FieldValue.arrayUnion([newFoodEntry])
        ])

        print("Food entry added with weight: \(weight)")

        // Check if daily macros document exists:
        let macrosSnapshot = try await Firestore.firestore().collection("dailyMacros")
            .whereField("userId", isEqualTo: userId)
            .whereField("date", isGreaterThanOrEqualTo: startOfDay)
            .whereField("date", isLessThanOrEqualTo: endOfDay)
            .getDocuments()

        // If Macros Document exists, map the Document ID to a variable called macrosDocumentID:
        let macrosDocumentID: String
        if let macrosDocument = macrosSnapshot.documents.first {
            macrosDocumentID = macrosDocument.documentID
        // Else, create this document with this variable name:
        } else {
            // Create a new macros document if not exists using createMacrosDocument function:
            macrosDocumentID = try await createMacrosDocument(userId: userId, date: date)
        }

        // Create reference to dailyMacros firestore database:
        let macrosRef = Firestore.firestore().collection("dailyMacros").document(macrosDocumentID)

        // Calculate new macros using calculateMacros function:
        let foodMacros = calculateMacros(for: food, weight: weight)

        // Update daily macros depending on food type:
        try await macrosRef.updateData([
            "calories": FieldValue.increment(Int64(foodMacros["calories"]!)),
            "protein": FieldValue.increment(Int64(foodMacros["protein"]!)),
            "carbs": FieldValue.increment(Int64(foodMacros["carbs"]!)),
            "fat": FieldValue.increment(Int64(foodMacros["fat"]!))
        ])

        // Update the corresponding meal array:
        let foodItem = (food.name, weight)
        DispatchQueue.main.async {
            switch mealType {
            case .breakfast:
                self.breakfasts.append(foodItem)
            case .lunch:
                self.lunches.append(foodItem)
            case .dinner:
                self.dinners.append(foodItem)
            case .other:
                self.otherFoods.append(foodItem)
            }
        }

        // Fetch and update today's macros to be used in the CurrentCalories component:
        await fetchTodayMacros()
    }

    // Calculate macros for given food and weight:
    private func calculateMacros(for food: Food, weight: Double) -> [String: Int] {
        let calories = Int((Double(food.calories) * weight / 100).rounded())
        let protein = Int((food.protein * weight / 100).rounded())
        let carbs = Int((food.carbs * weight / 100).rounded())
        let fat = Int((food.fat * weight / 100).rounded())

        return ["calories": calories, "protein": protein, "carbs": carbs, "fat": fat]
    }
    
    // Delete food entry from Firestore:
    func deleteFood(food: (String, Double), mealType: MealType) async {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User not logged in")
            return
        }

        let today = Date()
        let startOfDay = Calendar.current.startOfDay(for: today)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!

        do {
            let snapshot = try await Firestore.firestore().collection("foodIntake")
                .whereField("userId", isEqualTo: userId)
                .whereField("date", isGreaterThanOrEqualTo: startOfDay)
                .whereField("date", isLessThanOrEqualTo: endOfDay)
                .getDocuments()

            if let document = snapshot.documents.first {
                let intakeRef = Firestore.firestore().collection("foodIntake").document(document.documentID)

                // Fetch the foodId:
                let foodId = try await fetchFoodIdByName(food.0)
                let foodEntry = [
                    "foodId": foodId,
                    "weight": food.1,
                    "mealType": mealType.rawValue
                ] as [String: Any]

                // Fetch the current document data:
                var currentFoodArray = document.data()["food"] as? [[String: Any]] ?? []

                // Remove the food entry manually:
                currentFoodArray.removeAll { entry in
                    let entryFoodId = entry["foodId"] as? String
                    let entryWeight = entry["weight"] as? Double
                    let entryMealType = entry["mealType"] as? String
                    return entryFoodId == foodId && entryWeight == food.1 && entryMealType == mealType.rawValue
                }

                // Update the document with the new array:
                try await intakeRef.updateData([
                    "food": currentFoodArray
                ])

                // Fetch the food details:
                let foodDetails = try await Firestore.firestore().collection("food").document(foodId).getDocument(as: Food.self)

                // Calculate the macros to be removed:
                let foodMacros = calculateMacros(for: foodDetails, weight: food.1)

                // Update the daily macros:
                let macrosSnapshot = try await Firestore.firestore().collection("dailyMacros")
                    .whereField("userId", isEqualTo: userId)
                    .whereField("date", isGreaterThanOrEqualTo: startOfDay)
                    .whereField("date", isLessThanOrEqualTo: endOfDay)
                    .getDocuments()

                if let macrosDocument = macrosSnapshot.documents.first {
                    let macrosRef = Firestore.firestore().collection("dailyMacros").document(macrosDocument.documentID)

                    let caloriesToRemove = Int64(-foodMacros["calories"]!)
                    let proteinToRemove = Int64(-foodMacros["protein"]!)
                    let carbsToRemove = Int64(-foodMacros["carbs"]!)
                    let fatToRemove = Int64(-foodMacros["fat"]!)

                    try await macrosRef.updateData([
                        "calories": FieldValue.increment(caloriesToRemove),
                        "protein": FieldValue.increment(proteinToRemove),
                        "carbs": FieldValue.increment(carbsToRemove),
                        "fat": FieldValue.increment(fatToRemove)
                    ])
                }

                // Remove the food from the local state:
                DispatchQueue.main.async {
                    switch mealType {
                    case .breakfast:
                        self.breakfasts.removeAll { $0.0 == food.0 && $0.1 == food.1 }
                    case .lunch:
                        self.lunches.removeAll { $0.0 == food.0 && $0.1 == food.1 }
                    case .dinner:
                        self.dinners.removeAll { $0.0 == food.0 && $0.1 == food.1 }
                    case .other:
                        self.otherFoods.removeAll { $0.0 == food.0 && $0.1 == food.1 }
                    }

                    // Fetch and update today's macros to reflect the deleted food item:
                    Task {
                        await self.fetchTodayMacros()
                    }
                }
            } else {
                print("No food intake document found for today.")
            }
        } catch {
            print("Error deleting food: \(error)")
        }
    }

    // Update macro record in Firestore:
    func updateMacroRecord(macroRecordToUpdate: DailyMacros, newData: [String: Any]) async throws {
        guard let documentID = macroRecordToUpdate.id else {
            print("Error: Document ID is nil")
            return
        }

        try await macrosRef.document(documentID).setData(newData, merge: true)
    }

    // Update daily macros in Firestore:
    func updateDailyMacros(userId: String, date: Date, food: Food, weight: Double) async throws {
        let startOfDay = Calendar.current.startOfDay(for: date)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!

        let snapshot = try await Firestore.firestore().collection("dailyMacros")
            .whereField("userId", isEqualTo: userId)
            .whereField("date", isGreaterThanOrEqualTo: startOfDay)
            .whereField("date", isLessThanOrEqualTo: endOfDay)
            .getDocuments()

        guard let document = snapshot.documents.first else {
            throw NSError(domain: "com.example.app", code: 404, userInfo: [NSLocalizedDescriptionKey: "No matching document found"])
        }

        let documentID = document.documentID
        let macrosRef = Firestore.firestore().collection("dailyMacros").document(documentID)

        let foodMacros = calculateMacros(for: food, weight: weight)

        // Update macros record:
        try await macrosRef.setData(foodMacros, merge: true)
    }

    // Create macros document in Firestore:
    func createMacrosDocument(userId: String, date: Date) async throws -> String {
        let newMacros = DailyMacros(userId: userId, date: date, calories: 0, protein: 0, carbs: 0, fat: 0)
        do {
            let documentRef = try await Firestore.firestore().collection("dailyMacros").addDocument(from: newMacros)
            return documentRef.documentID
        } catch {
            throw error
        }
    }
}








