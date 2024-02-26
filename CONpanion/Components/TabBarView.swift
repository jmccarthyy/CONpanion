//
//  TabBarView.swift
//  CONpanion
//
//  Created by jake mccarthy on 23/02/2024.
//

import SwiftUI

//Tab class (for current tab) that conforms to String and CaseIterable so it can be looped through:
enum Tab: String, CaseIterable {
    // case (flow control) images for all tabs:
    case calories = "fork.knife.circle"
    case dumbbell = "dumbbell"
    case home = "house.circle"
    case notes = "square.and.pencil.circle"
    case profile = "person.circle"
}

struct TabBarView: View {
    //@Binding variable for keeping track of which tab is currently selected:
    @Binding var selectedTab: Tab
    
    //Computed property that takes name of SF Symbol and returns it with as new string with .fill version so that current tab selected has filled image:
    private var fillImage: String{
        selectedTab.rawValue + ".fill"
    }
    
    //Computed property to assign unique colour to each tab image
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
    
    var body: some View{
        VStack {
            HStack {
                //ForEach loop (that iterates through all cases) to hold tabs:
                ForEach(Tab.allCases, id: \.rawValue){ tab in
                    Spacer()
                    Image(systemName: selectedTab == tab ? fillImage: tab.rawValue)
                    //scaleEffect modifier so that currently selected tab is larger than others
                        .scaleEffect(selectedTab == tab ? 1.25 : 1.0)
                        .foregroundColor(selectedTab == tab ? .red : .gray)
                        .font(.system(size: 22))
                    //Assigned tab select animation
                        .onTapGesture {
                            withAnimation(.easeIn(duration: 0.1)) {
                                selectedTab = tab
                            }
                        }
                    Spacer()
                }
            }
            //TabBar container:
            .frame(width: nil, height: 60)
            //.thinMaterial for transferring between light + dark mode (need to change other pages' elements' backgrounds):
            .background(.thinMaterial)
            .cornerRadius(10)
            .padding()
        }
    }
}

//Preview is assigned the constant of house as it needs a value to get rid of error
#Preview {
    TabBarView(selectedTab: .constant(.calories))
}
