//
//  DiaryView.swift
//  CONpanion
//
//  Created by jake mccarthy on 26/02/2024.
//

import SwiftUI

struct DiaryView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Navigation link to the Progress view:
                NavigationLink(destination: ProgressView()) {
                    Label {
                        Text("Your Progress")
                            .font(.headline)
                            .foregroundColor(.blue)
                    } icon: {
                        Image(systemName: "chart.bar.xaxis")
                            .foregroundColor(.blue)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(10)
                .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)

                // Navigation link to the Goals view:
                NavigationLink(destination: GoalsView()) {
                    Label {
                        Text("View Your Goals")
                            .font(.headline)
                            .foregroundColor(.green)
                    } icon: {
                        Image(systemName: "target")
                            .foregroundColor(.green)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(10)
                .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)

                Spacer()
            }
            .padding()
            // Set navigation bar title:
            .navigationBarTitle("Diary", displayMode: .inline)
        }
    }
}



