//
//  DailyMacros.swift
//  CONpanion
//
//  Created by jake mccarthy on 14/05/2024.
//

import Foundation
import FirebaseFirestore

// Data model for saving Daily Macros:
struct DailyMacros: Codable, Identifiable {
    @DocumentID var id: String?
    var userId: String
    var date: Date
    var calories: Int
    var protein: Int
    var carbs: Int
    var fat: Int
}
