//
//  NewPlanView.swift
//  CONpanion
//
//  Created by jake mccarthy on 11/04/2024.
//

import SwiftUI
import Firebase
import FirebaseFirestore

// MARK: - NewPlanView:

// View for creating a new plan:
struct NewPlanView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedExercises: [Exercises] = []
    @State private var planName: String = "Your New Plan"

    var body: some View {
        NavigationView {
            Form {
                TextField("Your New Plan", text: $planName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                Section(header: Text("Exercises:")) {
                    if selectedExercises.isEmpty {
                        Text("No Exercises currently added")
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        ForEach(selectedExercises, id: \.id) { exercise in
                            HStack {
                                Text(exercise.Name)
                                Spacer()
                                Button("Remove") {
                                    selectedExercises.removeAll { $0.id == exercise.id }
                                }
                                .foregroundColor(.red)
                            }
                        }
                    }
                }
            }
            .navigationTitle("(1/2) New Plan")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: AddExercisesView(selectedExercises: $selectedExercises)) {
                        Text("Add Exercise")
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    NavigationLink(destination: SecondPlanView(selectedExercises: selectedExercises, planName: planName)) {
                        Text("Next")
                    }
                }
            }
        }
    }
}

// MARK: - SecondPlanView:

// View for the second step of creating a new plan:
struct SecondPlanView: View {
    let selectedExercises: [Exercises]
    let planName: String
    @State private var sets: [SetsArray] = [SetsArray(number: 1, reps: "", weight: "")]
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        Form {
            Section(header: Text("Selected Exercises:")) {
                ForEach(selectedExercises, id: \.id) { exercise in
                    ExerciseView(exercise: exercise, sets: $sets) { updatedSets in
                        self.sets = updatedSets
                    }
                }
            }
        }
        .navigationTitle("(2/2) New Plan - \(planName)")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button(action: {
                    Task {
                        await savePlan()
                    }
                }) {
                    Text("Save")
                }
            }
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }
    
    // Function to save the new plan:
    private func savePlan() async {
        do {
            try await PlansViewModel.shared.savePlan(planName: planName, selectedExercises: selectedExercises, sets: sets)
            await MainActor.run {
                presentationMode.wrappedValue.dismiss()
            }
        } catch {
            print("Error saving new plan: \(error.localizedDescription)")
        }
    }
}

// MARK: - ExerciseView

// View for displaying an exercise and its sets:
struct ExerciseView: View {
    let exercise: Exercises
    @Binding var sets: [SetsArray]
    let onUpdateSets: ([SetsArray]) -> Void

    var body: some View {
        VStack(alignment: .leading) {
            Text(exercise.Name)
                .font(.headline)
            
            ForEach(sets.indices, id: \.self) { setIndex in
                VStack {
                    HStack {
                        SetView(set: $sets[setIndex])
                        Spacer()
                    }
                    if setIndex > 0 {
                        Button("Delete Set") {
                            deleteSet(at: setIndex)
                        }
                    }
                }
                .padding(.top, 8)
            }
        }
        
        Button("Add Set") {
            addSet()
        }
    }
    
    // Function to add a new set:
    private func addSet() {
        let nextSetNumber = sets.count + 1
        sets.append(SetsArray(number: nextSetNumber, reps: "", weight: ""))
    }
    
    // Function to delete a set:
    private func deleteSet(at index: Int) {
        guard index >= 0 && index < sets.count && sets.count > 1 else {
            return
        }
        
        sets.remove(at: index)
        
        for i in index..<sets.count {
            sets[i].number = i + 1
        }
    }
}

// MARK: - SetView:

// View for displaying a single set:
struct SetView: View {
    @Binding var set: SetsArray

    var body: some View {
        HStack {
            Text("Set \(set.number):")
                .font(.subheadline)
            TextField("Reps", text: Binding(
                get: { self.set.reps },
                set: { self.set.reps = $0 }
            ))
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .keyboardType(.numberPad)
            
            TextField("Weight", text: Binding(
                get: { self.set.weight },
                set: { self.set.weight = $0 }
            ))
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .keyboardType(.numberPad)
        }
    }
}

// MARK: - AddExercisesView

// View for adding exercises to a plan:
struct AddExercisesView: View {
    @Binding var selectedExercises: [Exercises]
    @Environment(\.presentationMode) var presentationMode
    @StateObject var model = ExercisesViewModel()
    
    var availableExercises: [Exercises] {
        model.list.filter { exercise in
            !selectedExercises.contains(where: { $0.id == exercise.id })
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    Section(header: Text("You have added these exercises to your plan:")
                        .font(.headline)
                        .padding(.top)) {
                        
                        ForEach(selectedExercises, id: \.id) { exercise in
                            Text(exercise.Name)
                                .font(.body)
                                .padding(.vertical, 2)
                        }
                    }
                    .padding(.horizontal)
                    
                    LazyVStack(spacing: 16) {
                        ForEach(availableExercises, id: \.id) { exercise in
                            AddExerciseCardView(exercise: exercise, selectedExercises: $selectedExercises)
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

// MARK: - AddExerciseCardView:

// View for displaying an exercise card in the add exercises view:
struct AddExerciseCardView: View {
    let exercise: Exercises
    @Binding var selectedExercises: [Exercises]
    @Environment(\.presentationMode) var presentationMode
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
                    selectedExercises.append(exercise)
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

private extension NewPlanView {
    func handleDismiss() {
        if #available(iOS 15, *) {
            dismiss()
        } else {
            presentationMode.wrappedValue.dismiss()
        }
    }
}
