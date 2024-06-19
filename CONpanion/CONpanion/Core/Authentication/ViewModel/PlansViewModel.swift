//
//  PlansViewModel.swift
//  CONpanion
//
//  Created by jake mccarthy on 06/04/2024.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine

// ViewModel for managing plans data:
final class PlansViewModel {
    static let shared = PlansViewModel()
    private init() { }

    @Published var plans = [Plans]()

    let plansRef = Firestore.firestore().collection("plans")

    // Function to get data from Firestore:
    func getData() async throws -> [Plans] {
        let userID = Auth.auth().currentUser?.uid ?? ""
        let snapshot = try await plansRef.whereField("User", isEqualTo: userID).getDocuments()
        var plans: [Plans] = []

        for document in snapshot.documents {
            do {
                let plan = try document.data(as: Plans.self)
                plans.append(plan)
            } catch {
                print(String(describing: error))
            }
        }
        return plans
    }

    // Function to create a new plan:
    func newPlan(name: String, user: String, exercises: [ExercisesArray]) async throws -> String {
        do {
            let documentRef = try plansRef.addDocument(from: Plans(name: name, user: user, exercises: exercises))
            return documentRef.documentID
        } catch {
            throw error
        }
    }

    // Function to delete an existing plan:
    func deletePlan(planToDelete: Plans) async throws {
        guard let documentID = planToDelete.id else {
            print("Error: Document ID is nil")
            return
        }

        try await plansRef.document(documentID).delete()
        self.plans.removeAll { $0.id == planToDelete.id }
    }

    // Function to update an existing plan:
    func updatePlan(planToUpdate: Plans, newData: [String: Any]) async throws {
        guard let documentID = planToUpdate.id else {
            print("Error: Document ID is nil")
            return
        }

        try await plansRef.document(documentID).setData(newData, merge: true)
    }

    // Function to save a new plan:
    func savePlan(planName: String, selectedExercises: [Exercises], sets: [SetsArray]) async throws {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            print("Error: Current user ID not found")
            return
        }
        
        var exercisesArray: [ExercisesArray] = []

        for exercise in selectedExercises {
            let exerciseName = exercise.Name
            let exerciseArray = ExercisesArray(exerciseName: exerciseName, sets: sets)
            exercisesArray.append(exerciseArray)
        }

        try await newPlan(name: planName, user: currentUserID, exercises: exercisesArray)
    }
    
    // Function to update the local plan data:
    func updateLocalPlan(planId: String, updatedExercises: [ExercisesArray]) {
        if let index = self.plans.firstIndex(where: { $0.id == planId }) {
            self.plans[index].exercises = updatedExercises
        }
    }
}
