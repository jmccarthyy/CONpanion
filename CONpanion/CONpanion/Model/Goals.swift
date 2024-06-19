//
//  Goals.swift
//  CONpanion
//
//  Created by jake mccarthy on 12/05/2024.
//

import Foundation
import FirebaseFirestore

// Data model for setting Goals:
struct Goals: Codable, Identifiable {
    @DocumentID var id: String?
    var userId: String
    var fitnessGoal: String
    var goalCalories: Int?
}
