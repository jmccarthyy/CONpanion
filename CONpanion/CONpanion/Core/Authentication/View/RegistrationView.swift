//
//  RegistrationView.swift
//  CONpanion
//
//  Created by jake mccarthy on 07/02/2024.
//

import SwiftUI

// View for user registration:
struct RegistrationView: View {
    @State private var email = ""
    @State private var fullName = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Spacer()

                VStack(spacing: 10) {
                    Text("Welcome!")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)

                    Text("Introducing Your Newest CONpanion")
                        .foregroundColor(.primary)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top, 40)

                Spacer()

                // Form fields:
                InputView(text: $fullName,
                          title: "Your Name:",
                          placeholder: "Your Full Name")
                    .autocapitalization(.none)
                    .foregroundColor(.primary)
                    .padding(.horizontal)

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

                ZStack(alignment: .trailing) {
                    InputView(text: $confirmPassword,
                              title: "Confirm Password:",
                              placeholder: "Confirm Your Password",
                              isSecureField: true)
                        .foregroundColor(.primary)
                        .padding(.horizontal)
                    
                    if !password.isEmpty && !confirmPassword.isEmpty {
                        if password == confirmPassword {
                            Image(systemName: "checkmark.circle.fill")
                                .imageScale(.large)
                                .fontWeight(.bold)
                                .foregroundColor(Color(.systemGray))
                        } else {
                            Image(systemName: "xmark.circle.fill")
                                .imageScale(.large)
                                .fontWeight(.bold)
                                .foregroundColor(Color(.systemRed))
                        }
                    }
                }

                // Registration button:
                Button {
                    Task {
                        try await viewModel.createUser(withEmail: email, password: password, fullName: fullName)
                    }
                } label: {
                    HStack {
                        Text("CREATE ACCOUNT")
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

                // Log in link:
                Button {
                    dismiss()
                } label: {
                    HStack {
                        Text("Already been introduced?")
                        Text("Log In")
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
extension RegistrationView: AuthenticationFormProtocol {
    var formIsValid: Bool {
        return !email.isEmpty
        && email.contains("@")
        && !password.isEmpty
        && password.count > 5
        && !fullName.isEmpty
        && confirmPassword == password
    }
}



