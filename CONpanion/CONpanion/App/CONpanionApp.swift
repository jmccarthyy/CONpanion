//
//  CONpanionApp.swift
//  CONpanion
//
//  Created by jake mccarthy on 06/02/2024.
//

import SwiftUI
import Firebase

@main
// Main app file:
struct CONpanionApp: App {
    @StateObject var authViewModel = AuthViewModel()
    @StateObject var progressViewModel = ProgressViewModel()
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
                .environmentObject(progressViewModel)
                .environmentObject(CaloriesViewModel.shared)
        }
    }
}
