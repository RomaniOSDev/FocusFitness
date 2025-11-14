//
//  OnboardingView.swift
//  FocusFitness
//
//  Created by Роман Главацкий on 14.11.2025.
//

import SwiftUI

struct OnboardingView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @State private var currentPage = 0
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.6)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            TabView(selection: $currentPage) {
                OnboardingPageView(
                    title: "Focus = Workouts",
                    description: "Accumulated focus minutes convert into workouts. Double progress: productivity + fitness!",
                    imageName: "brain.head.profile",
                    pageIndex: 0
                )
                .tag(0)
                
                OnboardingPageView(
                    title: "Start Right Now",
                    description: "Launch the focus timer, accumulate minutes and exchange them for workouts. Health and productivity in one app!",
                    imageName: "figure.run",
                    pageIndex: 1
                )
                .tag(1)
                
                GiftPageView(
                    viewModel: viewModel,
                    pageIndex: 2
                )
                .tag(2)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            
            VStack {
                Spacer()
                
                if currentPage == 2 {
                    Button(action: {
                        viewModel.completeOnboarding()
                    }) {
                        Text("Get Started")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                            .padding(.horizontal, 40)
                            .padding(.bottom, 50)
                    }
                }
            }
        }
    }
}

struct OnboardingPageView: View {
    let title: String
    let description: String
    let imageName: String
    let pageIndex: Int
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .foregroundColor(.white)
            
            Text(title)
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Text(description)
                .font(.system(size: 18))
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .lineSpacing(4)
            
            Spacer()
        }
    }
}

struct GiftPageView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    let pageIndex: Int
    @State private var animateGift = false
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 200, height: 200)
                
                Image(systemName: "gift.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .foregroundColor(.white)
                    .scaleEffect(animateGift ? 1.2 : 1.0)
                    .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: animateGift)
            }
            
            Text("Welcome Gift!")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            VStack(spacing: 12) {
                Text("25 minutes")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.yellow)
                
                Text("in your focus bank")
                    .font(.system(size: 18))
                    .foregroundColor(.white.opacity(0.9))
            }
            
            Text("Start your journey with a bonus! Use these minutes to try your first workout.")
                .font(.system(size: 16))
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .lineSpacing(4)
            
            Spacer()
        }
        .onAppear {
            animateGift = true
        }
    }
}

