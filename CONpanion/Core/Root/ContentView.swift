//
//  ContentView.swift
//  CONpanion
//
//  Created by jake mccarthy on 06/02/2024.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Tab = .home
    @EnvironmentObject var viewModel: AuthViewModel
    
    init() {
        //Prevented automatically reserved tab bar space from showing on page:
        UITabBar.appearance().isHidden = true
    }
    
    var body: some View {
        Group{
            if viewModel.userSession != nil {
                
                ZStack {
                    VStack {
                        TabView(selection: $selectedTab) {
                            if selectedTab == .calories {
                                CaloriesView()
                            }
                            if selectedTab == .dumbbell {
                                WorkoutView()
                            }
                            if selectedTab == .home {
                                HomeView()
                            }
                            if selectedTab == .notes {
                                DiaryView()
                            }
                            if selectedTab == .profile {
                                ProfileView()
                            }
                        }
                    }
                    
                    VStack {
                        Spacer()
                        TabBarView(selectedTab: $selectedTab)
                    }
                }
                
            } else {
                LoginView()
            }
        }
    }
}

#Preview {
    ContentView()
}
