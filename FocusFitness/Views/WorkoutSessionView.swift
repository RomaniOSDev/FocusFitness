//
//  WorkoutSessionView.swift
//  FocusFitness
//
//  Created by Роман Главацкий on 14.11.2025.
//

import SwiftUI

struct WorkoutSessionView: View {
    @ObservedObject var viewModel: WorkoutViewModel
    let workout: Workout
    @Environment(\.dismiss) var dismiss
    @State private var isPaused = false
    var onDismiss: (() -> Void)?
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.green.opacity(0.8), Color.blue.opacity(0.8)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                // Название тренировки
                VStack(spacing: 8) {
                    Text(workout.name)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text(workout.description)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))
                }
                
                // Таймер
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.3), lineWidth: 20)
                        .frame(width: 280, height: 280)
                    
                    Circle()
                        .trim(from: 0, to: 1 - (viewModel.workoutTimeRemaining / TimeInterval(workout.duration * 60)))
                        .stroke(Color.white, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                        .frame(width: 280, height: 280)
                        .rotationEffect(.degrees(-90))
                        .animation(.linear, value: viewModel.workoutTimeRemaining)
                    
                    VStack {
                        Text(viewModel.formatTime(viewModel.workoutTimeRemaining))
                            .font(.system(size: 64, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Workout")
                            .font(.title3)
                            .foregroundColor(.white.opacity(0.9))
                    }
                }
                
                // Демонстрация упражнения
                VStack(spacing: 12) {
                    Image(systemName: "figure.run")
                        .font(.system(size: 80))
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text("Perform Exercises")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.9))
                }
                .padding()
                .background(Color.white.opacity(0.2))
                .cornerRadius(16)
                
                // Кнопки управления
                HStack(spacing: 30) {
                    if isPaused {
                        Button(action: {
                            isPaused = false
                            viewModel.resumeWorkout()
                        }) {
                            VStack {
                                Image(systemName: "play.fill")
                                    .font(.title)
                                Text("Resume")
                                    .font(.caption)
                            }
                            .foregroundColor(.white)
                            .frame(width: 100, height: 100)
                            .background(Color.green.opacity(0.3))
                            .clipShape(Circle())
                        }
                    } else {
                        Button(action: {
                            isPaused = true
                            viewModel.pauseWorkout()
                        }) {
                            VStack {
                                Image(systemName: "pause.fill")
                                    .font(.title)
                                Text("Pause")
                                    .font(.caption)
                            }
                            .foregroundColor(.white)
                            .frame(width: 100, height: 100)
                            .background(Color.orange.opacity(0.3))
                            .clipShape(Circle())
                        }
                    }
                    
                    Button(action: {
                        viewModel.stopWorkout()
                        onDismiss?()
                        dismiss()
                    }) {
                        VStack {
                            Image(systemName: "stop.fill")
                                .font(.title)
                            Text("Finish")
                                .font(.caption)
                        }
                        .foregroundColor(.white)
                        .frame(width: 100, height: 100)
                        .background(Color.red.opacity(0.3))
                        .clipShape(Circle())
                    }
                }
                
                Spacer()
            }
            .padding()
        }
        .onAppear {
            if !viewModel.isWorkoutActive {
                _ = viewModel.startWorkout(workout)
            }
        }
        .onChange(of: viewModel.workoutTimeRemaining) { newValue in
            if newValue <= 0 && viewModel.isWorkoutActive {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    viewModel.completeWorkout()
                    onDismiss?()
                    dismiss()
                }
            }
        }
        .onDisappear {
            onDismiss?()
        }
    }
}

