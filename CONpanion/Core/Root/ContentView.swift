//
//  ContentView.swift
//  CONpanion
//
//  Created by jake mccarthy on 06/02/2024.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .containerRelativeFrame([.horizontal, .vertical])
        .background(Color.black)
        .padding()
    }
}

#Preview {
    ContentView()
}
