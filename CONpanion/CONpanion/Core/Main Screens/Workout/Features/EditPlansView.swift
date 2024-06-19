//
//  EditPlansView.swift
//  CONpanion
//
//  Created by jake mccarthy on 16/04/2024.
//

import SwiftUI
import FirebaseAuth

// MARK: - EditPlansView:

// View for editing an existing plan:
struct EditPlansView: View {
    @Environment(\.presentationMode) private var presentationMode
    @State private var selectedExercises: [ExercisesArray]
    @State private var planName: String
    let plan: Plans

    init(plan: Plans) {
        self.plan = plan
        _planName = State(initialValue: plan.name)
        _selectedExercises = State(initialValue: plan.exercises ?? [])
    }

    var body: some View {
        NavigationView {
            Form {
                TextField("Plan Name", text: $planName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                Section(header: Text("Exercises:")) {
                    if selectedExercises.isEmpty {
                        Text("No Exercises currently added")
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        ForEach(selectedExercises.indices, id: \.self) { index in
                            HStack {
                                Text(selectedExercises[index].exerciseName)
                                Spacer()
                                Button(role: .destructive) {
                                    selectedExercises.remove(at: index)
                                } label: {
                                    Text("Remove")
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("(1/2) Edit Plan")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: EditExercisesView(selectedExercises: $selectedExercises)) {
                        Text("Add Exercises")
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    NavigationLink(destination: SecondEditPlanView(selectedExercises: $selectedExercises, planName: planName, originalPlan: plan)) {
                        Text("Next")
                    }
                }
            }
        }
    }
}

// MARK: - SecondEditPlanView:

// View for the second step of editing a plan:
struct SecondEditPlanView: View {
    @Binding var selectedExercises: [ExercisesArray]
    let planName: String
    let originalPlan: Plans
    @State private var sets: [[SetsArray]]

    @Environment(\.presentationMode) private var presentationMode

    init(selectedExercises: Binding<[ExercisesArray]>, planName: String, originalPlan: Plans) {
        self._selectedExercises = selectedExercises
        self.planName = planName
        self.originalPlan = originalPlan

        _sets = State(initialValue: selectedExercises.wrappedValue.map { $0.sets ?? [] })
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Selected Exercises:")) {
                    ForEach(selectedExercises.indices, id: \.self) { exerciseIndex in
                        let exerciseName = selectedExercises[exerciseIndex].exerciseName
                        EditExerciseView(exerciseName: exerciseName, sets: $sets[exerciseIndex])
                    }
                }
            }
            .navigationTitle("(2/2) Edit Plan - \(planName)")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: {
                        Task {
                            do {
                                guard let currentUserID = Auth.auth().currentUser?.uid else {
                                    print("Error: Current user ID not found")
                                    return
                                }

                                var exercisesArray: [ExercisesArray] = []
                                for (index, exercise) in selectedExercises.enumerated() {
                                    exercisesArray.append(ExercisesArray(exerciseName: exercise.exerciseName, sets: sets[index]))
                                }

                                var updatedPlan = originalPlan
                                updatedPlan.name = planName
                                updatedPlan.exercises = exercisesArray

                                let newData: [String: Any] = [
                                    "Name": updatedPlan.name,
                                    "User": currentUserID,
                                    "Exercises": try JSONSerialization.jsonObject(with: JSONEncoder().encode(exercisesArray))
                                ]

                                try await PlansViewModel.shared.updatePlan(planToUpdate: updatedPlan, newData: newData)
                                presentationMode.wrappedValue.dismiss()
                            } catch {
                                print("Error saving edited plan: \(error.localizedDescription)")
                            }
                        }
                    }) {
                        Text("Save")
                    }
                }
            }
        }
    }
}

// MARK: - EditExerciseView:

// View for displaying an exercise and its sets in edit mode:
struct EditExerciseView: View {
    let exerciseName: String
    @Binding var sets: [SetsArray]

    var body: some View {
        VStack(alignment: .leading) {
            Text(exerciseName)
                .font(.headline)

            ForEach(sets.indices, id: \.self) { setIndex in
                VStack {
                    EditSetView(set: $sets[setIndex])
                    if setIndex > 0 {
                        Button(role: .destructive) {
                            deleteSet(at: setIndex)
                        } label: {
                            Text("Delete Set")
                        }
                    }
                }
                .padding(.top, 8)
            }

            Button("Add Set") {
                addSet()
            }
            .foregroundColor(.blue)
            .padding(.top, 8)
        }
    }

    // Function to add a new set:
    private func addSet() {
        let nextSetNumber = sets.count + 1
        sets.append(SetsArray(number: nextSetNumber, reps: "", weight: ""))
    }

    // Function to delete a set:
    private func deleteSet(at index: Int) {
        guard index >= 0 && index < sets.count else { return }
        sets.remove(at: index)

        // Reorder the set numbers:
        for i in index..<sets.count {
            sets[i].number = i + 1
        }
    }
}

// MARK: - EditSetView:

// View for displaying a single set in edit mode:
struct EditSetView: View {
    @Binding var set: SetsArray

    var body: some View {
        HStack {
            Text("Set \(set.number):")
                .font(.subheadline)
            TextField("Reps", text: $set.reps)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.numberPad)

            TextField("Weight", text: $set.weight)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.numberPad)
        }
    }
}

// MARK: - EditExercisesView:

// View for adding exercises to an edited plan:
struct EditExercisesView: View {
    @Binding var selectedExercises: [ExercisesArray]
    @Environment(\.presentationMode) private var presentationMode
    @StateObject private var model = ExercisesViewModel()

    var availableExercises: [Exercises] {
        model.list.filter { exercise in
            !selectedExercises.contains(where: { $0.exerciseName == exercise.Name })
        }
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    Section(header: Text("You have added these exercises to your plan:")
                        .font(.headline)
                        .padding(.top)) {
                        
                        ForEach(selectedExercises, id: \.exerciseName) { exerciseArray in
                            Text(exerciseArray.exerciseName)
                                .font(.body)
                                .padding(.vertical, 2)
                        }
                    }
                    .padding(.horizontal)
                    
                    LazyVStack(spacing: 16) {
                        ForEach(availableExercises, id: \.id) { exercise in
                            EditExerciseCardView(exercise: exercise, selectedExercises: $selectedExercises)
                                .padding(.horizontal)
                                .padding(.top, 8)
                        }
                    }
                    .padding(.vertical)
                }
            }
            .background(Color(UIColor.systemBackground)) // White background for the entire view:
            .navigationBarTitle("Add Exercises", displayMode: .inline)
            .task {
                model.getData()
            }
        }
    }
}

// MARK: - EditExerciseCardView:

// View for displaying an exercise card in the edit exercises view:
struct EditExerciseCardView: View {
    let exercise: Exercises
    @Binding var selectedExercises: [ExercisesArray]
    @Environment(\.presentationMode) private var presentationMode
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
                ExerciseDetailRow(label: "Primary Muscle:", value: exercise.PrimaryMuscle)
                
                if !exercise.SecondaryMuscle.isEmpty {
                    ExerciseDetailRow(label: "Secondary Muscle:", value: exercise.SecondaryMuscle)
                }
                
                ExerciseDetailRow(label: "Compound Lift?", value: exercise.Compound ? "Yes" : "No")
                
                ExerciseDetailRow(label: "Description:", value: exercise.Description)
                
                Spacer()
                
                // Button to add the exercise to the selected exercises:
                Button(action: {
                    let exerciseArray = ExercisesArray(exerciseName: exercise.Name, sets: [])
                    selectedExercises.append(exerciseArray)
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Add")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                        .padding(.top)
                }
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
