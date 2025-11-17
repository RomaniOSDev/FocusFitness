//
//  FocusTimerView.swift
//  FocusFitness
//
//  Created by Роман Главацкий on 14.11.2025.
//

import SwiftUI

struct FocusTimerView: View {
    @ObservedObject var viewModel: FocusViewModel
    @Environment(\.dismiss) var dismiss
    @State private var selectedDuration: Int = 25
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            ScrollView{
                VStack(spacing: 40) {
                    Spacer()
                    if !viewModel.isRunning {
                        // Выбор длительности
                        VStack(spacing: 30) {
                            // Заголовок и иконка
                            VStack(spacing: 16) {
                                ZStack {
                                    Circle()
                                        .fill(Color.appButton.opacity(0.2))
                                        .frame(width: 100, height: 100)
                                    
                                    Image(systemName: "brain.head.profile")
                                        .font(.system(size: 50))
                                        .foregroundColor(Color.appButton)
                                }
                                
                                Text("Select Focus Duration")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(Color.appText)
                                
                                Text("Choose how long you want to focus")
                                    .font(.subheadline)
                                    .foregroundColor(Color.appText.opacity(0.7))
                                    .multilineTextAlignment(.center)
                            }
                            .padding(.top, 20)
                            
                            // Карточки выбора длительности
                            VStack(spacing: 16) {
                                DurationCard(
                                    duration: 15,
                                    title: "Quick Focus",
                                    description: "Perfect for short breaks",
                                    icon: "bolt.fill",
                                    isSelected: selectedDuration == 15,
                                    color: Color.appButton
                                ) {
                                    selectedDuration = 15
                                }
                                
                                DurationCard(
                                    duration: 25,
                                    title: "Pomodoro",
                                    description: "Classic focus session",
                                    icon: "timer",
                                    isSelected: selectedDuration == 25,
                                    color: Color.appButton
                                ) {
                                    selectedDuration = 25
                                }
                                
                                DurationCard(
                                    duration: 45,
                                    title: "Deep Work",
                                    description: "Extended concentration",
                                    icon: "brain",
                                    isSelected: selectedDuration == 45,
                                    color: Color.appButton
                                ) {
                                    selectedDuration = 45
                                }
                                
                                DurationCard(
                                    duration: 60,
                                    title: "Intensive",
                                    description: "Maximum productivity",
                                    icon: "flame.fill",
                                    isSelected: selectedDuration == 60,
                                    color: Color.appButton
                                ) {
                                    selectedDuration = 60
                                }
                            }
                            .padding(.horizontal, 24)
                            
                            // Кнопка старта
                            Button(action: {
                                viewModel.startFocus(duration: TimeInterval(selectedDuration * 60))
                            }) {
                                HStack {
                                    Image(systemName: "play.circle.fill")
                                        .font(.title2)
                                    Text("Start Focus Session")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.appButton)
                                .cornerRadius(16)
                            }
                            .padding(.horizontal, 24)
                            .padding(.top, 8)
                        }
                    } else {
                        // Таймер
                        VStack(spacing: 30) {
                            // Circular progress
                            ZStack {
                                Circle()
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 20)
                                    .frame(width: 280, height: 280)
                                
                                Circle()
                                    .trim(from: 0, to: 1 - (viewModel.currentTime / (TimeInterval(selectedDuration * 60))))
                                    .stroke(Color.appButton, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                                    .frame(width: 280, height: 280)
                                    .rotationEffect(.degrees(-90))
                                    .animation(.linear, value: viewModel.currentTime)
                                
                                VStack {
                                    Text(viewModel.formatTime(viewModel.currentTime))
                                        .font(.system(size: 64, weight: .bold))
                                        .foregroundColor(Color.appText)
                                    
                                    Text("Focus: \(selectedDuration) min")
                                        .font(.title3)
                                        .foregroundColor(Color.appText.opacity(0.7))
                                }
                            }
                            
                            // Кнопки управления
                            HStack(spacing: 30) {
                                if viewModel.isPaused {
                                    Button(action: {
                                        viewModel.resumeFocus()
                                    }) {
                                        VStack {
                                            Image(systemName: "play.fill")
                                                .font(.title)
                                            Text("Resume")
                                                .font(.caption)
                                        }
                                        .foregroundColor(.white)
                                        .frame(width: 100, height: 100)
                                        .background(Color.appButton)
                                        .clipShape(Circle())
                                    }
                                } else {
                                    Button(action: {
                                        viewModel.pauseFocus()
                                    }) {
                                        VStack {
                                            Image(systemName: "pause.fill")
                                                .font(.title)
                                            Text("Pause")
                                                .font(.caption)
                                        }
                                        .foregroundColor(.white)
                                        .frame(width: 100, height: 100)
                                        .background(Color.appButton)
                                        .clipShape(Circle())
                                    }
                                }
                                
                                Button(action: {
                                    viewModel.stopFocus()
                                    dismiss()
                                }) {
                                    VStack {
                                        Image(systemName: "stop.fill")
                                            .font(.title)
                                        Text("Stop")
                                            .font(.caption)
                                    }
                                    .foregroundColor(.white)
                                    .frame(width: 100, height: 100)
                                    .background(Color.appButton)
                                    .clipShape(Circle())
                                }
                            }
                        }
                    }
                    
                    Spacer()
                }
                .padding()
            }
        }
        .onDisappear {
            if viewModel.isRunning {
                viewModel.stopFocus()
            }
        }
    }
}

struct DurationCard: View {
    let duration: Int
    let title: String
    let description: String
    let icon: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Иконка
                ZStack {
                    Circle()
                        .fill(isSelected ? color.opacity(0.2) : Color.gray.opacity(0.1))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundColor(isSelected ? color : Color.appText.opacity(0.5))
                }
                
                // Текст
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("\(duration) min")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(Color.appText)
                        
                        if isSelected {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(color)
                                .font(.title3)
                        }
                    }
                    
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(Color.appText.opacity(0.8))
                    
                    Text(description)
                        .font(.caption)
                        .foregroundColor(Color.appText.opacity(0.6))
                }
                
                Spacer()
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? color.opacity(0.1) : Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? color : Color.gray.opacity(0.2), lineWidth: isSelected ? 2 : 1)
                    )
            )
            .shadow(color: isSelected ? color.opacity(0.2) : Color.black.opacity(0.05), radius: isSelected ? 8 : 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

