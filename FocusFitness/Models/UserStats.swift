//
//  UserStats.swift
//  FocusFitness
//
//  Created by Роман Главацкий on 14.11.2025.
//

import Foundation

struct UserStats: Codable {
    var totalFocusMinutes: Int
    var totalWorkoutMinutes: Int
    var focusBank: Int // текущий баланс минут
    var completedWorkouts: Int
    var completedSessions: Int
    
    init(totalFocusMinutes: Int = 0,
         totalWorkoutMinutes: Int = 0,
         focusBank: Int = 0,
         completedWorkouts: Int = 0,
         completedSessions: Int = 0) {
        self.totalFocusMinutes = totalFocusMinutes
        self.totalWorkoutMinutes = totalWorkoutMinutes
        self.focusBank = focusBank
        self.completedWorkouts = completedWorkouts
        self.completedSessions = completedSessions
    }
}

