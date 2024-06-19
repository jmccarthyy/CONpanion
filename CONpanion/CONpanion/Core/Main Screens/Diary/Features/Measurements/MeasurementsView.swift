//
//  MeasurementsView.swift
//  CONpanion
//
//  Created by jake mccarthy on 19/05/2024.
//

import FirebaseAuth
import SwiftUI

struct MeasurementsView: View {
    @State private var showEditSheet = false // State to control the display of the edit sheet
    @StateObject private var viewModel = MeasurementsViewModel() // ViewModel for handling measurements data

    var body: some View {
        VStack {
            // Display user information if available:
            if let user = viewModel.user {
                Form {
                    Section(header: Text("Personal Information")) {
                        Text("Age: \(user.age!)")
                        Text("Height: \(user.heightCM!) cm")
                        if let weight = user.weightKG {
                            Text("Weight: \(weight) kg")
                        } else {
                            VStack {
                                Text("You have not entered your current weight, do so in the Progress section")
                                NavigationLink(destination: ProgressView()) {
                                    Text("Go to Progress")
                                }
                            }
                        }
                        Text("Gender: \(user.gender!)")
                        Text("Activity Level: \(user.activityLevel!)")
                    }
                }
            } else {
                Text("Loading user data...")
                    .padding()
            }
        }
        .navigationTitle("Measurements")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                // Button to show edit sheet:
                Button("Edit") {
                    showEditSheet = true
                }
            }
        }
        .sheet(isPresented: $showEditSheet) {
            // Show EditMeasurementsView if user data is available:
            if let user = viewModel.user {
                EditMeasurementsView(viewModel: viewModel, user: user)
            }
        }
    }
}

struct EditMeasurementsView: View {
    // Environment to handle dismissing the view:
    @Environment(\.dismiss) private var dismiss
    // ViewModel for handling measurements data:
    @ObservedObject var viewModel: MeasurementsViewModel
    // User data to be edited:
    var user: User
    
    // State variables to hold user input:
    @State private var age: String
    @State private var height: String
    @State private var gender: String
    @State private var activityLevel: String
    
    // List of possible activity levels:
    let activityLevels = ["No Exercise", "Light Exercise", "Moderate Exercise", "Very Active"]
    
    init(viewModel: MeasurementsViewModel, user: User) {
        self.viewModel = viewModel
        self.user = user
        _age = State(initialValue: user.age.map { String($0) } ?? "")
        _height = State(initialValue: user.heightCM.map { String($0) } ?? "")
        _gender = State(initialValue: user.gender ?? "")
        _activityLevel = State(initialValue: user.activityLevel ?? "No Exercise")
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Personal Information")) {
                    // TextField for age input:
                    TextField("Age", text: $age)
                        .keyboardType(.numberPad)
                        .onChange(of: age) { newValue in
                            age = newValue.filter { "0123456789".contains($0) }
                        }
                    
                    // TextField for height input:
                    TextField("Height (cm)", text: $height)
                        .keyboardType(.numberPad)
                        .onChange(of: height) { newValue in
                            height = newValue.filter { "0123456789".contains($0) }
                        }
                    
                    // Picker for gender selection:
                    Picker("Gender", selection: $gender) {
                        Text("Male").tag("Male")
                        Text("Female").tag("Female")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section(header: Text("Activity Level")) {
                    // Picker for activity level selection:
                    Picker("Activity Level", selection: $activityLevel) {
                        ForEach(activityLevels, id: \.self) {
                            Text($0)
                        }
                    }
                }
            }
            .navigationTitle("Edit Your Measurements")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    // Cancel button to dismiss the view:
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    // Save button to save the edited measurements:
                    Button("Save") {
                        Task {
                            await viewModel.saveMeasurements(
                                age: age,
                                height: height,
                                gender: gender,
                                activityLevel: activityLevel
                            )
                            dismiss()
                        }
                    }
                }
            }
        }
    }
}

