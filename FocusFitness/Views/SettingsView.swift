//
//  SettingsView.swift
//  FocusFitness
//
//  Created by Роман Главацкий on 14.11.2025.
//

import SwiftUI
import StoreKit

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var statsViewModel = StatisticsViewModel()
    @State private var showResetAlert = false
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Statistics")) {
                    HStack {
                        Text("Total Focus Time")
                        Spacer()
                        Text("\(statsViewModel.totalFocusMinutes) min")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Total Workout Time")
                        Spacer()
                        Text("\(statsViewModel.totalWorkoutMinutes) min")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Completed Sessions")
                        Spacer()
                        Text("\(statsViewModel.completedSessions)")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Completed Workouts")
                        Spacer()
                        Text("\(statsViewModel.completedWorkouts)")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section(header: Text("About")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    Button {
                        SKStoreReviewController.requestReview()
                    } label: {
                        Text("Rate on App Store")
                    }

                    Link("Privacy Policy", destination: URL(string: "https://www.termsfeed.com/live/dce92c5b-c48b-43e1-9f07-8d0c9552b8b8")!)
                    Link("Terms of Service", destination: URL(string: "https://www.termsfeed.com/live/12fb8265-15f0-463a-9229-3e1c85f88d71")!)
                }
                
                Section(header: Text("Danger Zone")) {
                    Button(role: .destructive, action: {
                        showResetAlert = true
                    }) {
                        Text("Reset All Data")
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("Reset All Data", isPresented: $showResetAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    resetAllData()
                }
            } message: {
                Text("This will delete all your progress, statistics, and focus bank. This action cannot be undone.")
            }
            .onAppear {
                statsViewModel.loadStatistics()
            }
        }
    }
    
    private func resetAllData() {
        let storageService = UserDefaultsService.shared
        storageService.userStats = UserStats()
        storageService.focusSessions = []
        statsViewModel.loadStatistics()
    }
}

