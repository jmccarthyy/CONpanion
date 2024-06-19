//
//  InputView.swift
//  CONpanion
//
//  Created by jake mccarthy on 07/02/2024.
//

import SwiftUI

// Custom input view for text fields and secure fields:
struct InputView: View {
    @Binding var text: String
    let title: String
    let placeholder: String
    var isSecureField = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Title text for the input field:
            Text(title)
                .foregroundColor(Color(.gray))
                .fontWeight(.semibold)
                .font(.footnote)
            
            // Conditional rendering of TextField or SecureField:
            if isSecureField {
                SecureField(placeholder, text: $text)
                    .foregroundColor(.gray)
                    .font(.system(size: 14))
            } else {
                TextField(placeholder, text: $text)
                    .foregroundColor(.gray)
                    .font(.system(size: 14))
            }
            
            // Divider line below the input field:
            Rectangle()
                .frame(width: 350, height: 1)
                .foregroundColor(.gray)
        }
    }
}
