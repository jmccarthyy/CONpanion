//
//  LoginView.swift
//  CONpanion
//
//  Created by jake mccarthy on 06/02/2024.
//

import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        NavigationStack{
            VStack{
                //background
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .foregroundStyle(.linearGradient(colors: [.customGradientColour, .red], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width:1000, height:400)
                    .rotationEffect(.degrees(135))
                    .offset(y: -100)
                
                VStack(spacing: 24) {
                    //text
                    Text("Your CONpanion Missed You")
                        .foregroundColor(.white)
                        .font(.system(size: 35, weight: .bold, design: .rounded))
                        .lineLimit(2)
                        .offset(y: -300)
                    
                    Text("Log in:")
                        .foregroundColor(.white)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .offset(x: -150, y: -250)
                    
                    // form fields
                    InputView(text: $email,
                              title: "Email Address:",
                              placeholder: "name@email.com")
                        .autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)
                        .foregroundColor(.white)
                        .offset(y: -250)
                        .padding(.horizontal)
                    
                    InputView(text: $password,
                              title: "Password:",
                              placeholder: "Enter your password",
                              isSecureField: true)
                        .foregroundColor(.white)
                        .offset(y: -250)
                        .padding(.horizontal)
                    
                    //forgotten password link
                    NavigationLink {
                        ForgottenPasswordView()
                            .navigationBarBackButtonHidden(true)
                    } label: {
                        HStack (spacing: 4){
                            Text("I've Forgotten My Password")
                                .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                                .font(.system(size: 14))
                        }
                        .foregroundColor(.white)
                    }
                    .offset(y: -250)
                    
                    // sign in button
                    Button{
                        Task{
                            try await viewModel.signIn(withEmail: email, password: password)
                        }
                    } label: {
                        HStack{
                            Text("SIGN IN")
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
                    .padding(.top, 24)
                    .offset(y: -250)
                    
                    Spacer()
                    
                    //registration link
                    NavigationLink {
                        RegistrationView()
                            .navigationBarBackButtonHidden(true)
                    } label: {
                        HStack (spacing: 4){
                            Text("Not yet been introduced?")
                            Text("Sign Up")
                                .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                                .font(.system(size: 14))
                        }
                        .foregroundColor(.white)
                    }
                    .offset(y: -40)
                    
                }
            }
            .containerRelativeFrame([.horizontal, .vertical])
            .background(Color(.black))
        }
    }
}

//AuthenticationFormProtocol

extension LoginView: AuthenticationFormProtocol {
    var formIsValid: Bool {
        return !email.isEmpty
        && email.contains("@")
        && !password.isEmpty
        && password.count > 5
    }
    
    
}

#Preview {
    LoginView()
}
