//
//  LoginView.swift
//  CONpanion
//
//  Created by jake mccarthy on 06/02/2024.
//

import SwiftUI

struct LoginView: View {
    var body: some View {
        NavigationStack{
            VStack{
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .foregroundStyle(.linearGradient(colors: [.customGradientColour, .red], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width:1000, height:400)
                    .rotationEffect(.degrees(135))
                    .offset(y: -350)
                
                // text fields
                
                // sign in button
                
                //registration link
                
                //forgotten password link
            }
            .containerRelativeFrame([.horizontal, .vertical])
            .background(Color.black)
        }
    }
}

#Preview {
    LoginView()
}
