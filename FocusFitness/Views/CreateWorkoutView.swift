//
//  CreateWorkoutView.swift
//  FocusFitness
//
//  Created by Роман Главацкий on 14.11.2025.
//

import SwiftUI

struct CreateWorkoutView: View {
    @ObservedObject var viewModel: WorkoutViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var name: String = ""
    @State private var description: String = ""
    @State private var duration: Int = 15
    @State private var focusCost: Int = 30
    @State private var difficulty: WorkoutDifficulty = .easy
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                                        
                        // Название
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Workout Name")
                                .font(.headline)
                                .foregroundColor(Color.appText)
                            
                            TextField("Enter workout name", text: $name)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding(.horizontal, 4)
                        }
                        .padding(.horizontal)
                        
                        // Описание
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Description")
                                .font(.headline)
                                .foregroundColor(Color.appText)
                            
                            TextField("Enter description", text: $description, axis: .vertical)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .lineLimit(3...5)
                                .padding(.horizontal, 4)
                        }
                        .padding(.horizontal)
                        
                        // Длительность
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Duration: \(duration) minutes")
                                .font(.headline)
                                .foregroundColor(Color.appText)
                            
                            Slider(value: Binding(
                                get: { Double(duration) },
                                set: { duration = Int($0) }
                            ), in: 5...60, step: 5)
                            .tint(Color.appButton)
                            
                            HStack {
                                Text("5 min")
                                    .font(.caption)
                                    .foregroundColor(Color.appText.opacity(0.6))
                                Spacer()
                                Text("60 min")
                                    .font(.caption)
                                    .foregroundColor(Color.appText.opacity(0.6))
                            }
                        }
                        .padding(.horizontal)
                        
                        // Стоимость в минутах фокуса
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Focus Cost: \(focusCost) minutes")
                                .font(.headline)
                                .foregroundColor(Color.appText)
                            
                            Slider(value: Binding(
                                get: { Double(focusCost) },
                                set: { focusCost = Int($0) }
                            ), in: 10...120, step: 5)
                            .tint(Color.appButton)
                            
                            HStack {
                                Text("10 min")
                                    .font(.caption)
                                    .foregroundColor(Color.appText.opacity(0.6))
                                Spacer()
                                Text("120 min")
                                    .font(.caption)
                                    .foregroundColor(Color.appText.opacity(0.6))
                            }
                        }
                        .padding(.horizontal)
                        
                        // Сложность
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Difficulty")
                                .font(.headline)
                                .foregroundColor(Color.appText)
                            
                            Picker("Difficulty", selection: $difficulty) {
                                ForEach(WorkoutDifficulty.allCases, id: \.self) { diff in
                                    Text(diff.rawValue).tag(diff)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                        .padding(.horizontal)
                        
                        // Кнопка сохранения
                        Button(action: {
                            saveWorkout()
                        }) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.title2)
                                Text("Create Workout")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(isValid ? Color.appButton : Color.gray)
                            .cornerRadius(16)
                        }
                        .disabled(!isValid)
                        .padding(.horizontal)
                        .padding(.top, 8)
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Create Workout")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(Color.appText)
                }
            }
        }
    }
    
    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !description.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    private func saveWorkout() {
        let workout = Workout(
            name: name.trimmingCharacters(in: .whitespaces),
            duration: duration,
            focusCost: focusCost,
            description: description.trimmingCharacters(in: .whitespaces),
            difficulty: difficulty
        )
        
        viewModel.saveCustomWorkout(workout)
        dismiss()
    }
}

