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
            ZStack{
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .foregroundStyle(.linearGradient(colors: [.customGradientColour, .red], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width:1000, height:400)
                    .rotationEffect(.degrees(135))
                    .offset(y: -350)
                
                VStack(spacing: 20) {
                    Text("Your CONpanion Missed You")
                        .foregroundColor(.white)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .lineLimit(2)
                        .offset( y: -250)
                    
                    Text("Log in:")
                        .foregroundColor(.white)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .offset(x: -150, y: -210)
                    
                    // form fields
                    
                    // sign in button
                    
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
