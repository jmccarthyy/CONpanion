//
//  RegistrationView.swift
//  CONpanion
//
//  Created by jake mccarthy on 07/02/2024.
//

import SwiftUI

struct RegistrationView: View {
    var body: some View {
        VStack{
            //background
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .foregroundStyle(.linearGradient(colors: [.customGradientColour, .red], startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width:1000, height:400)
                .rotationEffect(.degrees(135))
                .offset(y: -350)
        }
        .containerRelativeFrame([.horizontal, .vertical])
        .background(Color(.black))
    }
}

#Preview {
    RegistrationView()
}
