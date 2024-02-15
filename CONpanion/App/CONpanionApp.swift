//
//  CONpanionApp.swift
//  CONpanion
//
//  Created by jake mccarthy on 06/02/2024.
//

import SwiftUI
import Firebase

@main
struct CONpanionApp: App {
    @StateObject var viewModel = AuthViewModel()
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
    }
}
