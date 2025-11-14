//
//  UserDefaultsService.swift
//  FocusFitness
//
//  Created by Роман Главацкий on 14.11.2025.
//

import Foundation

class UserDefaultsService {
    static let shared = UserDefaultsService()
    
    private let hasCompletedOnboardingKey = "hasCompletedOnboarding"
    private let userStatsKey = "userStats"
    private let focusSessionsKey = "focusSessions"
    private let customWorkoutsKey = "customWorkouts"
    
    private init() {}
    
    // MARK: - Onboarding
    var hasCompletedOnboarding: Bool {
        get {
            UserDefaults.standard.bool(forKey: hasCompletedOnboardingKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: hasCompletedOnboardingKey)
        }
    }
    
    // MARK: - User Stats
    var userStats: UserStats {
        get {
            if let data = UserDefaults.standard.data(forKey: userStatsKey),
               let stats = try? JSONDecoder().decode(UserStats.self, from: data) {
                return stats
            }
            return UserStats()
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                UserDefaults.standard.set(data, forKey: userStatsKey)
            }
        }
    }
    
    // MARK: - Focus Sessions
    var focusSessions: [FocusSession] {
        get {
            if let data = UserDefaults.standard.data(forKey: focusSessionsKey),
               let sessions = try? JSONDecoder().decode([FocusSession].self, from: data) {
                return sessions
            }
            return []
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                UserDefaults.standard.set(data, forKey: focusSessionsKey)
            }
        }
    }
    
    func saveFocusSession(_ session: FocusSession) {
        var sessions = focusSessions
        sessions.append(session)
        focusSessions = sessions
    }
    
    func updateUserStats(_ stats: UserStats) {
        userStats = stats
    }
    
    // MARK: - Custom Workouts
    var customWorkouts: [Workout] {
        get {
            if let data = UserDefaults.standard.data(forKey: customWorkoutsKey),
               let workouts = try? JSONDecoder().decode([Workout].self, from: data) {
                return workouts
            }
            return []
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                UserDefaults.standard.set(data, forKey: customWorkoutsKey)
            }
        }
    }
    
    func saveCustomWorkout(_ workout: Workout) {
        var workouts = customWorkouts
        workouts.append(workout)
        customWorkouts = workouts
    }
    
    func deleteCustomWorkout(_ workout: Workout) {
        var workouts = customWorkouts
        workouts.removeAll { $0.id == workout.id }
        customWorkouts = workouts
    }
}

