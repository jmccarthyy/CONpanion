//
//  ProfileView.swift
//  CONpanion
//
//  Created by jake mccarthy on 07/02/2024.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        if let user = viewModel.currentUser {
            List{
                Section{
                    HStack {
                        Text(user.initials)
                            .font(.title)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(width:72, height: 72)
                            .background(Color(.systemGray3))
                            .clipShape(Circle())
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(user.fullName)
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .padding(.top, 4)
                            
                            Text(user.email)
                                .font(.footnote)
                                .foregroundColor(.gray)
                            
                        }
                    }
                    
                }
                
                Section("General"){
                    HStack{
                    SettingsRowView(imageName: "gear",
                                    title: "Version",
                                    tintColor: Color(.systemGray))
                    
                    
                    Spacer()
                    
                    Text("Alpha")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    }
                }
                
                Section("Accessibility"){
                    
                    HStack{
                    Button {
                        print("Accessibility selected...")
                    } label: {
                        SettingsRowView(imageName: "accessibility",
                                        title: "Accessibility",
                                        tintColor: Color(.systemGray))
                    }
                        
                    Spacer()
                        
                    Image(systemName: "chevron.right")
                        .imageScale(.small)
                        .foregroundColor(Color(.systemGray))
                    
                    }
                    
                    HStack{
                    Button {
                        print("Font size selected...")
                    } label: {
                    SettingsRowView(imageName: "textformat.size",
                                    title: "Font Size",
                                    tintColor: Color(.systemGray))
                    }
                    
                    Spacer()
                        
                    Image(systemName: "chevron.right")
                        .imageScale(.small)
                        .foregroundColor(Color(.systemGray))
                    
                    }
                    
                    HStack{
                    Button {
                        print("App appearance selected...")
                    } label: {
                        SettingsRowView(imageName: "eye",
                                        title: "App Appearance",
                                        tintColor: Color(.systemGray))
                    }
                    
                    Spacer()
                        
                    Image(systemName: "chevron.right")
                        .imageScale(.small)
                        .foregroundColor(Color(.systemGray))
                    
                    }
                    
                }
                
                Section("Account"){
                    Button {
                        viewModel.signOut()
                    } label: {
                        SettingsRowView(imageName: "arrow.left.circle.fill", title: "Sign Out", tintColor: Color(.red))
                    }
                    
                    Button {
                        print("Delete Account...")
                    } label: {
                        SettingsRowView(imageName: "xmark.circle.fill", title: "Delete Account", tintColor: Color(.red))
                    }
                }
                
            }
        }
    }
}

#Preview {
    ProfileView()
}
