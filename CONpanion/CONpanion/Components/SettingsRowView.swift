//
//  SettingsRowView.swift
//  CONpanion
//
//  Created by jake mccarthy on 08/02/2024.
//

import SwiftUI

// Custom view for displaying a settings row:
struct SettingsRowView: View {
    let imageName: String
    let title: String
    let tintColor: Color
    
    var body: some View {
        HStack(spacing: 12) {
            // Image icon for the settings row:
            Image(systemName: imageName)
                .imageScale(.small)
                .font(.title)
                .foregroundColor(tintColor)
            
            // Title text for the settings row:
            Text(title)
                .font(.subheadline)
                .foregroundColor(.black)
        }
    }
}
