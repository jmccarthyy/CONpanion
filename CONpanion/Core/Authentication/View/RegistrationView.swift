//
//  RegistrationView.swift
//  CONpanion
//
//  Created by jake mccarthy on 07/02/2024.
//

import SwiftUI

struct RegistrationView: View {
    @State private var email = ""
    @State private var fullName = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @Environment (\.dismiss) var dismiss
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        VStack{
            //background
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .foregroundStyle(.linearGradient(colors: [.customGradientColour, .red], startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width:1000, height:400)
                .rotationEffect(.degrees(135))
                .offset(y: -100)
            
            VStack(spacing: 24) {
                //text
                Text("Introducing Your Newest CONpanion")
                    .foregroundColor(.white)
                    .font(.system(size: 35, weight: .bold, design: .rounded))
                    .lineLimit(2)
                    .offset(y: -250)
                
                Text("Sign Up:")
                    .foregroundColor(.white)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .offset(x: -150, y: -200)
                
                // form fields
                InputView(text: $fullName,
                          title: "Your Name:",
                          placeholder: "Your Full Name")
                .autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)
                .foregroundColor(.white)
                .offset(y: -200)
                .padding(.horizontal)
                
                InputView(text: $email,
                          title: "Email Address:",
                          placeholder: "name@email.com")
                .autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)
                .foregroundColor(.white)
                .offset(y: -200)
                .padding(.horizontal)
                
                InputView(text: $password,
                          title: "Password:",
                          placeholder: "Enter your password",
                          isSecureField: true)
                .foregroundColor(.white)
                .offset(y: -200)
                .padding(.horizontal)
                
                ZStack(alignment: .trailing) {
                    InputView(text: $confirmPassword,
                              title: "Confirm Password:",
                              placeholder: "Confirm Your Password",
                              isSecureField: true)
                    .foregroundColor(.white)
                    .offset(y: -200)
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
                
                // registration button
                Button{
                    Task {
                        try await viewModel.createUser(withEmail: email, password: password, fullName: fullName)
                    }
                } label: {
                    HStack{
                        Text("CREATE ACCOUNT")
                            .fontWeight(.semibold)
                        Image(systemName:"arrow.right")
                    }
                    .foregroundColor(.black)
                    .frame(width: UIScreen.main.bounds.width - 32, height: 48)
                }
                .background(Color(.white))
                .disabled(!formIsValid)
                .opacity(formIsValid ? 1.0 : 0.5)
                .cornerRadius(10)
                .offset(y: -200)
                
                //registration link
                Button {
                    dismiss()
                } label: {
                    HStack (spacing: 4){
                        Text("Already been introduced?")
                        Text("Log In")
                            .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                            .font(.system(size: 14))
                    }
                    .foregroundColor(.white)
                }
                .offset(y: -100)
            }
        }
        .containerRelativeFrame([.horizontal, .vertical])
        .background(Color(.black))
    }
}

//AuthenticationFormProtocol

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

#Preview {
    RegistrationView()
}
