//
//  ExercisesView.swift
//  CONpanion
//
//  Created by jake mccarthy on 05/04/2024.
//

import SwiftUI
import Firebase
import FirebaseFirestore

// MARK: ExercisesView:

// View for displaying exercises:
struct ExercisesView: View {
    
    @ObservedObject var model = ExercisesViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 16) {
                    Section{
                        
                        // Iterate over the list of exercises and display each one using ExerciseCardView:
                        ForEach(model.list, id: \.id) { item in
                            ExerciseCardView(exercise: item)
                                .padding(.horizontal)
                                .padding(.top, 8)
                        }
                    }
                }
                .padding(.vertical)
            }
            .background(Color(UIColor.systemBackground)) // White background for the entire view:
            .navigationBarTitle("All Exercises", displayMode: .inline)
            .task {
                model.getData()
            }
        }
    }
}

// MARK: ExerciseCardView:

// View for displaying an exercise card:
struct ExerciseCardView: View {
    let exercise: Exercises
    @State private var showInfoBox = false
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text(exercise.Name)
                        .font(.title3)
                        .bold()
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    // Button to toggle info box visibility:
                    Button(action: {
                        withAnimation {
                            showInfoBox.toggle()
                        }
                    }) {
                        Image(systemName: "info.circle")
                            .foregroundColor(.gray)
                    }
                }
                
                // Detail rows for exercise properties:
                ExerciseDetailRow(label: "Target Muscle Group:", value: exercise.PrimaryMuscle)
                
                if !exercise.SecondaryMuscle.isEmpty {
                    ExerciseDetailRow(label: "Secondary Muscle Group:", value: exercise.SecondaryMuscle)
                }
                
                ExerciseDetailRow(label: "Compound Lift?", value: exercise.Compound ? "Yes" : "No")
                
                ExerciseDetailRow(label: "Description:", value: exercise.Description)
                
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(UIColor.secondarySystemBackground))
                    .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
            )
            .padding(.vertical, 8)
            
            if showInfoBox {
                infoBox
                    .offset(y: 40) // Offset the info box below the 'i' icon:
            }
        }
    }
    
    // Info box view for displaying additional exercise details:
    private var infoBox: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("How to perform:")
                .font(.headline)
                .foregroundColor(.primary)
            
            if let gifURL = URL(string: exercise.gifURL) {
                GIFView(url: gifURL)
                    .frame(height: 200)
                    .cornerRadius(8)
            }
        }
        .frame(maxWidth: 250)
        .padding()
        .background(Color.white)
        .cornerRadius(8)
        .shadow(radius: 10)
        .opacity(showInfoBox ? 1 : 0)
        .animation(.easeInOut, value: showInfoBox)
    }
}

// MARK: ExerciseDetailRow:

// View for displaying a detail row in the exercise card:
struct ExerciseDetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.subheadline)
                .bold()
                .foregroundColor(.secondary)
            Text(value)
                .font(.subheadline)
                .foregroundColor(.primary)
        }
    }
}
