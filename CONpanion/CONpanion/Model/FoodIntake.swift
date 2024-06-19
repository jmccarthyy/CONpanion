//
//  FoodIntake.swift
//  CONpanion
//
//  Created by jake mccarthy on 13/05/2024.
//

import Foundation
import FirebaseFirestore

// Data model for saving FoodIntake:
struct FoodIntake: Identifiable, Codable {
    @DocumentID var id: String?
    var date: Date
    var userId: String
    var food: [FoodArray]?
}

enum MealType: String, Codable, CaseIterable, Identifiable {
    case breakfast = "Breakfast"
    case lunch = "Lunch"
    case dinner = "Dinner"
    case other = "Other food"
    
    var id: String { self.rawValue }
}

// Array for Food Selections (Extension of FoodIntake):
struct FoodArray: Codable {
    var selectionId: String
    var weight: Double //was amount
    var foodId: String
    var mealType: MealType
}
