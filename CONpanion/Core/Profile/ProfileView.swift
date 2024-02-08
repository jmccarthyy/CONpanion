//
//  ProfileView.swift
//  CONpanion
//
//  Created by jake mccarthy on 07/02/2024.
//

import SwiftUI

struct ProfileView: View {
    var body: some View {
        List{
            Section{
                HStack {
                    Text("CM")
                        .font(.system(size: 28))
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(width:72, height: 72)
                        .background(Color(.systemGray3))
                        .clipShape(Circle())
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Conor McGregor")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .padding(.top, 4)
                        
                        Text("test@email.com")
                            .font(.footnote)
                            .accentColor(.black)
                        
                    }
                }
                
            }
            
            Section("General"){
                SettingsRowView(imageName: "gear", 
                                title: "Version",
                                tintColor: Color(.systemGray))
            }
            
            Section("Accessibility"){
                
                
            }
            
            Section("Account"){
            }
            
        }
    }
}

#Preview {
    ProfileView()
}
