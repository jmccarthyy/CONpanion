//
//  WorkoutView.swift
//  CONpanion
//
//  Created by jake mccarthy on 26/02/2024.
//

import SwiftUI

struct WorkoutView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Navigation link to PlansView:
                NavigationLink(destination: PlansView()) {
                    Label {
                        Text("View Your Plans")
                            .font(.headline)
                            .foregroundColor(.blue)
                    } icon: {
                        Image(systemName: "list.bullet")
                            .foregroundColor(.blue)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(10)
                .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)

                // Navigation link to ExercisesView:
                NavigationLink(destination: ExercisesView()) {
                    Label {
                        Text("View All Exercises")
                            .font(.headline)
                            .foregroundColor(.orange)
                    } icon: {
                        Image(systemName: "dumbbell")
                            .foregroundColor(.orange)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(10)
                .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
                
                Spacer() // Add spacer to create space between elements

                // Navigation link to SelectLiveWorkoutView:
                NavigationLink(destination: SelectLiveWorkoutView()) {
                    Label {
                        Text("Start Your Workout")
                            .font(.headline)
                            .foregroundColor(.white)
                    } icon: {
                        Image(systemName: "play.circle.fill")
                            .foregroundColor(.white)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.green)
                .cornerRadius(10)
                .shadow(color: .gray.opacity(0.3), radius: 4, x: 0, y: 2)

                Spacer() // Add spacer to create space between elements
            }
            .padding()
            .navigationBarTitle("Workout", displayMode: .inline) // Set navigation bar title
        }
    }
}

// Placeholder view for PreviousWorkoutSessionsView:
struct PreviousWorkoutSessionsView: View {
    var body: some View {
        Text("Previous Workout Sessions View")
    }
}
