//
//  FoodItem.swift
//  CONpanion
//
//  Created by jake mccarthy on 29/05/2024.
//

import SwiftUI

struct EditableFood: Identifiable {
    let id = UUID()
    let selectionId: String
    let name: String
    let weight: Double
    let mealType: MealType
}

