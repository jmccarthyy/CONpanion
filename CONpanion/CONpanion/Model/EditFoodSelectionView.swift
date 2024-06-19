//
//  EditFoodSelectionView.swift
//  CONpanion
//
//  Created by jake mccarthy on 17/05/2024.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestoreSwift

struct EditFoodSelectionView: View {
    @ObservedObject var calsViewModel: CaloriesViewModel
    var food: EditableFood
    var mealType: MealType
    @State private var weight: String
    @State private var showConfirmation: Bool = false
    @State private var errorMessage: String?
    @Environment(\.dismiss) private var dismiss

    init(calsViewModel: CaloriesViewModel, food: EditableFood, mealType: MealType) {
        self.calsViewModel = calsViewModel
        self.food = food
        self.mealType = mealType
        _weight = State(initialValue: "\(food.weight)")
    }

    var body: some View {
        NavigationView {
            VStack {
                TextField("Enter weight in grams", text: $weight)
                    .keyboardType(.numberPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                if let weightAsDouble = Double(weight) {
                    Text("Calories: \(Double(food.weight) * weightAsDouble / 100, specifier: "%.2f") kcal")
                    Group {
                        Text("Protein: \(food.weight * weightAsDouble / 100, specifier: "%.2f") g")
                        Text("Carbs: \(food.weight * weightAsDouble / 100, specifier: "%.2f") g")
                        Text("Fat: \(food.weight * weightAsDouble / 100, specifier: "%.2f") g")
                    }
                    .font(.headline)
                }

                Spacer()

                Button("Update Food") {
                    Task {
                        let today = Date()
                        guard let userId = Auth.auth().currentUser?.uid else {
                            errorMessage = "Unexpected error: User ID is not available."
                            return
                        }

                        do {
                            let weightDouble = Double(weight) ?? food.weight
                            try await calsViewModel.updateFoodIntake(userId: userId, date: today, selectionId: food.selectionId, weight: weightDouble, mealType: mealType)

                            showConfirmation = true
                            dismiss()  // Dismiss the sheet after updating the food
                        } catch {
                            errorMessage = "An unexpected error occurred: \(error.localizedDescription)"
                        }
                    }
                }
                .alert("Food Updated", isPresented: $showConfirmation) {
                    Button("OK", role: .cancel) { }
                } message: {
                    Text("Your daily intake has been updated.")
                }

                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }

                Spacer()
            }
            .padding()
            .navigationTitle("\(food.name) Details")
        }
    }
}

