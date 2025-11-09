//
//  LoginView.swift
//  TimeEgg
//
//  Created by donghyeon choi on 10/4/25.
//

import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @StateObject private var authService = FirebaseAuthService()
    @StateObject private var googleSignInService = GoogleSignInService()
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var navigateToMainView = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 배경
                Color(red: 0.97, green: 0.98, blue: 1)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    Spacer()
                    
                    // 상단 로고
                    Image("textLogo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: geometry.size.height * 0.05)

                    Image("colorEgg")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: geometry.size.height * 0.3)
                    
                    Spacer()
                    
                    // Google 로그인 버튼
                    VStack(spacing: geometry.size.height * 0.03) {
                        Text("Google 계정으로 시작하기")
                            .font(Font.custom("Inter", size: geometry.size.width * 0.042).weight(.medium))
                            .foregroundColor(Color(red: 0.24, green: 0.24, blue: 0.24))
                            .padding(.bottom, geometry.size.height * 0.01)
                        
                        Button(action: {
                            handleGoogleSignIn()
                        }) {
                            HStack(spacing: geometry.size.width * 0.04) {
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.9)
                                } else {
                                    // Google 아이콘
                                    Image(systemName: "globe")
                                        .font(.system(size: geometry.size.width * 0.05, weight: .medium))
                                        .foregroundColor(.white)
                                }
                                
                                Text(isLoading ? "로그인 중..." : "Google로 로그인")
                                    .font(Font.custom("Inter", size: geometry.size.width * 0.04).weight(.semibold))
                                    .foregroundColor(.white)
                            }
                            .frame(width: geometry.size.width * 0.85, height: geometry.size.height * 0.07)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 0.26, green: 0.52, blue: 0.96),
                                        Color(red: 0.20, green: 0.40, blue: 0.85)
                                    ]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(geometry.size.width * 0.06)
                            .shadow(
                                color: Color(red: 0.26, green: 0.52, blue: 0.96, opacity: 0.3),
                                radius: geometry.size.width * 0.05, y: geometry.size.height * 0.01
                            )
                        }
                        .disabled(isLoading)
                    }
                    .frame(width: geometry.size.width * 0.89)
                    
                    Spacer()
                }
            }
        }
        .onChange(of: authService.isAuthenticated) { oldValue, newValue in
            if newValue {
                navigateToMainView = true
            }
        }
        .alert("알림", isPresented: $showAlert) {
            Button("확인") { }
        } message: {
            Text(alertMessage)
        }
        .navigationDestination(isPresented: $navigateToMainView) {
            MainView()
        }
    }
    
    // MARK: - Google Sign-In
    
    private func handleGoogleSignIn() {
        isLoading = true
        
        Task {
            let success = await googleSignInService.signInWithGoogle()
            
            await MainActor.run {
                isLoading = false
                
                if success {
                    // FirebaseAuthService의 isAuthenticated가 변경되면 자동으로 navigateToMainView가 true가 됨
                    // 하지만 GoogleSignInService를 사용하는 경우를 위해 명시적으로 설정
                    if authService.isAuthenticated {
                        navigateToMainView = true
                    } else {
                        // Google Sign-In이 성공했지만 FirebaseAuthService가 아직 업데이트되지 않은 경우
                        // 약간의 지연 후 다시 확인
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                            if authService.isAuthenticated {
                                self.navigateToMainView = true
                            }
                        })
                    }
                } else {
                    alertMessage = googleSignInService.errorMessage ?? "Google 로그인에 실패했습니다."
                    showAlert = true
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        LoginView()
    }
}
