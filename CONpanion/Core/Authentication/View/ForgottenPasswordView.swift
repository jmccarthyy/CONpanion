//
//  ForgottenPasswordView.swift
//  CONpanion
//
//  Created by jake mccarthy on 07/02/2024.
//

import SwiftUI

struct ForgottenPasswordView: View {
    @Environment (\.dismiss) var dismiss
    var body: some View {
        VStack{
            //background
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .foregroundStyle(.linearGradient(colors: [.customGradientColour, .red], startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width:1000, height:400)
                .rotationEffect(.degrees(135))
                .offset(y: -350)
            
            
            
            Button {
                dismiss()
            } label: {
                HStack (spacing: 4){
                    Text("I've remembered my password")
                        .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                        .font(.system(size: 14))
                }
                .foregroundColor(.white)
            }
            .offset(y: -100)
        }
        .containerRelativeFrame([.horizontal, .vertical])
        .background(Color(.black))
    }
}

#Preview {
    ForgottenPasswordView()
}
