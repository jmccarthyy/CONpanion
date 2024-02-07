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
    let isSecureField = false
    
    var body: some View {
        VStack{
            Text(title)
                .foregroundColor(Color(.darkGray))
                .fontWeight(.semibold)
                .font(.footnote)
            
            if isSecureField {
                
            } else {
                
            }
        }
    }
}

#Preview {
    InputView(text: .constant(""), title: "Email Address", placeholder: "name@example.com")
}
