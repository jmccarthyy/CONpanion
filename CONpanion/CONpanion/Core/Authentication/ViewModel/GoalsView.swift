//
//  GoalsView.swift
//  CONpanion
//
//  Created by jake mccarthy on 12/05/2024.
//

import SwiftUI
import Firebase
import FirebaseFirestore

struct GoalsView: View {
    @StateObject private var viewModel = GoalsViewModel() // State object to manage the GoalsViewModel
    @State private var selectedGoal = "Maintain Weight" // State to manage the selected goal
    @State private var currentWeight: String = "Loading..." // State to manage the current weight
    let goals = ["Maintain Weight", "Bulk / Build muscle", "Cut / Lose fat"] // Available fitness goals

    var body: some View {
        NavigationView {
            Form {
                // Section to display the user's current weight:
                Section(header: Text("Your Current Weight")) {
                    Text("\(currentWeight) kg")
                        .onAppear {
                            // Fetch current weight when the view appears:
                            viewModel.fetchCurrentWeight { weight in
                                if let weight = weight {
                                    currentWeight = weight
                                } else {
                                    currentWeight = "No weight data"
                                }
                            }
                            // Fetch or create goals when the view appears:
                            viewModel.fetchOrCreateGoals { goal, goalCalories in
                                if let goal = goal {
                                    selectedGoal = goal
                                }
                            }
                            // Fetch user details when the view appears:
                            viewModel.fetchUserDetails { _ in }
                        }
                }
                
                // Section to select the user's fitness goal:
                Section(header: Text("Select Your Fitness Goal")) {
                    Picker("Goal", selection: $selectedGoal) {
                        ForEach(goals, id: \.self) { goal in
                            Text(goal)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .onChange(of: selectedGoal) { newGoal in
                        // Update the fitness goal when it changes:
                        viewModel.updateGoal(fitnessGoal: newGoal) { success, message in
                            // Removed alert presentation:
                        }
                    }
                }

                // Section to display the goal calories:
                Section(header: Text("Goal Calories")) {
                    Text(goalCaloriesText)
                }
                
                // Section to display the calorie requirement based on user data:
                if let maintenanceCalories = viewModel.maintenanceCalories {
                    Section(header: Text("Calorie Requirement")) {
                        VStack(alignment: .leading) {
                            Text("Based on your data, you need at least ")
                                + Text("\(maintenanceCalories)").bold()
                                + Text(" calories a day.")
                            
                            Text(calorieText(for: selectedGoal, baseCalories: maintenanceCalories)).bold()
                        }
                    }
                } else {
                    Section(header: Text("Calorie Requirement")) {
                        Text("Loading calorie information...")
                    }
                }
            }
            .navigationTitle("Your Goals")
        }
    }

    // Function to generate calorie requirement text based on selected goal and base calories:
    private func calorieText(for goal: String, baseCalories: Int) -> String {
        let adjustedCalories: Int
        let calorieText: String

        switch goal {
        case "Bulk / Build muscle":
            adjustedCalories = baseCalories + 400
            calorieText = "To build muscle you need to eat \(adjustedCalories) calories"
        case "Cut / Lose fat":
            adjustedCalories = Int(Double(baseCalories) * 0.85)
            calorieText = "For a healthy cut you need to eat \(adjustedCalories) calories"
        case "Maintain Weight":
            adjustedCalories = baseCalories
            calorieText = "To maintain your weight you need to eat \(adjustedCalories) calories"
        default:
            adjustedCalories = baseCalories
            calorieText = ""
        }
        return calorieText
    }

    // Computed property to generate text for goal calories:
    private var goalCaloriesText: String {
        switch selectedGoal {
        case "Bulk / Build muscle":
            return "In order to build muscle, I would recommend a lean bulk which means you need to be in a surplus of around 400 calories per day!"
        case "Cut / Lose fat":
            return "In order to lose weight, you need to cut weight! A healthy way to do this is to be in a calorie deficit of around 300 calories per day!"
        case "Maintain Weight":
            return "To maintain your current weight, you need to consume your daily maintenance calories."
        default:
            return ""
        }
    }
}
