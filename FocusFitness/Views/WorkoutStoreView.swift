//
//  WorkoutStoreView.swift
//  FocusFitness
//
//  Created by Роман Главацкий on 14.11.2025.
//

import SwiftUI

struct WorkoutStoreView: View {
    @ObservedObject var viewModel: WorkoutViewModel
    @Binding var focusBank: Int
    @Environment(\.dismiss) var dismiss
    @State private var showWorkoutSession = false
    @State private var selectedWorkout: Workout?
    @State private var animateDeduction = false
    @State private var showCreateWorkout = false
    @State private var workoutToDelete: Workout?
    @State private var showDeleteAlert = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        // Кнопка создания
                        Button(action: {
                            showCreateWorkout = true
                        }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                                Text("Create Custom Workout")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.appButton)
                            .cornerRadius(16)
                        }
                        .padding(.horizontal)
                        .padding(.top)
                        
                        // Сетка тренировок
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 16),
                            GridItem(.flexible(), spacing: 16)
                        ], spacing: 16) {
                            ForEach(viewModel.workouts) { workout in
                                WorkoutStoreCard(
                                    workout: workout,
                                    canAfford: focusBank >= workout.focusCost,
                                    isCustom: viewModel.isCustomWorkout(workout),
                                    onTap: {
                                        if focusBank >= workout.focusCost {
                                            startWorkoutWithAnimation(workout)
                                        }
                                    },
                                    onDelete: viewModel.isCustomWorkout(workout) ? {
                                        workoutToDelete = workout
                                        showDeleteAlert = true
                                    } : nil
                                )
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Workout Store")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(Color.appText)
                }
            }
            .alert("Delete Workout", isPresented: $showDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    if let workout = workoutToDelete {
                        viewModel.deleteCustomWorkout(workout)
                    }
                }
            } message: {
                Text("Are you sure you want to delete this custom workout?")
            }
            .sheet(isPresented: $showCreateWorkout) {
                CreateWorkoutView(viewModel: viewModel)
                    .onDisappear {
                        viewModel.loadWorkouts()
                    }
            }
            .sheet(isPresented: $showWorkoutSession) {
                if let workout = selectedWorkout {
                    WorkoutSessionView(
                        viewModel: viewModel,
                        workout: workout,
                        onDismiss: {
                            viewModel.loadFocusBank()
                        }
                    )
                }
            }
            .overlay {
                if animateDeduction {
                    DeductionAnimationView()
                        .transition(.opacity)
                }
            }
        }
    }
    
    private func startWorkoutWithAnimation(_ workout: Workout) {
        // Анимация списания
        withAnimation(.easeInOut(duration: 0.3)) {
            animateDeduction = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            // Обновляем баланс перед проверкой
            viewModel.loadFocusBank()
            
            if viewModel.startWorkout(workout) {
                // Обновляем баланс через binding
                focusBank = viewModel.focusBank
                selectedWorkout = workout
                
                withAnimation {
                    animateDeduction = false
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    showWorkoutSession = true
                }
            } else {
                withAnimation {
                    animateDeduction = false
                }
            }
        }
    }
}

struct WorkoutStoreCard: View {
    let workout: Workout
    let canAfford: Bool
    let isCustom: Bool
    let onTap: () -> Void
    let onDelete: (() -> Void)?
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Button(action: onTap) {
                VStack(alignment: .leading, spacing: 12) {
                    // Иконка и сложность
                    HStack {
                        Image(systemName: "figure.run")
                            .font(.title)
                            .foregroundColor(canAfford ? Color.appButton : Color.gray)
                        
                        Spacer()
                        
                        if isCustom {
                            Text("Custom")
                                .font(.caption2)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 3)
                                .background(Color.appButton.opacity(0.8))
                                .cornerRadius(6)
                        }
                        
                        Text(workout.difficulty.rawValue)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                Color(workout.difficulty.color).opacity(canAfford ? 1.0 : 0.5)
                            )
                            .cornerRadius(8)
                    }
                    
                    // Название
                    Text(workout.name)
                        .font(.headline)
                        .foregroundColor(Color.appText)
                        .multilineTextAlignment(.leading)
                    
                    // Описание
                    Text(workout.description)
                        .font(.caption)
                        .foregroundColor(Color.appText.opacity(0.7))
                        .lineLimit(2)
                    
                    Spacer()
                    
                    // Информация о стоимости и длительности
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Image(systemName: "clock")
                                .font(.caption)
                            Text("\(workout.duration) min")
                                .font(.caption)
                        }
                        .foregroundColor(Color.appText.opacity(0.7))
                        
                        HStack {
                            Image(systemName: "brain.head.profile")
                                .font(.caption)
                            Text("\(workout.focusCost) min")
                                .font(.caption)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(canAfford ? Color.appButton : .red)
                    }
                }
                .padding()
                .frame(height: 200)
                .frame(maxWidth: .infinity)
                .background(
                    canAfford ?
                    Color.white :
                    Color.white.opacity(0.6)
                )
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            canAfford ? Color.appButton.opacity(0.3) : Color.gray.opacity(0.3),
                            lineWidth: 2
                        )
                )
                .shadow(
                    color: canAfford ?
                    Color.appButton.opacity(0.2) :
                    Color.black.opacity(0.1),
                    radius: canAfford ? 8 : 4,
                    x: 0,
                    y: 4
                )
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(!canAfford)
            
            // Кнопка удаления для кастомных тренировок
            if isCustom, let onDelete = onDelete {
                Button(action: {
                    onDelete()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundColor(.red)
                        .background(Color.white.clipShape(Circle()))
                }
                .padding(8)
            }
        }
    }
}

struct DeductionAnimationView: View {
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 1.0
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                Image(systemName: "minus.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.red)
                    .scaleEffect(scale)
                    .opacity(opacity)
                
                Text("Deducting Minutes")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            .padding(40)
            .background(Color.black.opacity(0.7))
            .cornerRadius(20)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.3)) {
                scale = 1.2
            }
            withAnimation(.easeOut(duration: 0.3).delay(0.1)) {
                opacity = 0
            }
        }
    }
}

