//
//  FoodView.swift
//  CONpanion
//
//  Created by jake mccarthy on 14/05/2024.
//
import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestoreSwift

// View to show the list of foods from the Firestore database:
struct FoodListView: View {
    @ObservedObject var calsViewModel: CaloriesViewModel
    @ObservedObject var foodViewModel = FoodViewModel() // Consider passing this as a parameter:
    @Environment(\.dismiss) private var dismiss
    @Environment(\.presentationMode) var presentationMode

    @State private var searchText: String = "" // State for search text:
    var mealType: MealType

    var body: some View {
        NavigationView {
            VStack {
                // Search bar:
                TextField("Search for food", text: $searchText)
                    .padding(7)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .padding(.horizontal, 10)

                List(filteredFoods) { food in
                    NavigationLink(destination: FoodDetailView(calsViewModel: calsViewModel, food: food, mealType: mealType)) {
                        Text(food.name)
                    }
                }
                .navigationTitle("Select Food")
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                }
                .onAppear {
                    foodViewModel.fetchFoods()
                }
            }
        }
    }
    
    private var filteredFoods: [Food] {
        if searchText.isEmpty {
            return foodViewModel.foods
        } else {
            return foodViewModel.foods.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
    }
}

// View so user can enter how much of the selected food they had:
struct FoodDetailView: View {
    @ObservedObject var calsViewModel: CaloriesViewModel
    var food: Food
    var mealType: MealType
    @State private var weight: String = "100"
    @State private var showConfirmation: Bool = false
    @State private var errorMessage: String?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack {
            TextField("Enter weight in grams", text: $weight)
                .keyboardType(.numberPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            if let weightAsDouble = Double(weight) {
                Text("Calories: \(Double(food.calories) * weightAsDouble / 100, specifier: "%.2f") kcal")
                Group {
                    Text("Protein: \(food.protein * weightAsDouble / 100, specifier: "%.2f") g")
                    Text("Carbs: \(food.carbs * weightAsDouble / 100, specifier: "%.2f") g")
                    Text("Fat: \(food.fat * weightAsDouble / 100, specifier: "%.2f") g")
                }
                .font(.headline)
            }

            Spacer()

            Button("Add Food") {
                Task {
                    let today = Date()
                    guard let userId = Auth.auth().currentUser?.uid else {
                        errorMessage = "Unexpected error: User ID is not available."
                        return
                    }

                    do {
                        let weightDouble = Double(weight) ?? 100
                        print("Adding food with weight: \(weightDouble)") // Debug log:
                        try await calsViewModel.addFoodIntakeAndUpdateMacros(userId: userId, date: today, food: food, weight: weightDouble, mealType: mealType)

                        showConfirmation = true
                        dismiss()  // Dismiss the sheet after adding the food:
                    } catch {
                        errorMessage = "An unexpected error occurred: \(error.localizedDescription)"
                    }
                }
            }
            .alert("Food Added", isPresented: $showConfirmation) {
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
