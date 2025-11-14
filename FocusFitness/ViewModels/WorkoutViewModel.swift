//
//  WorkoutViewModel.swift
//  FocusFitness
//
//  Created by Роман Главацкий on 14.11.2025.
//

import Foundation
import Combine

class WorkoutViewModel: ObservableObject {
    @Published var workouts: [Workout] = []
    @Published var focusBank: Int = 0
    @Published var isWorkoutActive = false
    @Published var currentWorkout: Workout?
    @Published var workoutTimeRemaining: TimeInterval = 0
    
    private let storageService = UserDefaultsService.shared
    private var workoutTimer: Timer?
    
    init() {
        loadWorkouts()
        loadFocusBank()
    }
    
    func loadWorkouts() {
        let defaultWorkouts = Workout.defaultWorkouts
        let customWorkouts = storageService.customWorkouts
        workouts = defaultWorkouts + customWorkouts
    }
    
    func saveCustomWorkout(_ workout: Workout) {
        storageService.saveCustomWorkout(workout)
        loadWorkouts()
    }
    
    func deleteCustomWorkout(_ workout: Workout) {
        storageService.deleteCustomWorkout(workout)
        loadWorkouts()
    }
    
    func isCustomWorkout(_ workout: Workout) -> Bool {
        return !Workout.defaultWorkouts.contains { $0.id == workout.id }
    }
    
    func loadFocusBank() {
        let stats = storageService.userStats
        focusBank = stats.focusBank
    }
    
    func canAffordWorkout(_ workout: Workout) -> Bool {
        return focusBank >= workout.focusCost
    }
    
    func startWorkout(_ workout: Workout) -> Bool {
        guard canAffordWorkout(workout) else { return false }
        
        // Списываем минуты
        var stats = storageService.userStats
        stats.focusBank -= workout.focusCost
        storageService.updateUserStats(stats)
        focusBank = stats.focusBank
        
        // Запускаем тренировку
        currentWorkout = workout
        workoutTimeRemaining = TimeInterval(workout.duration * 60)
        isWorkoutActive = true
        
        workoutTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            if self.workoutTimeRemaining > 0 {
                self.workoutTimeRemaining -= 1
            } else {
                self.completeWorkout()
            }
        }
        
        return true
    }
    
    func pauseWorkout() {
        workoutTimer?.invalidate()
        workoutTimer = nil
    }
    
    func resumeWorkout() {
        guard let workout = currentWorkout else { return }
        
        workoutTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            if self.workoutTimeRemaining > 0 {
                self.workoutTimeRemaining -= 1
            } else {
                self.completeWorkout()
            }
        }
    }
    
    func stopWorkout() {
        workoutTimer?.invalidate()
        workoutTimer = nil
        isWorkoutActive = false
        currentWorkout = nil
        workoutTimeRemaining = 0
    }
    
    func completeWorkout() {
        workoutTimer?.invalidate()
        workoutTimer = nil
        
        guard let workout = currentWorkout else { return }
        
        // Обновляем статистику
        var stats = storageService.userStats
        stats.totalWorkoutMinutes += workout.duration
        stats.completedWorkouts += 1
        storageService.updateUserStats(stats)
        
        isWorkoutActive = false
        currentWorkout = nil
        workoutTimeRemaining = 0
    }
    
    func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

