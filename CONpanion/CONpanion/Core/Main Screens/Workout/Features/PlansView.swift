//
//  PlansView.swift
//  CONpanion
//
//  Created by jake mccarthy on 06/04/2024.
//

import SwiftUI
import FirebaseFirestore

// View for displaying user plans:
struct PlansView: View {
    @State private var shouldShowNewPlan: Bool = false

    var body: some View {
        NavigationView {
            DisplayPlansView()
                .navigationBarTitle("Your Plans", displayMode: .inline)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button {
                            shouldShowNewPlan.toggle()
                        } label: {
                            Image(systemName: "plus")
                                .foregroundColor(.green)
                        }
                    }
                }
        }
        .sheet(isPresented: $shouldShowNewPlan) {
            NewPlanView()
        }
    }
}
