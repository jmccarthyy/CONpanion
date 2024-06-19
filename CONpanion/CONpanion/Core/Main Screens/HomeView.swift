//
//  HomeView.swift
//  CONpanion
//
//  Created by jake mccarthy on 23/02/2024.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct HomeView: View {
    @EnvironmentObject var viewModel: AuthViewModel // Observed object for authentication
    @EnvironmentObject var calsViewModel: CaloriesViewModel // Observed object for calories data
    @Binding var selectedTab: Tab // Binding to manage the selected tab
    
    var body: some View {
        NavigationView {
            // Check if the user is logged in:
            if let _ = viewModel.currentUser {
                VStack(spacing: 20) {
                    VStack(spacing: 10) {
                        // Welcome message with the user's first name:
                        Text("Welcome back,")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                        Text(viewModel.firstName)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.top, 40)
                    // Spacer to create space between elements:
                    Spacer()
                    
                    VStack(spacing: 30) {
                        // Display current calories view:
                        CurrentCaloriesView(viewModel: calsViewModel)
                        // Display today's intake view:
                        TodayIntakeView(viewModel: calsViewModel)
                            .padding()
                    }
                    .padding(.horizontal)
                    // Spacer to create space between elements:
                    Spacer()
                    
                    // Button to start today's workout:
                    Button(action: {
                        selectedTab = .dumbbell
                    }) {
                        HStack {
                            Image(systemName: "figure.walk")
                                .foregroundColor(.white)
                            Text("Start Today's Workout!")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.orange)
                        .cornerRadius(10)
                        .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
                    }
                    .padding(.horizontal)
                    // Spacer to create space between elements:
                    Spacer()
                }
                .padding()
                .navigationBarTitle("Home", displayMode: .inline) // Set navigation bar title
                .background(Color(UIColor.systemBackground)) // Set background color
                .onAppear {
                    Task {
                        // Fetch today's macros on appear:
                        await calsViewModel.fetchTodayMacros()
                    }
                }
            } else {
                // Loading view when user data is not available:
                VStack {
                    Text("Loading...")
                        .font(.title)
                        .padding()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .orange))
                        .scaleEffect(2.0)
                }
            }
        }
    }
}
