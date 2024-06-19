//
//  LiveWorkoutView.swift
//  CONpanion
//
//  Created by jake mccarthy on 05/04/2024.
//

import SwiftUI
import Firebase
import Combine
import FirebaseAuth
import FirebaseFirestoreSwift

import SwiftUI
import Firebase
import Combine
import FirebaseAuth
import FirebaseFirestoreSwift

struct SelectLiveWorkoutView: View {
    @ObservedObject private var viewModel = UserPlansViewModel()
    @State private var selection: Plans?
    @State private var showSheet = false  // State to control sheet presentation
    @State private var isLoading = true
    @State private var hasError = false
    @State private var errorMessage: String?

    var body: some View {
        VStack {
            if isLoading {
                Text("Loading plans...")
                    .font(.headline)
                    .foregroundColor(.gray)
                    .padding()
            } else if hasError {
                Text("Failed to load plans: \(errorMessage ?? "Unknown error")")
                    .font(.headline)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(10)
                    .padding()
            } else if viewModel.plans.isEmpty {
                Text("You cannot start a workout session without a plan to train with! Go back and create a plan on the ‘Your Plans’ page!")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
            } else {
                NavigationView {
                    VStack {
                        Text("Select a plan to use for your workout")
                            .font(.headline)
                            .padding(.top)

                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(viewModel.plans, id: \.id) { plan in
                                    VStack(alignment: .leading, spacing: 16) {
                                        Text(plan.name)
                                            .font(.title3)
                                            .bold()
                                            .foregroundColor(.primary)
                                            .padding(.bottom, 2)
                                        
                                        Text("Exercises:")
                                            .font(.headline)
                                            .foregroundColor(.secondary)
                                        
                                        if let exercises = plan.exercises {
                                            ForEach(exercises, id: \.exerciseName) { exercise in
                                                VStack(alignment: .leading, spacing: 4) {
                                                    Text(exercise.exerciseName)
                                                        .font(.subheadline)
                                                        .bold()
                                                        .foregroundColor(.primary)
                                                    
                                                    if let sets = exercise.sets {
                                                        VStack(alignment: .leading, spacing: 4) {
                                                            ForEach(sets.indices, id: \.self) { index in
                                                                let set = sets[index]
                                                                HStack {
                                                                    Text("Set \(index + 1):")
                                                                        .font(.caption)
                                                                        .foregroundColor(.secondary)
                                                                    Text("\(set.reps) x \(set.weight)KG")
                                                                        .font(.caption)
                                                                        .foregroundColor(.secondary)
                                                                }
                                                            }
                                                        }
                                                    } else {
                                                        Text("No sets found")
                                                            .font(.caption)
                                                            .foregroundColor(.secondary)
                                                    }
                                                }
                                            }
                                        } else {
                                            Text("No exercises found")
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                        }
                                        
                                        Divider()
                                        
                                        HStack {
                                            Spacer()
                                            Button(action: {
                                                selection = plan
                                            }) {
                                                if selection?.id == plan.id {
                                                    Text("Plan Selected")
                                                        .font(.headline)
                                                        .foregroundColor(.white)
                                                        .padding()
                                                        .frame(maxWidth: .infinity)
                                                        .background(Color.green)
                                                        .cornerRadius(10)
                                                } else {
                                                    Text("Select Plan")
                                                        .font(.headline)
                                                        .foregroundColor(.white)
                                                        .padding()
                                                        .frame(maxWidth: .infinity)
                                                        .background(selection == nil ? Color.blue : Color.gray)
                                                        .cornerRadius(10)
                                                }
                                            }
                                            Spacer()
                                        }
                                    }
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                                            .fill(Color(UIColor.secondarySystemBackground))
                                            .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
                                    )
                                    .padding(.horizontal)
                                }
                            }
                            .padding(.vertical)
                        }
                        
                        Spacer()
                        
                        if selection != nil {
                            Button(action: {
                                showSheet = true
                            }) {
                                Text("Train with Selected Plan")
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.green)
                                    .cornerRadius(10)
                                    .padding(.horizontal)
                            }
                            .transition(.slide)
                        }
                    }
                    .navigationBarTitle("Live Workout", displayMode: .inline)
                    .padding(.bottom)
                }
                .sheet(isPresented: $showSheet) {
                    if let selectedPlan = selection {
                        LiveWorkoutView(plan: selectedPlan)
                    }
                }
            }
        }
        .task {
            do {
                try await viewModel.getData()
                isLoading = false
            } catch {
                hasError = true
                errorMessage = error.localizedDescription
            }
        }
    }
}

