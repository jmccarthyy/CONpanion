//
//  TabBarView.swift
//  CONpanion
//
//  Created by jake mccarthy on 23/02/2024.
//

import SwiftUI

//Tab class (to see current tab) that conforms to String and CaseIterable so it can be looped through
enum Tab: String, CaseIterable {
    // case (flow control) images for all tabs
    case calories = "fork.knife.circle"
    case dumbbell = "dumbbell"
    case home = "house.circle"
    case notes = "square.and.pencil.circle"
    case profile = "person.circle"
}

struct TabBarView: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    TabBarView()
}
