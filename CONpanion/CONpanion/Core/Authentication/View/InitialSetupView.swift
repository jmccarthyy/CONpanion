//
//  InitialSetupView.swift
//  CONpanion
//
//  Created by jake mccarthy on 30/05/2024.
//

import SwiftUI
import Firebase

// View for initial setup after registration:
struct InitialSetupView: View {
    @State private var age: String
    @State private var gender: String
    @State private var heightCM: String
    @State private var weightKG: String
    @State private var activityLevel: String
    @EnvironmentObject var viewModel: AuthViewModel

    let activityLevels = ["No Exercise", "Light Exercise", "Moderate Exercise", "Very Active"]

    init(user: User) {
        _age = State(initialValue: user.age.map { String($0) } ?? "")
        _heightCM = State(initialValue: user.heightCM.map { String($0) } ?? "")
        _weightKG = State(initialValue: user.weightKG.map { String($0) } ?? "")
        _gender = State(initialValue: user.gender ?? "")
        _activityLevel = State(initialValue: user.activityLevel ?? "No Exercise")
    }

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            VStack(spacing: 10) {
                Text("Complete Your Profile")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .padding(.top, 40)
            
            Form {
                Section(header: Text("Personal Information").font(.headline).foregroundColor(.secondary)) {
                    TextField("Age", text: $age)
                        .keyboardType(.numberPad)
                        .onChange(of: age) { newValue in
                            age = newValue.filter { "0123456789".contains($0) }
                        }

                    TextField("Height (cm)", text: $heightCM)
                        .keyboardType(.numberPad)
                        .onChange(of: heightCM) { newValue in
                            heightCM = newValue.filter { "0123456789".contains($0) }
                        }

                    TextField("Weight (kg)", text: $weightKG)
                        .keyboardType(.numberPad)
                        .onChange(of: weightKG) { newValue in
                            weightKG = newValue.filter { "0123456789".contains($0) }
                        }

                    Picker("Gender", selection: $gender) {
                        Text("Male").tag("Male")
                        Text("Female").tag("Female")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }

                Section(header: Text("Activity Level").font(.headline).foregroundColor(.secondary)) {
                    Picker("Activity Level", selection: $activityLevel) {
                        ForEach(activityLevels, id: \.self) {
                            Text($0)
                        }
                    }
                }

                // Submit button to update the profile:
                Button(action: {
                    Task {
                        try await viewModel.updateUserProfile(
                            age: Int(age),
                            gender: gender,
                            heightCM: Int(heightCM),
                            weightKG: Int(weightKG),
                            activityLevel: activityLevel
                        )
                    }
                }) {
                    Text("Submit")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(Color.green)
                        .cornerRadius(10)
                }
                .disabled(!formIsValid())
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(10)
            .padding(.horizontal)

            Spacer()
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .edgesIgnoringSafeArea(.all)
    }

    // Function to validate the form:
    func formIsValid() -> Bool {
        return !age.isEmpty && !heightCM.isEmpty && !weightKG.isEmpty && !gender.isEmpty && !activityLevel.isEmpty
    }
}

