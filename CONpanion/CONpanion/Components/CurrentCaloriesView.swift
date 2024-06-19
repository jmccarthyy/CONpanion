//
//  CurrentCaloriesView.swift
//  CONpanion
//
//  Created by jake mccarthy on 10/05/2024.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestoreSwift

// View that displays user's current macros based on food eaten today:
struct CurrentCaloriesView: View {
    @ObservedObject var viewModel: CaloriesViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Your macros so far today:")
                    .font(.headline)
                    .bold()
                HStack {
                    // Displaying data for each value:
                    macroComponent(title: "Calories", value: viewModel.currentCalories, unit: "kcal", color: .green)
                    Spacer()
                    macroComponent(title: "Protein", value: viewModel.currentProtein, unit: "g", color: .blue)
                    Spacer()
                    macroComponent(title: "Carbs", value: viewModel.currentCarbs, unit: "g", color: .orange)
                    Spacer()
                    macroComponent(title: "Fat", value: viewModel.currentFat, unit: "g", color: .red)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(10)
            .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
        }
        .onAppear {
            Task {
                await viewModel.fetchTodayMacros()
            }
        }
    }
    
    @ViewBuilder
    func macroComponent(title: String, value: Int, unit: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("\(title):")
                .font(.subheadline)
                .bold()
            Text("\(value) \(unit)")
                .font(.title)
                .bold()
                .foregroundColor(color)
        }
    }
}
