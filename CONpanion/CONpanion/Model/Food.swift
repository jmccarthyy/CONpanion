//
//  Food.swift
//  CONpanion
//
//  Created by jake mccarthy on 13/05/2024.
//

import Foundation
import FirebaseFirestore

// Data model for getting Food:
struct Food: Identifiable, Codable {
    @DocumentID var id: String?
    let name: String
    let calories: Int
    let protein: Double
    let carbs: Double
    let fat: Double
}
