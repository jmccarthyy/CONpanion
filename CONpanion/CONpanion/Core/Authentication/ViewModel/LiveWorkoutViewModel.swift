//
//  LiveWorkoutViewModel.swift
//  CONpanion
//
//  Created by jake mccarthy on 07/05/2024.
//

import SwiftUI
import Combine
import Firebase

// ViewModel for managing live workout data:
class LiveWorkoutViewModel: ObservableObject {
    @Published var currentExerciseIndex = 0
    @Published var currentSetIndex = 0
    @Published var isRestTime = false
    @Published var restTimeRemaining: Int = 0
    @Published var restTimeRemainingInitial: Int = 0
    @Published var userInputReps: String = ""
    @Published var userInputWeight: String = ""
    @Published var defaultRestTime: Int = 60  // New default rest time:
    @Published var sessionTime: Int = 0    // Placeholder session time of 1 hour (3600 seconds):
    @Published var caloriesBurned: Int = 0    // Calories burned (as an integer):
    @Published var userWeight: Double = 0     // User weight:

    var planExercises: [ExercisesArray] = []
    var timer: Timer?
    var sessionTimer: Timer?
    var plan: Plans?

    var exerciseSets = [String: [WorkoutSetsArray]]()  // To store completed sets per exercise:
    var completedSets: [WorkoutSetsArray] = []
    var previousSetIndex: Int?

    let metValue: Double = 6.0  // Example MET value for gym session:
    private var db = Firestore.firestore()

    // Start the workout with the specific plan:
    func startWorkout(with plan: Plans) {
        self.plan = plan
        self.planExercises = plan.exercises ?? []
        currentExerciseIndex = 0
        if planExercises.isEmpty {
            print("No exercises available in this plan.")
        } else {
            moveToExercise(at: 0)
        }
        startSessionTimer() // Start the session timer:
    }

