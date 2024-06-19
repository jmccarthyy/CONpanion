//
//  User.swift
//  CONpanion
//
//  Created by jake mccarthy on 09/02/2024.
//

import Foundation

// Data model for a user:
struct User: Identifiable, Codable {
    let id: String
    let fullName: String
    let email: String
    var heightCM: Int?
    var weightKG: Int?
    var age: Int?
    var height: Int?
    var gender: String?
    var activityLevel: String?

    // Computed property to get the user's initials:
    var initials: String {
        let formatter = PersonNameComponentsFormatter()
        if let components = formatter.personNameComponents(from: fullName) {
            formatter.style = .abbreviated
            return formatter.string(from: components)
        } else {
            return ""
        }
    }
}
