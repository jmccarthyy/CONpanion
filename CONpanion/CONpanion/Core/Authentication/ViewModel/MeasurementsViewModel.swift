//
//  MeasurementsViewModel.swift
//  CONpanion
//
//  Created by jake mccarthy on 19/05/2024.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import FirebaseFirestoreSwift

class MeasurementsViewModel: ObservableObject {
    // Published property to hold user data:
    @Published var user: User?
    
    // Firestore database reference:
    private var db = Firestore.firestore()
    
    init() {
        // Fetch user data on initialization:
        fetchUserData()
    }
    
    // Function to fetch user data from Firestore:
    private func fetchUserData() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users").document(userID).getDocument { [weak self] (document, error) in
            if let document = document, document.exists {
                do {
                    // Decode user data:
                    self?.user = try document.data(as: User.self)
                } catch {
                    print("Error decoding user: \(error.localizedDescription)")
                }
            } else {
                print("User does not exist")
            }
        }
    }
    
    // Function to save edited measurements to Firestore:
    func saveMeasurements(age: String, height: String, gender: String, activityLevel: String) async {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        // Create or update user object with new data:
        var updatedUser = user ?? User(id: userID, fullName: "", email: "", heightCM: nil, weightKG: nil, age: nil, gender: nil, activityLevel: nil)
        
        if let heightCM = Int(height) {
            updatedUser.heightCM = heightCM
        }
        if let ageValue = Int(age) {
            updatedUser.age = ageValue
        }
        updatedUser.gender = gender
        updatedUser.activityLevel = activityLevel
        
        do {
            // Save updated user data to Firestore:
            try await db.collection("users").document(userID).setData(from: updatedUser)
            self.user = updatedUser
            
            // Notify that user details have been updated:
            NotificationCenter.default.post(name: .userDetailsUpdated, object: nil)
        } catch {
            print("Error updating user: \(error.localizedDescription)")
        }
    }
    
    // Function to calculate daily calorie requirement:
    func calculateCalories() -> Int? {
        guard let user = user,
              let weight = user.weightKG,
              let height = user.heightCM,
              let age = user.age,
              let gender = user.gender,
              let activityLevel = user.activityLevel else {
            return nil
        }

        // Calculate Basal Metabolic Rate (BMR) based on gender:
        var bmr: Double
        if gender == "Male" {
            bmr = 88.362 + (13.397 * Double(weight)) + (4.799 * Double(height)) - (5.677 * Double(age))
        } else {
            bmr = 447.593 + (9.247 * Double(weight)) + (3.098 * Double(height)) - (4.330 * Double(age))
        }

        // Determine activity multiplier based on activity level:
        let activityMultiplier: Double
        switch activityLevel {
        case "No Exercise":
            activityMultiplier = 1.2
        case "Light Exercise":
            activityMultiplier = 1.375
        case "Moderate Exercise":
            activityMultiplier = 1.55
        case "Very Active":
            activityMultiplier = 1.725
        default:
            activityMultiplier = 1.2
        }

        // Calculate daily calorie requirement:
        let dailyCalories = bmr * activityMultiplier
        return Int(dailyCalories)
    }
}

// Extension to define a notification name for user details update:
extension Notification.Name {
    static let userDetailsUpdated = Notification.Name("userDetailsUpdated")
}
