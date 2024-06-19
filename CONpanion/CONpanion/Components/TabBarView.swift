//
//  TabBarView.swift
//  CONpanion
//
//  Created by jake mccarthy on 23/02/2024.
//

import SwiftUI

// Enum for tab bar items:
enum Tab: String, CaseIterable {
    case calories = "fork.knife.circle"
    case dumbbell = "dumbbell"
    case home = "house.circle"
    case notes = "square.and.pencil.circle"
    case profile = "person.circle"
}

// Custom tab bar view:
struct TabBarView: View {
    @Binding var selectedTab: Tab
    
    // Computed property for the fill image:
    private var fillImage: String {
        selectedTab.rawValue + ".fill"
    }
    
    // Computed property for the tab color:
    private var tabColor: Color {
        switch selectedTab {
        case .calories:
            return .yellow
        case .dumbbell:
            return .red
        case .home:
            return .blue
        case .notes:
            return .green
        case .profile:
            return .purple
        }
    }
    
    var body: some View {
        HStack {
            // Loop through all tab items:
            ForEach(Tab.allCases, id: \.rawValue) { tab in
                Spacer()
                // Display the tab icon:
                Image(systemName: selectedTab == tab ? fillImage : tab.rawValue)
                    .scaleEffect(selectedTab == tab ? 1.25 : 1.0)
                    .foregroundColor(selectedTab == tab ? tabColor : .gray)
                    .font(.system(size: 22))
                    .onTapGesture {
                        withAnimation(.easeIn(duration: 0.1)) {
                            selectedTab = tab
                        }
                    }
                Spacer()
            }
        }
        .frame(height: 60)
        .background(.thinMaterial)
        .cornerRadius(10)
        .padding(.horizontal)
        .padding(.bottom, 10) // Additional padding to avoid overlapping:
    }
}
