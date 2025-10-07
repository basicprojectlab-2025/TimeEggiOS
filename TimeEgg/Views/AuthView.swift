//
//  AuthView.swift
//  TimeEgg
//
//  Created by donghyeon choi on 10/6/25.
//

import SwiftUI
import FirebaseAuth

struct AuthView: View {
    @StateObject private var authService = FirebaseAuthService()
    @State private var isLoginMode = true
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var displayName = ""
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 배경
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.98, green: 0.53, blue: 0.12),
                        Color(red: 0.85, green: 0.35, blue: 0.15)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: geometry.size.height * 0.04) {
                        // 로고
                        VStack(spacing: geometry.size.height * 0.02) {
                            Image("colorEgg")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: geometry.size.width * 0.2)
                            
                            Image("textLogo")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: geometry.size.width * 0.4)
                        }
                        .padding(.top, geometry.size.height * 0.08)
                        
                        // 인증 폼
                        VStack(spacing: geometry.size.height * 0.025) {
                            // 모드 전환 버튼
                            HStack(spacing: 0) {
                                Button(action: { 
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        isLoginMode = true
                                    }
                                }) {
                                    Text("로그인")
                                        .font(.system(size: geometry.size.width * 0.045, weight: .semibold))
                                        .foregroundColor(isLoginMode ? .white : .white.opacity(0.7))
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, geometry.size.height * 0.015)
                                        .background(
                                            isLoginMode ? 
                                            Color.white.opacity(0.2) : 
                                            Color.clear
                                        )
                                        .cornerRadius(geometry.size.width * 0.025)
                                }
                                
                                Button(action: { 
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        isLoginMode = false
                                    }
                                }) {
                                    Text("회원가입")
                                        .font(.system(size: geometry.size.width * 0.045, weight: .semibold))
                                        .foregroundColor(!isLoginMode ? .white : .white.opacity(0.7))
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, geometry.size.height * 0.015)
                                        .background(
                                            !isLoginMode ? 
                                            Color.white.opacity(0.2) : 
                                            Color.clear
                                        )
                                        .cornerRadius(geometry.size.width * 0.025)
                                }
                            }
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(geometry.size.width * 0.025)
                            .padding(.horizontal, geometry.size.width * 0.08)
                            
                            // 입력 필드들
                            VStack(spacing: geometry.size.height * 0.02) {
                                // 이메일
                                CustomTextField(
                                    text: $email,
                                    placeholder: "이메일",
                                    isSecure: false
                                )
                                
                                // 비밀번호
                                CustomTextField(
                                    text: $password,
                                    placeholder: "비밀번호",
                                    isSecure: true
                                )
                                
                                // 회원가입 모드일 때만 표시
                                if !isLoginMode {
                                    // 비밀번호 확인
                                    CustomTextField(
                                        text: $confirmPassword,
                                        placeholder: "비밀번호 확인",
                                        isSecure: true
                                    )
                                    
                                    // 이름
                                    CustomTextField(
                                        text: $displayName,
                                        placeholder: "이름",
                                        isSecure: false
                                    )
                                }
                            }
                            .padding(.horizontal, geometry.size.width * 0.08)
                            
                            // 로그인/회원가입 버튼
                            Button(action: handleAuth) {
                                HStack {
                                    if isLoading {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .scaleEffect(0.8)
                                    }
                                    
                                    Text(isLoginMode ? "로그인" : "회원가입")
                                        .font(.system(size: geometry.size.width * 0.045, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, geometry.size.height * 0.02)
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(geometry.size.width * 0.025)
                            }
                            .disabled(isLoading)
                            .padding(.horizontal, geometry.size.width * 0.08)
                            
                            // 비밀번호 재설정 (로그인 모드일 때만)
                            if isLoginMode {
                                Button(action: {
                                    showPasswordResetAlert()
                                }) {
                                    Text("비밀번호를 잊으셨나요?")
                                        .font(.system(size: geometry.size.width * 0.035))
                                        .foregroundColor(.white.opacity(0.8))
                                        .underline()
                                }
                                .padding(.top, geometry.size.height * 0.01)
                            }
                        }
                        .padding(.vertical, geometry.size.height * 0.03)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(geometry.size.width * 0.05)
                        .padding(.horizontal, geometry.size.width * 0.06)
                        
                        Spacer()
                    }
                }
            }
        }
        .alert("알림", isPresented: $showAlert) {
            Button("확인") { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func handleAuth() {
        guard validateInputs() else { return }
        
        isLoading = true
        
        if isLoginMode {
            // 로그인
            authService.signIn(email: email, password: password) { success, error in
                isLoading = false
                if !success {
                    alertMessage = error ?? "로그인에 실패했습니다."
                    showAlert = true
                }
            }
        } else {
            // 회원가입
            authService.signUp(email: email, password: password) { success, error in
                isLoading = false
                if success {
                    // 회원가입 성공 시 이름 업데이트
                    if !displayName.isEmpty {
                        authService.updateUserProfile(displayName: displayName) { _, _ in }
                    }
                    alertMessage = "회원가입이 완료되었습니다!"
                    showAlert = true
                } else {
                    alertMessage = error ?? "회원가입에 실패했습니다."
                    showAlert = true
                }
            }
        }
    }
    
    private func validateInputs() -> Bool {
        if email.isEmpty || password.isEmpty {
            alertMessage = "이메일과 비밀번호를 입력해주세요."
            showAlert = true
            return false
        }
        
        if !isLoginMode {
            if password != confirmPassword {
                alertMessage = "비밀번호가 일치하지 않습니다."
                showAlert = true
                return false
            }
            
            if password.count < 6 {
                alertMessage = "비밀번호는 6자 이상이어야 합니다."
                showAlert = true
                return false
            }
        }
        
        return true
    }
    
    private func showPasswordResetAlert() {
        let alert = UIAlertController(title: "비밀번호 재설정", message: "이메일을 입력해주세요.", preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "이메일"
            textField.text = email
        }
        
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "전송", style: .default) { _ in
            if let emailText = alert.textFields?.first?.text, !emailText.isEmpty {
                authService.resetPassword(email: emailText) { success, error in
                    DispatchQueue.main.async {
                        if success {
                            alertMessage = "비밀번호 재설정 이메일을 전송했습니다."
                        } else {
                            alertMessage = error ?? "이메일 전송에 실패했습니다."
                        }
                        showAlert = true
                    }
                }
            }
        })
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(alert, animated: true)
        }
    }
}

// MARK: - CustomTextField
struct CustomTextField: View {
    @Binding var text: String
    let placeholder: String
    let isSecure: Bool
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                if text.isEmpty {
                    Text(placeholder)
                        .foregroundColor(.white.opacity(0.6))
                        .padding(.leading, geometry.size.width * 0.04)
                }
                
                if isSecure {
                    SecureField("", text: $text)
                        .textFieldStyle(PlainTextFieldStyle())
                        .foregroundColor(.white)
                        .padding(.horizontal, geometry.size.width * 0.04)
                        .padding(.vertical, geometry.size.height * 0.02)
                } else {
                    TextField("", text: $text)
                        .textFieldStyle(PlainTextFieldStyle())
                        .foregroundColor(.white)
                        .padding(.horizontal, geometry.size.width * 0.04)
                        .padding(.vertical, geometry.size.height * 0.02)
                }
            }
            .background(Color.white.opacity(0.1))
            .cornerRadius(geometry.size.width * 0.025)
        }
        .frame(height: 50)
    }
}

#Preview {
    AuthView()
}
