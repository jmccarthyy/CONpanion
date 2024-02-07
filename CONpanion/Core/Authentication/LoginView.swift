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
    var body: some View {
        NavigationStack{
            VStack{
                //background
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .foregroundStyle(.linearGradient(colors: [.customGradientColour, .red], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width:1000, height:400)
                    .rotationEffect(.degrees(135))
                    .offset(y: -150)
                
                VStack(spacing: 24) {
                    //text
                    Text("Your CONpanion Missed You")
                        .foregroundColor(.white)
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .lineLimit(3)
                        .offset( y: -350)
                    
                    Text("Log in:")
                        .foregroundColor(.white)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .offset(x: -150, y: -300)
                    
                    // form fields
                    InputView(text: $email, title: "Email Address", placeholder: "name@email.com")
                        .foregroundColor(.white)
                        .offset(x: 15, y: -300)
                        
                    
                    // sign in button
                    
                    Spacer()
                    
                    //registration link
                    
                    //forgotten password link
                }
            }
            .containerRelativeFrame([.horizontal, .vertical])
            .background(Color.black)
        }
    }
}

#Preview {
    LoginView()
}
