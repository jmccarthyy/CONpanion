//
//  TimerCircleView.swift
//  CONpanion
//
//  Created by jake mccarthy on 08/05/2024.
//

import SwiftUI

// View for displaying the rest timer circle:
struct TimerCircleView: View {
    var timeRemaining: Int
    var initialTime: Int

    var progress: Double {
        return Double(timeRemaining) / Double(initialTime)
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 20)
                .opacity(0.3)
                .foregroundColor(.blue)

            Circle()
                .trim(from: 0.0, to: CGFloat(min(progress, 1.0)))
                .stroke(style: StrokeStyle(lineWidth: 20, lineCap: .round, lineJoin: .round))
                .foregroundColor(progress > 0.5 ? .green : (progress > 0.25 ? .orange : .red))
                .rotationEffect(Angle(degrees: 270))
                .animation(.linear, value: timeRemaining)

            Text("\(timeRemaining) s")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primary)
        }
        .frame(width: 150, height: 150)
    }
}
