//
//  StatisticsViewModel.swift
//  FocusFitness
//
//  Created by Роман Главацкий on 14.11.2025.
//

import Foundation
import Combine

struct DailyStat: Identifiable {
    let id = UUID()
    let date: Date
    let focusMinutes: Int
    let workoutMinutes: Int
}

class StatisticsViewModel: ObservableObject {
    @Published var totalFocusMinutes: Int = 0
    @Published var totalWorkoutMinutes: Int = 0
    @Published var completedSessions: Int = 0
    @Published var completedWorkouts: Int = 0
    @Published var weeklyStats: [DailyStat] = []
    
    private let storageService = UserDefaultsService.shared
    
    init() {
        loadStatistics()
    }
    
    func loadStatistics() {
        // Загружаем свежие данные из хранилища
        let stats = storageService.userStats
        
        // Обновляем published свойства для обновления UI
        totalFocusMinutes = stats.totalFocusMinutes
        totalWorkoutMinutes = stats.totalWorkoutMinutes
        completedSessions = stats.completedSessions
        completedWorkouts = stats.completedWorkouts
        
        loadWeeklyStats()
    }
    
    private func loadWeeklyStats() {
        let sessions = storageService.focusSessions
        let calendar = Calendar.current
        let now = Date()
        
        var dailyStats: [Date: (focus: Int, workout: Int)] = [:]
        
        // Инициализируем последние 7 дней
        for i in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: -i, to: now) {
                let dayStart = calendar.startOfDay(for: date)
                dailyStats[dayStart] = (focus: 0, workout: 0)
            }
        }
        
        // Подсчитываем сессии фокуса
        for session in sessions {
            let dayStart = calendar.startOfDay(for: session.startTime)
            if var currentStats = dailyStats[dayStart] {
                currentStats.focus += session.minutesEarned
                dailyStats[dayStart] = currentStats
            }
        }
        
        // Преобразуем в массив
        weeklyStats = dailyStats.map { date, values in
            DailyStat(date: date, focusMinutes: values.focus, workoutMinutes: values.workout)
        }.sorted { $0.date > $1.date }
    }
    
    var totalMinutes: Int {
        totalFocusMinutes + totalWorkoutMinutes
    }
    
    var focusPercentage: Double {
        guard totalMinutes > 0 else { return 0 }
        return Double(totalFocusMinutes) / Double(totalMinutes) * 100
    }
    
    var workoutPercentage: Double {
        guard totalMinutes > 0 else { return 0 }
        return Double(totalWorkoutMinutes) / Double(totalMinutes) * 100
    }
}

