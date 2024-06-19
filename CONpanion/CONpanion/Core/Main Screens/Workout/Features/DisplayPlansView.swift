//
//  DisplayPlansView.swift
//  CONpanion
//
//  Created by jake mccarthy on 12/04/2024.
//

import SwiftUI
import Firebase

// MARK: - UserPlansViewModel:

// ViewModel for managing user plans:
@MainActor
final class UserPlansViewModel: ObservableObject {
    @Published private(set) var plans: [Plans] = []
    @Published var isLoading: Bool = true
    @Published var hasError: Bool = false
    @Published var errorMessage: String?

    init() {
        PlansViewModel.shared.$plans
            .receive(on: DispatchQueue.main)
            .assign(to: &$plans)
    }

    // Function to fetch plans data:
    func getData() async {
        do {
            self.plans = try await PlansViewModel.shared.getData()
            self.isLoading = false
        } catch {
            self.hasError = true
            self.errorMessage = error.localizedDescription
        }
    }
}

// MARK: - DisplauPlansView:

// View for displaying user plans:
struct DisplayPlansView: View {
    @ObservedObject private var viewModel = UserPlansViewModel()
    @State private var selectedPlan: Plans?

    var body: some View {
        VStack {
            if viewModel.isLoading {
                Text("Loading plans...")
                    .font(.headline)
                    .foregroundColor(.gray)
                    .padding()
            } else if viewModel.hasError {
                Text("Failed to load plans: \(viewModel.errorMessage ?? "Unknown error")")
                    .font(.headline)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(10)
                    .padding()
            } else if viewModel.plans.isEmpty {
                Text("You currently have no created plans! Create one by clicking the green plus in the top right!")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.plans, id: \.id) { plan in
                            PlanCardView(plan: plan, selectedPlan: $selectedPlan)
                                .padding(.horizontal)
                                .padding(.top, 8)
                        }
                    }
                    .padding(.vertical)
                }
            }
        }
        .task {
            await viewModel.getData()
        }
        .sheet(item: $selectedPlan) { plan in
                    EditPlansView(plan: plan)
                }
    }
}
