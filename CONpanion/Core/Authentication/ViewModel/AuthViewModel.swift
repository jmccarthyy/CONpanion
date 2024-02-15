//
//  AuthViewModel.swift
//  CONpanion
//
//  Created by jake mccarthy on 14/02/2024.
//

import Foundation
import Firebase

class AuthViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?
    
    init() {
        
    }
    
    func signIn(withEmail email: String, password: String) async throws {
        print("Sign In...")
    }
    
    func createUser(withEmail email: String, password: String, fullName: String) async throws {
        print("Create User...")
    }
    
    func signOut() {
        
    }
    
    func deleteAccount() {
        
    }
    
    func fetchUser() {
        
    }
}
