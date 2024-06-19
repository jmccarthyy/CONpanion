//
//  CaloriesView.swift
//  CONpanion
//
//  Created by jake mccarthy on 26/02/2024.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestoreSwift

// View to show all user's selected food:
struct CaloriesView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @EnvironmentObject var calsViewModel: CaloriesViewModel
    @State private var shouldPresentSheet: Bool = false
    @State private var selectedMealType: MealType? = nil

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    
                    // Inclusion of TodayIntakeView component:
                    TodayIntakeView(viewModel: calsViewModel)
                    
                    // Declaration of 4 meal type sections:
                    mealSection("Breakfast", mealType: .breakfast, foods: calsViewModel.breakfasts)
                    mealSection("Lunch", mealType: .lunch, foods: calsViewModel.lunches)
                    mealSection("Dinner", mealType: .dinner, foods: calsViewModel.dinners)
                    mealSection("Other Food", mealType: .other, foods: calsViewModel.otherFoods)
                }
                .navigationBarTitle("Calories", displayMode: .inline)
                .padding()
            }
        }
        .onAppear {
            Task {
                await calsViewModel.fetchTodayMacros()
                await calsViewModel.fetchTodayFoodIntake()
            }
        }
        .sheet(item: $selectedMealType) { mealType in
            FoodListView(calsViewModel: calsViewModel, mealType: mealType)
        }
    }

    @ViewBuilder
    private func mealSection(_ category: String, mealType: MealType, foods: [(String, Double)]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(category)
                .font(.headline)
                .padding(.top)
            
            ForEach(foods.indices, id: \.self) { index in
                let food = foods[index]
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(food.0)
                            .font(.headline)
                            .bold()
                        Text("Weight: \(food.1, specifier: "%.2f") g")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color(UIColor.systemGray6)))
                    .padding(.vertical, 4)
                    
                    Spacer()
                    
                    Button(action: {
                        Task {
                            await calsViewModel.deleteFood(food: food, mealType: mealType)
                        }
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                            .padding()
                            .background(Circle().fill(Color(UIColor.systemGray6)))
                    }
                    .buttonStyle(BorderlessButtonStyle())
                }
            }
            
            Button(action: {
                Task {
                    // Use the current date:
                    let currentDate = Date()
                    // Directly using the user ID as we're sure user is logged in:
                    let currentUserId = Auth.auth().currentUser!.uid
                    
                    do {
                        let macrosDocumentExists = await calsViewModel.doesMacrosDocumentExist(userId: currentUserId, date: currentDate)
                        if (!macrosDocumentExists) {
                            try await calsViewModel.createMacrosDocument(userId: currentUserId, date: currentDate)
                        }
                        
                        let foodIntakeDocumentExists = await calsViewModel.doesFoodIntakeDocumentExist(userId: currentUserId, date: currentDate)
                        if (!foodIntakeDocumentExists) {
                            try await calsViewModel.createIntakeDocument(userId: currentUserId, date: currentDate)
                        }
                        
                        selectedMealType = mealType
                    } catch {
                        print("Error creating documents: \(error.localizedDescription)")
                    }
                }
            }) {
                Label("Add Food For \(category)", systemImage: "plus.circle.fill")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .cornerRadius(10)
            }
            .padding(.bottom)
        }
        .padding(.horizontal)
    }
}