struct LiveWorkoutView: View {
    var plan: Plans
    @ObservedObject var viewModel = LiveWorkoutViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var showRestTimePicker = true  // Show picker initially
    @State private var defaultRestTimeSelection = 60

    var body: some View {
        NavigationView {
            VStack {
                SessionTimerView(viewModel: viewModel)  // Add the session timer view
                
                Spacer()
                
                if showRestTimePicker {
                    VStack(spacing: 20) {
                        Text("Select Default Rest Time")

                        Picker("Rest Time", selection: $defaultRestTimeSelection) {
                            ForEach([30, 45, 60, 90, 120], id: \.self) { time in
                                Text("\(time) seconds")
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())

                        Button("Start Workout") {
                            viewModel.setDefaultRestTime(defaultRestTimeSelection)
                            viewModel.fetchUserWeight { weight in
                                if let weight = weight {
                                    viewModel.userWeight = weight
                                    viewModel.startWorkout(with: plan)
                                    showRestTimePicker = false
                                } else {
                                    print("Failed to fetch user weight.")
                                }
                            }
                        }
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                } else {
                    if viewModel.isRestTime {
                        VStack(spacing: 20) {
                            TimerCircleView(timeRemaining: viewModel.restTimeRemaining, initialTime: viewModel.restTimeRemainingInitial)

                            HStack(spacing: 10) {
                                Button("-10s") {
                                    viewModel.decreaseRestTime(by: 10)
                                }
                                .padding()
                                .background(viewModel.restTimeRemaining < 10 ? Color.gray : Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .disabled(viewModel.restTimeRemaining < 10)

                                Button("Skip Rest") {
                                    viewModel.skipRest()
                                }
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)

                                Button("+10s") {
                                    viewModel.increaseRestTime(by: 10)
                                }
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            }
                        }
                    } else if let currentExercise = viewModel.planExercises[safe: viewModel.currentExerciseIndex],
                              let currentSet = currentExercise.sets?[safe: viewModel.currentSetIndex] {
                        VStack(spacing: 20) {
                            Text("Exercise: \(currentExercise.exerciseName)")
                            Text("Set \(viewModel.currentSetIndex + 1) of \(currentExercise.sets?.count ?? 1):")

                            // Show previously completed sets for the current exercise
                            if let previousSets = viewModel.exerciseSets[currentExercise.exerciseName], !previousSets.isEmpty {
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("Previously Completed Sets:")
                                        .font(.headline)
                                    ForEach(previousSets, id: \.number) { set in
                                        Text("Set \(set.number): \(set.reps) reps @ \(set.weight) KG")
                                    }
                                }
                                .padding()
                                .background(Color(UIColor.systemGray6))
                                .cornerRadius(10)
                            }

                            // Inputs for the current set
                            HStack {
                                TextField("Weight - last time you put up \(currentSet.weight) KG", text: $viewModel.userInputWeight)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .frame(width: 100)
                                Text("X")
                                TextField("Reps - last time you got \(currentSet.reps)", text: $viewModel.userInputReps)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .frame(width: 50)
                            }

                            if viewModel.isLastSet() && viewModel.isLastExercise() {
                                Button("Finish Workout") {
                                    viewModel.markWorkoutAsComplete()
                                    dismiss()
                                }
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            } else {
                                Button("Set Complete") {
                                    viewModel.completeSet()
                                }
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            }
                        }
                    } else {
                        Text("Workout Complete")
                    }
                }
            }
            .navigationTitle("Live Workout")
            .navigationBarItems(leading: Button("Quit") {
                dismiss()
            })
        }
    }
}

struct SessionTimerView: View {
    @ObservedObject var viewModel: LiveWorkoutViewModel

    var body: some View {
        HStack {
            Text("Session Time: \(timeString(viewModel.sessionTime))")
                .font(.headline)
                .padding(.leading)
            Spacer()
        }
    }

    private func timeString(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let seconds = seconds % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}


extension Collection where Indices.Iterator.Element == Index {
    subscript (safe index: Index) -> Iterator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
