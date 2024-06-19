//
//  Plans.swift
//  CONpanion
//
//  Created by jake mccarthy on 06/04/2024.
//

import Foundation
import FirebaseFirestoreSwift
import FirebaseFirestore

// Data model for a plan:
struct Plans: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var user: String
    var exercises: [ExercisesArray]?
 
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "Name"
        case user = "User"
        case exercises = "Exercises"
    }
}

// ExercisesArray (extension of Plans data model):
struct ExercisesArray: Codable {
    var exerciseName: String
    var sets: [SetsArray]?
    
    enum CodingKeys: String, CodingKey {
        case exerciseName = "ExerciseName"
        case sets = "Sets"
    }
}

// SetsArray (extension of ExercisesArray):
struct SetsArray: Codable {
    var number: Int
    var reps: String
    var weight: String
    
    enum CodingKeys: String, CodingKey {
        case number = "SetNumber"
        case reps = "Reps"
        case weight = "Weight"
    }
}


