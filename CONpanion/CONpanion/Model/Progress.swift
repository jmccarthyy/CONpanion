//
//  Progress.swift
//  CONpanion
//
//  Created by jake mccarthy on 11/05/2024.
//

import Foundation
import FirebaseFirestoreSwift
import FirebaseFirestore

// Data model for Progress tracking:
struct Progress: Identifiable, Codable, Equatable {
    @DocumentID var id: String?
    var pictureURL: String
    var currentWeight: String
    var timestamp: Date
    var userId: String
    
    // Implement Equatable:
    static func ==(lhs: Progress, rhs: Progress) -> Bool {
        return lhs.id == rhs.id && lhs.currentWeight == rhs.currentWeight && lhs.pictureURL == rhs.pictureURL
    }
}