    // Start the session timer:
    func startSessionTimer() {
        sessionTimer?.invalidate()  // Stop any existing timer:
        sessionTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.sessionTime += 1
            self?.calculateCaloriesBurned() // Update calories burned every second:
        }
    }

    // Calculate the calories burned:
    func calculateCaloriesBurned() {
        let durationInHours = Double(sessionTime) / 3600.0
        caloriesBurned = Int(round(metValue * userWeight * durationInHours))
        print("Calculated calories burned: \(caloriesBurned), Duration: \(durationInHours) hours, User weight: \(userWeight) kg")
    }

    // Fetch the user's weight from Firestore:
    func fetchUserWeight(completion: @escaping (Double?) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User is not authenticated.")
            completion(nil)
            return
        }
        let userRef = db.collection("users").document(userId)
        userRef.getDocument { document, error in
            if let document = document, document.exists, let data = document.data(), let weightKG = data["weightKG"] as? Double {
                print("Fetched user weight: \(weightKG) kg")
                completion(weightKG)
            } else {
                print("User weight not found: \(error?.localizedDescription ?? "No error information")")
                completion(nil)
            }
        }
    }

    // Move to a specific exercise:
    func moveToExercise(at index: Int) {
        guard index < planExercises.count else {
            print("Attempted to move to an invalid exercise index.")
            return
        }
        currentExerciseIndex = index
        currentSetIndex = 0
        nextSet()
    }

    // Complete the current set:
    func completeSet() {
        guard let sets = planExercises[safe: currentExerciseIndex]?.sets,
              currentSetIndex < sets.count,
              let currentExercise = planExercises[safe: currentExerciseIndex] else {
            print("Failed to fetch current set or exercise")
            return
        }

        if let currentSet = sets[safe: currentSetIndex] {
            let newSet = WorkoutSetsArray(
                number: currentSet.number,
                reps: userInputReps,
                weight: userInputWeight
            )
            // Append the new set to the correct exercise in the dictionary:
            var setsArray = exerciseSets[currentExercise.exerciseName] ?? []
            setsArray.append(newSet)
            exerciseSets[currentExercise.exerciseName] = setsArray

            // Update Firestore with the new set values:
            updatePlanSetInFirestore(exerciseName: currentExercise.exerciseName, set: newSet)

            // Update the local plan data and notify the view models:
            if var updatedExercises = self.plan?.exercises {
                if let exerciseIndex = updatedExercises.firstIndex(where: { $0.exerciseName == currentExercise.exerciseName }) {
                    updatedExercises[exerciseIndex].sets = setsArray.map { SetsArray(number: $0.number, reps: $0.reps, weight: $0.weight) }
                    PlansViewModel.shared.updateLocalPlan(planId: self.plan?.id ?? "", updatedExercises: updatedExercises)
                }
            }

            // Record the index of the current set as the previous set index:
            previousSetIndex = currentSetIndex

            // Start a new rest period using the default rest time:
            isRestTime = true
            restTimeRemaining = defaultRestTime
            restTimeRemainingInitial = defaultRestTime
            startRestTimer()

            // Increment to the next set or exercise only after assigning the rest time:
            incrementSetOrExercise(currentExercise: currentExercise, setsCount: sets.count)
        } else {
            print("No valid set found at currentSetIndex: \(currentSetIndex)")
        }
    }

    // Update the plan set in Firestore:
    func updatePlanSetInFirestore(exerciseName: String, set: WorkoutSetsArray) {
        guard let planId = plan?.id else {
            print("No plan ID available")
            return
        }

        let planRef = db.collection("plans").document(planId)
        
        planRef.getDocument { document, error in
            if let document = document, document.exists {
                if var planData = document.data(),
                   var exercises = planData["Exercises"] as? [[String: Any]] {
                    
                    if let exerciseIndex = exercises.firstIndex(where: { $0["ExerciseName"] as? String == exerciseName }),
                       var sets = exercises[exerciseIndex]["Sets"] as? [[String: Any]] {
                        
                        if let setIndex = sets.firstIndex(where: { $0["SetNumber"] as? Int == set.number }) {
                            sets[setIndex]["Reps"] = set.reps
                            sets[setIndex]["Weight"] = set.weight
                            exercises[exerciseIndex]["Sets"] = sets
                            planData["Exercises"] = exercises

                            planRef.setData(planData, merge: true) { error in
                                if let error = error {
                                    print("Error updating plan set: \(error)")
                                } else {
                                    print("Plan set successfully updated")
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // Save the workout data to Firestore:
    func saveWorkoutToFirestore() {
        guard let plan = self.plan, let planId = plan.id else {
            print("No plan information available.")
            return
        }
        let db = Firestore.firestore()
        let workoutRef = db.collection("user_workout_sessions").document()  // Generate new document ID:

        let totalRestTime = exerciseSets.flatMap { $0.value }.reduce(0) { $0 + (Int($1.reps) ?? 0) } // Example logic, adapt as needed:

        let workoutData: [String: Any] = [
            "Plan": plan.name,
            "User": plan.user,
            "Exercises": organizeDataForSaving()["Exercises"] as Any,
            "SessionTime": sessionTime - totalRestTime,  // Total session time minus rest times:
            "CaloriesBurned": caloriesBurned,            // Include calories burned as an integer:
            "timestamp": FieldValue.serverTimestamp()  // Optionally add timestamp for sorting or querying:
        ]

        workoutRef.setData(workoutData) { error in
            if let error = error {
                print("Error saving workout: \(error)")
            } else {
                print("Workout successfully saved.")
            }
        }
    }

    // Finalize the rest time for the previous set:
    func finalizePreviousSetRestTime() {
        guard let previousSetIndex = previousSetIndex,
              let currentExercise = planExercises[safe: currentExerciseIndex],
              var setsArray = exerciseSets[currentExercise.exerciseName] else {
            print("No valid previous set index or exercise")
            return
        }

        if previousSetIndex < setsArray.count {
            exerciseSets[currentExercise.exerciseName] = setsArray
        } else {
            print("Previous set index out of bounds in the saved sets array")
        }
    }

    // Increment to the next set or exercise:
    func incrementSetOrExercise(currentExercise: ExercisesArray, setsCount: Int) {
        currentSetIndex += 1

        if currentSetIndex >= setsCount {
            currentSetIndex = 0
            currentExerciseIndex += 1

            if currentExerciseIndex >= planExercises.count {
                print("All exercises are completed.")
                currentExerciseIndex = 0  // Reset indices if needed:
            } else {
                moveToExercise(at: currentExerciseIndex)
            }
        } else {
            nextSet()
        }
    }

    // Prepare for the next set:
    func nextSet() {
        guard !isRestTime else { return }  // Skip starting next set if it's rest time:
        guard currentSetIndex < (planExercises[safe: currentExerciseIndex]?.sets?.count ?? 0) else {
            print("Attempted to start a set that does not exist, moving to next exercise")
            currentSetIndex = 0
            currentExerciseIndex += 1
            return
        }
        print("Preparing next set")
        clearUserInputs()
    }

    // Organize the data for saving to Firestore:
    func organizeDataForSaving() -> [String: Any] {
        var exercisesData: [[String: Any]] = []

        for (exerciseName, sets) in exerciseSets {
            let exerciseData: [String: Any] = [
                "ExerciseName": exerciseName,
                "Sets": sets.map { set in
                    [
                        "SetNumber": set.number,
                        "Reps": set.reps,
                        "Weight": set.weight
                    ]
                }
            ]
            exercisesData.append(exerciseData)
        }

        return ["Exercises": exercisesData]
    }

    // Mark the workout as complete:
    func markWorkoutAsComplete() {
        if isLastExercise() && isLastSet() {
            completeSet()  // Ensure last set data is captured:
        }
        sessionTimer?.invalidate() // Stop the session timer:
        saveWorkoutToFirestore()
    }

    // Helper function to clear user inputs after a set is completed:
    func clearUserInputs() {
        userInputReps = ""
        userInputWeight = ""
    }

    // Check if it's the last set:
    func isLastSet() -> Bool {
        guard let sets = planExercises[safe: currentExerciseIndex]?.sets else {
            return false
        }
        return currentSetIndex == (sets.count - 1)
    }

    // Check if it's the last exercise:
    func isLastExercise() -> Bool {
        return currentExerciseIndex == (planExercises.count - 1)
    }

    // Start the rest timer:
    func startRestTimer() {
        timer?.invalidate()  // Stop any existing timer:
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.restTimeRemaining > 0 {
                self.restTimeRemaining -= 1
            } else {
                self.timer?.invalidate()
                self.isRestTime = false
                self.nextSet()
            }
        }
    }

    // Skip the rest period:
    func skipRest() {
        timer?.invalidate()  // Stop the timer:
        isRestTime = false
        restTimeRemaining = 0
        nextSet()  // Immediately move to the next set:
    }

    // Increase the rest time:
    func increaseRestTime(by seconds: Int) {
        restTimeRemaining += seconds
    }

    // Decrease the rest time:
    func decreaseRestTime(by seconds: Int) {
        if restTimeRemaining >= seconds {
            restTimeRemaining -= seconds
        }
    }

    // Set the default rest time:
    func setDefaultRestTime(_ restTime: Int) {
        self.defaultRestTime = restTime
    }
}

