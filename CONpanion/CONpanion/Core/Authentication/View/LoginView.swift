//
//  LoginView.swift
//  CONpanion
//
//  Created by jake mccarthy on 06/02/2024.
//

import SwiftUI
import FirebaseAuth

// View for user login:
struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var showAlert = false  // State to control the display of the alert:
    @State private var alertMessage = ""  // State to hold the alert message:

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Spacer()

                VStack(spacing: 10) {
                    Text("Welcome back!")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)

                    Text("Your CONpanion Missed You")
                        .foregroundColor(.primary)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top, 40)

                Spacer()

                // Form fields:
                InputView(text: $email,
                          title: "Email Address:",
                          placeholder: "name@email.com")
                    .autocapitalization(.none)
                    .foregroundColor(.primary)
                    .padding(.horizontal)

                InputView(text: $password,
                          title: "Password:",
                          placeholder: "Enter your password",
                          isSecureField: true)
                    .foregroundColor(.primary)
                    .padding(.horizontal)

                // Error message:
                if showAlert {
                    Text(alertMessage)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                // Sign in button:
                Button {
                    Task {
                        do {
                            try await viewModel.signIn(withEmail: email, password: password)
                            showAlert = false
                        } catch {
                            showAlert = true
                            alertMessage = "Unable to login as Email Address / Password used were invalid"
                        }
                    }
                } label: {
                    HStack {
                        Text("SIGN IN")
                            .fontWeight(.semibold)
                        Image(systemName: "arrow.right")
                    }
                    .foregroundColor(.white)
                    .frame(width: UIScreen.main.bounds.width - 32, height: 48)
                }
                .background(Color.green)
                .disabled(!formIsValid)
                .opacity(formIsValid ? 1.0 : 0.5)
                .cornerRadius(10)
                .padding(.top, 24)

                Spacer()

                // Registration link:
                NavigationLink {
                    RegistrationView()
                        .navigationBarBackButtonHidden(true)
                } label: {
                    HStack {
                        Text("Not yet been introduced?")
                        Text("Sign Up")
                            .fontWeight(.bold)
                            .font(.system(size: 14))
                    }
                    .foregroundColor(.red)
                }
                .padding(.bottom, 20)
            }
            .padding()
            .background(Color(UIColor.systemBackground))
            .edgesIgnoringSafeArea(.all)
        }
    }
}

// AuthenticationFormProtocol implementation:
extension LoginView: AuthenticationFormProtocol {
    var formIsValid: Bool {
        return !email.isEmpty
        && email.contains("@")
        && !password.isEmpty
        && password.count > 5
    }
}







