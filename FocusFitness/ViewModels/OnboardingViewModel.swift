//
//  OnboardingViewModel.swift
//  FocusFitness
//
//  Created by Роман Главацкий on 14.11.2025.
//

import Foundation
import Combine

class OnboardingViewModel: ObservableObject {
    @Published var currentPage = 0
    @Published var hasCompletedOnboarding: Bool = false
    
    private let storageService = UserDefaultsService.shared
    
    init() {
        hasCompletedOnboarding = storageService.hasCompletedOnboarding
    }
    
    func completeOnboarding() {
        // Give 25 minutes as a gift
        var stats = storageService.userStats
        stats.focusBank += 25
        storageService.updateUserStats(stats)
        
        storageService.hasCompletedOnboarding = true
        hasCompletedOnboarding = true
    }
}

