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
    
    var body: some View{
        Text ("Hello World!")
    }
}

//Preview is assigned the constant of house as it needs a value to get rid of error
#Preview {
    TabBarView(selectedTab: .constant(.home))
}
