//
//  GoalCaloriesView.swift
//  CONpanion
//
//  Created by jake mccarthy on 26/05/2024.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestoreSwift


// View that displays user's current remaining calories based on goal - consumption + burned amount:
struct TodayIntakeView: View {
    @ObservedObject var viewModel: CaloriesViewModel
    @State private var goalCalories: Int = 0 // State variable to hold goal calories:

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Today's Calories:")
                .font(.headline)
                .bold()
            HStack(spacing: 8) {
                
                // Displaying user's relevant calorie values:
                caloriesComponent(title: "Goal Calories", value: goalCalories, color: .green)
                Text("-")
                    .font(.headline)
                caloriesComponent(title: "Today's Food Consumed", value: viewModel.currentCalories, color: .blue)
                Text("+")
                    .font(.headline)
                caloriesComponent(title: "Calories Burned Today", value: viewModel.caloriesBurned, color: .orange)
                Text("=")
                    .font(.headline)
                caloriesComponent(title: "Calories Remaining", value: caloriesRemaining, color: .purple)
            }
            .frame(maxWidth: .infinity)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(10)
        .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
        .onAppear {
            Task {
                if let goalCalories = await viewModel.fetchGoalCalories() {
                    self.goalCalories = goalCalories
                }
                await viewModel.fetchTodayWorkoutCalories()
            }
        }
    }
    
    private var caloriesRemaining: Int {
        goalCalories - viewModel.currentCalories + viewModel.caloriesBurned
    }
    
    @ViewBuilder
    func caloriesComponent(title: String, value: Int, color: Color) -> some View {
        VStack(alignment: .center, spacing: 4) {
            Text("\(value)")
                .font(.title2)
                .bold()
                .foregroundColor(color)
            Text(title)
                .font(.footnote)
                .bold()
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.center)
                .lineLimit(nil)
                .allowsTightening(false)  // Prevent word breaking with hyphens:
        }
        .frame(minWidth: 60, maxWidth: .infinity)
    }
}
