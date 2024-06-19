//
//  PlanButtonGroupView.swift
//  CONpanion
//
//  Created by jake mccarthy on 09/05/2024.
//

import SwiftUI

struct PlanButtonGroupView: View {
    let plan: Plans
    @Binding var selectedPlan: Plans?

    var body: some View {
        HStack {
            Button(action: {
                selectedPlan = plan
            }) {
                HStack {
                    Image(systemName: "square.and.pencil")
                    Text("Edit Plan")
                }
            }
            .buttonStyle(PlainButtonStyle())
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.yellow.opacity(0.2))
            )
            .foregroundColor(.yellow)
            
            Divider()
                .frame(height: 30)
                .padding(.horizontal)
            
            Button(action: {
                Task {
                    do {
                        try await PlansViewModel.shared.deletePlan(planToDelete: plan)
                    } catch {
                        print("Error deleting plan: \(error.localizedDescription)")
                    }
                }
            }) {
                HStack {
                    Image(systemName: "trash")
                    Text("Delete Plan")
                }
            }
            .buttonStyle(PlainButtonStyle())
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.red.opacity(0.2))
            )
            .foregroundColor(.red)
        }
    }
}
