//
//  PlanCardView.swift
//  CONpanion
//
//  Created by jake mccarthy on 09/05/2024.
//

import SwiftUI

// View for displaying a plan card:
struct PlanCardView: View {
    let plan: Plans
    @Binding var selectedPlan: Plans?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(plan.name)
                .font(.title3)
                .bold()
                .foregroundColor(.primary)
            
            Text("Exercises:")
                .font(.headline)
                .foregroundColor(.secondary)
            
            if let exercises = plan.exercises {
                ForEach(exercises, id: \.exerciseName) { exercise in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(exercise.exerciseName)
                            .font(.subheadline)
                            .bold()
                            .foregroundColor(.primary)
                        
                        if let sets = exercise.sets {
                            VStack(alignment: .leading, spacing: 4) {
                                ForEach(sets.indices, id: \.self) { index in
                                    let set = sets[index]
                                    HStack {
                                        Text("Set \(index + 1):")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        Text("\(set.reps) x \(set.weight)KG")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        } else {
                            Text("No sets found")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            } else {
                Text("No exercises found")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Divider()
            
            PlanButtonGroupView(plan: plan, selectedPlan: $selectedPlan)
            
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(UIColor.secondarySystemBackground))
                .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
        )
        .padding(.vertical, 8)
    }
}
