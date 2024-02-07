//
//  InputView.swift
//  CONpanion
//
//  Created by jake mccarthy on 07/02/2024.
//

import SwiftUI

struct InputView: View {
    @Binding var text: String
    let title: String
    let placeholder: String
    var isSecureField = false
    
    var body: some View {
        VStack (alignment: .leading, spacing: 12){
            Text(title)
                .foregroundColor(Color(.white))
                .fontWeight(.semibold)
                .font(.footnote)
            
            if isSecureField {
                SecureField(placeholder, text: $text)
                    .foregroundColor(.white)
                    .font(.system(size: 14))
                    
            } else {
                TextField(placeholder, text: $text)
                    .foregroundColor(.white)
                    .font(.system(size: 14))
                    
            }
            
            Rectangle()
                .frame(width: 350, height: 1)
                .foregroundColor(.white)
        }
    }
}

#Preview {
    InputView(text: .constant(""), title: "Email Address", placeholder: "name@example.com")
}
