//
//  Workout.swift
//  FocusFitness
//
//  Created by Роман Главацкий on 14.11.2025.
//

import Foundation

enum WorkoutDifficulty: String, Codable, CaseIterable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
    
    var color: String {
        switch self {
        case .easy: return "green"
        case .medium: return "orange"
        case .hard: return "red"
        }
    }
}

struct Workout: Identifiable, Codable {
    let id: UUID
    let name: String
    let duration: Int // в минутах
    let focusCost: Int // стоимость в минутах фокуса
    let description: String
    let difficulty: WorkoutDifficulty
    
    init(id: UUID = UUID(), name: String, duration: Int, focusCost: Int, description: String, difficulty: WorkoutDifficulty) {
        self.id = id
        self.name = name
        self.duration = duration
        self.focusCost = focusCost
        self.description = description
        self.difficulty = difficulty
    }
    
    static let defaultWorkouts: [Workout] = [
        Workout(name: "Morning Warm-up", duration: 10, focusCost: 30,
                description: "Energizing routine", difficulty: .easy),
        
        Workout(name: "Office Stretch", duration: 5, focusCost: 25,
                description: "For neck and back", difficulty: .easy),
        
        Workout(name: "Strength 15 min", duration: 15, focusCost: 45,
                description: "Basic exercises", difficulty: .medium),
        
        Workout(name: "Focus Yoga", duration: 20, focusCost: 60,
                description: "Stretching and balance", difficulty: .medium),
        
        Workout(name: "Cardio Intensity", duration: 25, focusCost: 75,
                description: "High activity", difficulty: .hard)
    ]
}

