//
//  FocusViewModel.swift
//  FocusFitness
//
//  Created by Роман Главацкий on 14.11.2025.
//

import Foundation
import Combine

class FocusViewModel: ObservableObject {
    @Published var isRunning = false
    @Published var isPaused = false
    @Published var currentTime: TimeInterval = 0
    @Published var focusBank: Int = 0
    @Published var currentSession: FocusSession?
    
    private var timer: Timer?
    private let storageService = UserDefaultsService.shared
    private var startTime: Date?
    
    init() {
        loadFocusBank()
    }
    
    func loadFocusBank() {
        let stats = storageService.userStats
        focusBank = stats.focusBank
    }
    
    func startFocus(duration: TimeInterval = 25 * 60) { // 25 минут по умолчанию
        guard !isRunning else { return }
        
        startTime = Date()
        currentTime = duration
        isRunning = true
        isPaused = false
        
        currentSession = FocusSession(startTime: startTime!)
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            if self.currentTime > 0 {
                self.currentTime -= 1
            } else {
                self.completeFocus()
            }
        }
    }
    
    func pauseFocus() {
        isPaused = true
        timer?.invalidate()
        timer = nil
    }
    
    func resumeFocus() {
        guard isPaused else { return }
        isPaused = false
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            if self.currentTime > 0 {
                self.currentTime -= 1
            } else {
                self.completeFocus()
            }
        }
    }
    
    func stopFocus() {
        timer?.invalidate()
        timer = nil
        
        if let session = currentSession, let start = startTime {
            let duration = Date().timeIntervalSince(start)
            let completedSession = FocusSession(
                id: session.id,
                startTime: session.startTime,
                endTime: Date(),
                duration: duration,
                isCompleted: false
            )
            
            // Сохраняем частично завершенную сессию
            storageService.saveFocusSession(completedSession)
            
            // Добавляем заработанные минуты
            let minutesEarned = completedSession.minutesEarned
            if minutesEarned > 0 {
                addMinutesToBank(minutesEarned)
                
                // Обновляем статистику даже для незавершенных сессий
                var stats = storageService.userStats
                stats.totalFocusMinutes += minutesEarned
                storageService.updateUserStats(stats)
            }
        }
        
        resetFocus()
    }
    
    func completeFocus() {
        timer?.invalidate()
        timer = nil
        
        guard let session = currentSession, let start = startTime else { return }
        
        let duration = Date().timeIntervalSince(start)
        let completedSession = FocusSession(
            id: session.id,
            startTime: session.startTime,
            endTime: Date(),
            duration: duration,
            isCompleted: true
        )
        
        storageService.saveFocusSession(completedSession)
        
        // Добавляем заработанные минуты
        let minutesEarned = completedSession.minutesEarned
        addMinutesToBank(minutesEarned)
        
        // Обновляем статистику
        var stats = storageService.userStats
        stats.totalFocusMinutes += minutesEarned
        stats.completedSessions += 1
        storageService.updateUserStats(stats)
        
        resetFocus()
    }
    
    private func resetFocus() {
        isRunning = false
        isPaused = false
        currentTime = 0
        currentSession = nil
        startTime = nil
    }
    
    private func addMinutesToBank(_ minutes: Int) {
        var stats = storageService.userStats
        stats.focusBank += minutes
        storageService.updateUserStats(stats)
        focusBank = stats.focusBank
    }
    
    func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

