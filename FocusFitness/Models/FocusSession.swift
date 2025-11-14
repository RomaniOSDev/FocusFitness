//
//  FocusSession.swift
//  FocusFitness
//
//  Created by Роман Главацкий on 14.11.2025.
//

import Foundation

struct FocusSession: Identifiable, Codable {
    let id: UUID
    let startTime: Date
    let endTime: Date?
    let duration: TimeInterval // в секундах
    let isCompleted: Bool
    
    init(id: UUID = UUID(), startTime: Date, endTime: Date? = nil, duration: TimeInterval = 0, isCompleted: Bool = false) {
        self.id = id
        self.startTime = startTime
        self.endTime = endTime
        self.duration = duration
        self.isCompleted = isCompleted
    }
    
    var minutesEarned: Int {
        Int(duration / 60)
    }
}

