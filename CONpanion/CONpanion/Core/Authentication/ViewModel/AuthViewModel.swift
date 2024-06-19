//
//  AuthViewModel.swift
//  CONpanion
//
//  Created by jake mccarthy on 14/02/2024.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

// Protocol to define a form's validity:
protocol AuthenticationFormProtocol {
    var formIsValid: Bool { get }
}

@MainActor
class AuthViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?

    // Computed property to get the user's first name:
    var firstName: String {
        currentUser?.fullName.components(separatedBy: " ").first ?? ""
    }

    // Initializer to set up the user session and fetch the user:
    init() {
        self.userSession = Auth.auth().currentUser

        Task {
            await fetchUser()
        }
    }

    // Function to sign in with email and password:
    func signIn(withEmail email: String, password: String) async throws {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = result.user
            await fetchUser()
        } catch {
            print("Failed to log in with error \(error.localizedDescription)")
            throw error
        }
    }

    // Function to create a user with email, password, and full name:
    func createUser(withEmail email: String, password: String, fullName: String) async throws {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.userSession = result.user
            let user = User(id: result.user.uid, fullName: fullName, email: email)
            try Firestore.firestore().collection("users").document(user.id).setData(from: user)
            await fetchUser()
        } catch {
            print("Failed to create user with error \(error.localizedDescription)")
            throw error
        }
    }

    // Function to sign out the current user:
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.userSession = nil
            self.currentUser = nil
        } catch {
            print("Failed to sign out with error \(error.localizedDescription)")
        }
    }

    // Function to fetch the current user from Firestore:
    func fetchUser() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let snapshot = try? await Firestore.firestore().collection("users").document(uid).getDocument() else { return }
        self.currentUser = try? snapshot.data(as: User.self)
    }

    // Function to update the user's profile with additional details:
    func updateUserProfile(age: Int?, gender: String, heightCM: Int?, weightKG: Int?, activityLevel: String) async throws {
        guard var currentUser = self.currentUser else { return }
        currentUser.age = age
        currentUser.gender = gender
        currentUser.heightCM = heightCM
        currentUser.weightKG = weightKG
        currentUser.activityLevel = activityLevel
        try Firestore.firestore().collection("users").document(currentUser.id).setData(from: currentUser)
        await fetchUser()
    }
}

