//
//  ContentView.swift
//  FocusFitness
//
//  Created by Роман Главацкий on 14.11.2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var onboardingViewModel = OnboardingViewModel()
    
    var body: some View {
        Group {
            if onboardingViewModel.hasCompletedOnboarding {
                MainDashboardView()
            } else {
                OnboardingView(viewModel: onboardingViewModel)
            }
        }
    }
}

#Preview {
    ContentView()
}
