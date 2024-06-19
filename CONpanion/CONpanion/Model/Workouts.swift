//
//  Workouts.swift
//  CONpanion
//
//  Created by jake mccarthy on 07/05/2024.
//

import Foundation
import FirebaseFirestoreSwift
import FirebaseFirestore

// Data model for a workout:
struct Workouts: Identifiable, Codable {
    @DocumentID var id: String?
    var plan: String
    var user: String
    var exercises: [WorkoutExercisesArray]?
 
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case plan = "Plan"
        case user = "User"
        case exercises = "Exercises"
    }
}

// Data model for an array of workout exercises:
struct WorkoutExercisesArray: Codable {
    var exerciseName: String
    var sets: [WorkoutSetsArray]?
    
    enum CodingKeys: String, CodingKey {
        case exerciseName = "ExerciseName"
        case sets = "Sets"
    }
}

// Data model for an array of workout sets:
struct WorkoutSetsArray: Codable {
    var number: Int
    var reps: String
    var weight: String
    
    enum CodingKeys: String, CodingKey {
        case number = "SetNumber"
        case reps = "Reps"
        case weight = "Weight"
    }
}


