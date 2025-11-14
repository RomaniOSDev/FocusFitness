//
//  MainDashboardView.swift
//  FocusFitness
//
//  Created by Роман Главацкий on 14.11.2025.
//

import SwiftUI

struct MainDashboardView: View {
    @StateObject private var focusViewModel = FocusViewModel()
    @StateObject private var workoutViewModel = WorkoutViewModel()
    @State private var showFocusTimer = false
    @State private var showWorkoutStore = false
    @State private var showStatistics = false
    @State private var showSettings = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Фокус банк
                        FocusBankCard(focusBank: focusViewModel.focusBank)
                        
                        // Таймер фокуса
                        FocusTimerCard(
                            viewModel: focusViewModel,
                            onStart: {
                                showFocusTimer = true
                            }
                        )
                        
                        // Кнопка магазина тренировок
                        Button(action: {
                            showWorkoutStore = true
                        }) {
                            HStack {
                                Image(systemName: "cart.fill")
                                Text("Workout Store")
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.appButton)
                            .cornerRadius(12)
                        }
                        .padding(.horizontal)
                        
                        // Популярные тренировки
                        PopularWorkoutsSection(
                            workouts: Array(workoutViewModel.workouts.prefix(3)),
                            focusBank: focusViewModel.focusBank,
                            onWorkoutTap: { workout in
                                if workoutViewModel.canAffordWorkout(workout) {
                                    showWorkoutStore = true
                                }
                            }
                        )
                    }
                    .padding()
                }
            }
            .navigationTitle("Focus Fitness")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.light, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        showSettings = true
                    }) {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(Color.appText)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showStatistics = true
                    }) {
                        Image(systemName: "chart.bar.fill")
                            .foregroundColor(Color.appText)
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showStatistics) {
                StatisticsView()
                    .onAppear {
                        // Force refresh when sheet appears
                    }
            }
            .sheet(isPresented: $showFocusTimer) {
                FocusTimerView(viewModel: focusViewModel)
                    .onDisappear {
                        focusViewModel.loadFocusBank()
                        workoutViewModel.loadFocusBank()
                    }
            }
            .sheet(isPresented: $showWorkoutStore) {
                WorkoutStoreView(
                    viewModel: workoutViewModel,
                    focusBank: Binding(
                        get: { focusViewModel.focusBank },
                        set: { focusViewModel.focusBank = $0 }
                    )
                )
                .onDisappear {
                    focusViewModel.loadFocusBank()
                    workoutViewModel.loadFocusBank()
                }
            }
            .onAppear {
                focusViewModel.loadFocusBank()
                workoutViewModel.loadFocusBank()
            }
        }
    }
}

struct FocusBankCard: View {
    let focusBank: Int
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Focus Bank")
                .font(.headline)
                .foregroundColor(Color.appText)
            
            Text("\(focusBank) min")
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(Color.appText)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}

struct FocusTimerCard: View {
    @ObservedObject var viewModel: FocusViewModel
    let onStart: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            if viewModel.isRunning {
                // Circular progress
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 12)
                        .frame(width: 200, height: 200)
                    
                    Circle()
                        .trim(from: 0, to: 1 - (viewModel.currentTime / (25 * 60)))
                        .stroke(Color.appButton, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                        .frame(width: 200, height: 200)
                        .rotationEffect(.degrees(-90))
                        .animation(.linear, value: viewModel.currentTime)
                    
                    VStack {
                        Text(viewModel.formatTime(viewModel.currentTime))
                            .font(.system(size: 42, weight: .bold))
                            .foregroundColor(Color.appText)
                        
                        Text("Focus")
                            .font(.caption)
                            .foregroundColor(Color.appText)
                    }
                }
                
                HStack(spacing: 20) {
                    if viewModel.isPaused {
                        Button(action: {
                            viewModel.resumeFocus()
                        }) {
                            Image(systemName: "play.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                                .frame(width: 60, height: 60)
                                .background(Color.appButton)
                                .clipShape(Circle())
                        }
                    } else {
                        Button(action: {
                            viewModel.pauseFocus()
                        }) {
                            Image(systemName: "pause.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                                .frame(width: 60, height: 60)
                                .background(Color.appButton)
                                .clipShape(Circle())
                        }
                    }
                    
                    Button(action: {
                        viewModel.stopFocus()
                    }) {
                        Image(systemName: "stop.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(width: 60, height: 60)
                            .background(Color.appButton)
                            .clipShape(Circle())
                    }
                }
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "timer")
                        .font(.system(size: 60))
                        .foregroundColor(Color.appButton)
                    
                    Text("Ready to Focus")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(Color.appText)
                    
                    Button(action: onStart) {
                        Text("Start Focus")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.appButton)
                            .cornerRadius(12)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}

struct PopularWorkoutsSection: View {
    let workouts: [Workout]
    let focusBank: Int
    let onWorkoutTap: (Workout) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Popular Workouts")
                .font(.headline)
                .foregroundColor(Color.appText)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(workouts) { workout in
                        WorkoutCard(workout: workout, canAfford: focusBank >= workout.focusCost)
                            .onTapGesture {
                                onWorkoutTap(workout)
                            }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

struct WorkoutCard: View {
    let workout: Workout
    let canAfford: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(workout.name)
                .font(.headline)
                .foregroundColor(Color.appText)
            
            Text(workout.description)
                .font(.caption)
                .foregroundColor(Color.appText.opacity(0.7))
            
            HStack {
                Label("\(workout.duration) min", systemImage: "clock")
                    .font(.caption)
                
                Spacer()
                
                Label("\(workout.focusCost) min", systemImage: "brain.head.profile")
                    .font(.caption)
            }
            .foregroundColor(Color.appText.opacity(0.7))
        }
        .padding()
        .frame(width: 200)
        .background(canAfford ? Color.appButton.opacity(0.1) : Color.gray.opacity(0.1))
        .cornerRadius(12)
        .opacity(canAfford ? 1.0 : 0.6)
    }
}

