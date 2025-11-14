//
//  StatisticsView.swift
//  FocusFitness
//
//  Created by Роман Главацкий on 14.11.2025.
//

import SwiftUI

struct StatisticsView: View {
    @StateObject private var viewModel = StatisticsViewModel()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Круговые диаграммы
                    HStack(spacing: 20) {
                        FocusPieChart(
                            focusMinutes: viewModel.totalFocusMinutes,
                            totalMinutes: viewModel.totalMinutes
                        )
                        
                        WorkoutPieChart(
                            workoutMinutes: viewModel.totalWorkoutMinutes,
                            totalMinutes: viewModel.totalMinutes
                        )
                    }
                    .padding()
                    
                    // Статистика
                    VStack(spacing: 16) {
                        StatCard(
                            title: "Total Focus",
                            value: "\(viewModel.totalFocusMinutes) min",
                            icon: "brain.head.profile",
                            color: .blue
                        )
                        
                        StatCard(
                            title: "Total Workouts",
                            value: "\(viewModel.totalWorkoutMinutes) min",
                            icon: "figure.run",
                            color: .green
                        )
                        
                        StatCard(
                            title: "Completed Sessions",
                            value: "\(viewModel.completedSessions)",
                            icon: "checkmark.circle.fill",
                            color: .orange
                        )
                        
                        StatCard(
                            title: "Completed Workouts",
                            value: "\(viewModel.completedWorkouts)",
                            icon: "trophy.fill",
                            color: .purple
                        )
                    }
                    .padding(.horizontal)
                    
                    // График за неделю
                    if !viewModel.weeklyStats.isEmpty {
                        WeeklyChartView(stats: viewModel.weeklyStats)
                            .padding()
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Statistics")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                viewModel.loadStatistics()
            }
            .refreshable {
                viewModel.loadStatistics()
            }
        }
    }
}

struct FocusPieChart: View {
    let focusMinutes: Int
    let totalMinutes: Int
    
    var percentage: Double {
        guard totalMinutes > 0 else { return 0 }
        return Double(focusMinutes) / Double(totalMinutes) * 100
    }
    
    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 20)
                    .frame(width: 150, height: 150)
                
                Circle()
                    .trim(from: 0, to: percentage / 100)
                    .stroke(Color.blue, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                    .frame(width: 150, height: 150)
                    .rotationEffect(.degrees(-90))
                
                VStack {
                    Text("\(Int(percentage))%")
                        .font(.title)
                        .fontWeight(.bold)
                    Text("Focus")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Text("\(focusMinutes) min")
                .font(.headline)
                .foregroundColor(.blue)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }
}

struct WorkoutPieChart: View {
    let workoutMinutes: Int
    let totalMinutes: Int
    
    var percentage: Double {
        guard totalMinutes > 0 else { return 0 }
        return Double(workoutMinutes) / Double(totalMinutes) * 100
    }
    
    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 20)
                    .frame(width: 150, height: 150)
                
                Circle()
                    .trim(from: 0, to: percentage / 100)
                    .stroke(Color.green, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                    .frame(width: 150, height: 150)
                    .rotationEffect(.degrees(-90))
                
                VStack {
                    Text("\(Int(percentage))%")
                        .font(.title)
                        .fontWeight(.bold)
                    Text("Workouts")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Text("\(workoutMinutes) min")
                .font(.headline)
                .foregroundColor(.green)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 50)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

struct WeeklyChartView: View {
    let stats: [DailyStat]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Weekly Progress")
                .font(.headline)
                .padding(.horizontal)
            
            VStack(spacing: 8) {
                ForEach(stats) { stat in
                    HStack {
                        Text(dayName(for: stat.date))
                            .font(.caption)
                            .frame(width: 60, alignment: .leading)
                        
                        HStack(spacing: 4) {
                            // Фокус
                            if stat.focusMinutes > 0 {
                                Rectangle()
                                    .fill(Color.blue)
                                    .frame(width: CGFloat(stat.focusMinutes) * 2, height: 20)
                            }
                            
                            // Тренировки
                            if stat.workoutMinutes > 0 {
                                Rectangle()
                                    .fill(Color.green)
                                    .frame(width: CGFloat(stat.workoutMinutes) * 2, height: 20)
                            }
                        }
                        
                        Spacer()
                        
                        Text("\(stat.focusMinutes + stat.workoutMinutes) min")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
        }
    }
    
    private func dayName(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter.string(from: date)
    }
}

