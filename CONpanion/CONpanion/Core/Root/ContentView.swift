//
//  ContentView.swift
//  CONpanion
//
//  Created by jake mccarthy on 06/02/2024.
//

import SwiftUI

// Main content view:
struct ContentView: View {
    @State private var selectedTab: Tab = .home
    @EnvironmentObject var viewModel: AuthViewModel
    @EnvironmentObject var calsViewModel: CaloriesViewModel
    @EnvironmentObject var progressViewModel: ProgressViewModel

    init() {
        UITabBar.appearance().isHidden = true
    }

    var body: some View {
        Group {
            // Show different views based on user's profile completeness:
            if let user = viewModel.currentUser {
                if isProfileComplete(user) {
                    MainTabView(selectedTab: $selectedTab)
                } else {
                    InitialSetupView(user: user)
                }
            } else {
                LoginView()
            }
        }
    }

    // Check if user's profile is complete:
    func isProfileComplete(_ user: User) -> Bool {
        return user.age != nil &&
               user.gender != nil &&
               user.heightCM != nil &&
               user.weightKG != nil &&
               user.activityLevel != nil
    }
}

// View for the main tab bar:
struct MainTabView: View {
    @Binding var selectedTab: Tab

    var body: some View {
        ZStack {
            VStack {
                TabView(selection: $selectedTab) {
                    CaloriesView()
                        .tag(Tab.calories)
                        .edgesIgnoringSafeArea(.top)
                    WorkoutView()
                        .tag(Tab.dumbbell)
                        .edgesIgnoringSafeArea(.top)
                    HomeView(selectedTab: $selectedTab)
                        .tag(Tab.home)
                        .edgesIgnoringSafeArea(.top)
                    DiaryView()
                        .tag(Tab.notes)
                        .edgesIgnoringSafeArea(.top)
                    ProfileView()
                        .tag(Tab.profile)
                        .edgesIgnoringSafeArea(.top)
                }
            }
            .padding(.bottom, 60)

            VStack {
                Spacer()
                TabBarView(selectedTab: $selectedTab)
                    .background(Color(.systemBackground))
                    .edgesIgnoringSafeArea(.bottom)
            }
        }
    }
}
