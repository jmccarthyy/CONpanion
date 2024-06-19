//
//  Exercises.swift
//  CONpanion
//
//  Created by jake mccarthy on 06/04/2024.
//

import Foundation

// Data model for an exercise:
struct Exercises: Identifiable, Codable, Hashable {
    var id: String
    var Name: String
    var PrimaryMuscle: String
    var SecondaryMuscle: String
    var Compound: Bool
    var Description: String
    var gifURL: String // New property for the GIF URL:
}
