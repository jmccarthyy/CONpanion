//
//  GoalsViewModel.swift
//  CONpanion
//
//  Created by jake mccarthy on 12/05/2024.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

class GoalsViewModel: ObservableObject {
    // Published properties to manage user, maintenance calories, and fitness goal:
    @Published var currentUser: User?
    @Published var maintenanceCalories: Int?
    @Published var fitnessGoal: String?
    private var db = Firestore.firestore()
    
    init() {
        // Observe user details update notifications:
        NotificationCenter.default.addObserver(self, selector: #selector(userDetailsUpdated), name: .userDetailsUpdated, object: nil)
    }
    
    deinit {
        // Remove observer on deinitialization:
        NotificationCenter.default.removeObserver(self, name: .userDetailsUpdated, object: nil)
    }
    
    @objc private func userDetailsUpdated() {
        // Fetch user details when notified:
        fetchUserDetails { user in
            if let user = user {
                // Recalculate maintenance calories and fetch goals when user details update:
                self.calculateMaintenanceCalories()
                self.fetchOrCreateGoals { goal, goalCalories in
                    self.fitnessGoal = goal
                    self.updateGoalCalories(for: goal ?? "Maintain Weight") { _ in }
                }
            }
        }
    }
    
    // Function to fetch the current weight from Firestore:
    func fetchCurrentWeight(completion: @escaping (String?) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion("User not authenticated")
            return
        }
        
        let userRef = db.collection("users").document(userId)
        userRef.getDocument { document, error in
            if let error = error {
                print("Error fetching user document: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let document = document, document.exists else {
                print("User document does not exist")
                completion(nil)
                return
            }
            
            guard let data = document.data() else {
                print("No data found in user document")
                completion(nil)
                return
            }
            
            if let weightKG = data["weightKG"] as? Int {
                completion(String(weightKG))
            } else {
                print("weightKG field is missing or is not an Int")
                completion(nil)
            }
        }
    }
    
    // Function to fetch or create the goals document:
    func fetchOrCreateGoals(completion: @escaping (String?, Int?) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(nil, nil)
            return
        }
        
        let goalsRef = db.collection("goals").document(userId)
        goalsRef.getDocument { document, error in
            if let error = error {
                print("Error fetching goals document: \(error.localizedDescription)")
                completion(nil, nil)
                return
            }
            
            if let document = document, document.exists {
                if let data = document.data(), let fitnessGoal = data["fitnessGoal"] as? String, let goalCalories = data["goalCalories"] as? Int {
                    completion(fitnessGoal, goalCalories)
                } else {
                    print("No fitnessGoal or goalCalories found in goals document")
                    completion(nil, nil)
                }
            } else {
                let initialGoal = "Bulk / Build muscle"
                let initialCalories = 2400 // Example initial value, should be calculated
                let goals = Goals(userId: userId, fitnessGoal: initialGoal, goalCalories: initialCalories)
                do {
                    try goalsRef.setData(from: goals) { error in
                        if let error = error {
                            print("Error creating goals document: \(error.localizedDescription)")
                            completion(nil, nil)
                        } else {
                            self.updateGoalCalories(for: initialGoal, completion: { goalCalories in
                                completion(initialGoal, goalCalories)
                            })
                        }
                    }
                } catch let error {
                    print("Error preparing goals for Firestore: \(error.localizedDescription)")
                    completion(nil, nil)
                }
            }
        }
    }
    
    // Function to update the goals document:
    func updateGoal(fitnessGoal: String, completion: @escaping (Bool, String) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(false, "User not authenticated")
            return
        }
        
        let goalsRef = db.collection("goals").document(userId)
        goalsRef.updateData(["fitnessGoal": fitnessGoal]) { error in
            if let error = error {
                print("Error updating goals document: \(error.localizedDescription)")
                completion(false, "Failed to update goal: \(error.localizedDescription)")
            } else {
                print("Goals successfully updated.")
                self.updateGoalCalories(for: fitnessGoal) { _ in
                    completion(true, "Goal updated successfully.")
                }
            }
        }
    }
    
    // Function to fetch user details:
    func fetchUserDetails(completion: @escaping (User?) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users").document(userId).getDocument { (document, error) in
            if let document = document, document.exists {
                do {
                    let user = try document.data(as: User.self)
                    self.currentUser = user
                    self.calculateMaintenanceCalories() // Recalculate maintenance calories when fetching user details:
                    completion(user)
                } catch {
                    print("Error decoding user: \(error.localizedDescription)")
                    completion(nil)
                }
            } else {
                completion(nil)
            }
        }
    }
    
    // Function to calculate maintenance calories based on user details:
    func calculateMaintenanceCalories() {
        guard let user = currentUser,
              let weight = user.weightKG,
              let height = user.heightCM,
              let age = user.age,
              let gender = user.gender,
              let activityLevel = user.activityLevel else {
            maintenanceCalories = nil
            return
        }

        var bmr: Double
        if gender == "Male" {
            bmr = 88.362 + (13.397 * Double(weight)) + (4.799 * Double(height)) - (5.677 * Double(age))
        } else {
            bmr = 447.593 + (9.247 * Double(weight)) + (3.098 * Double(height)) - (4.330 * Double(age))
        }

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

        maintenanceCalories = Int(bmr * activityMultiplier)
    }

    // Function to calculate calories based on user details and fitness goal:
    func calculateCalories(fitnessGoal: String) -> Int? {
        guard let maintenanceCalories = maintenanceCalories else {
            return nil
        }

        let adjustedCalories: Int
        switch fitnessGoal {
        case "Bulk / Build muscle":
            adjustedCalories = maintenanceCalories + 400
        case "Cut / Lose fat":
            adjustedCalories = Int(Double(maintenanceCalories) * 0.85)
        case "Maintain Weight":
            adjustedCalories = maintenanceCalories
        default:
            adjustedCalories = maintenanceCalories
        }

        return adjustedCalories
    }
    
    // Function to update goalCalories in Firestore:
    func updateGoalCalories(for fitnessGoal: String, completion: @escaping (Int?) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(nil)
            return
        }
        
        if let goalCalories = calculateCalories(fitnessGoal: fitnessGoal) {
            let goalsRef = db.collection("goals").document(userId)
            goalsRef.updateData(["goalCalories": goalCalories]) { error in
                if let error = error {
                    print("Error updating goalCalories: \(error.localizedDescription)")
                    completion(nil)
                } else {
                    completion(goalCalories)
                }
            }
        } else {
            completion(nil)
        }
    }
}
