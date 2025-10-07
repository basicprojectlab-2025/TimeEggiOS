//
//  SignUpView.swift
//  TimeEgg
//
//  Created by donghyeon choi on 10/6/25.
//

import SwiftUI
import FirebaseAuth

struct SignUpView: View {
    @StateObject private var authService = FirebaseAuthService()
    @State private var username = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 배경
                Color(red: 0.97, green: 0.98, blue: 1)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // 상단 Skip 버튼
                    HStack {
                        Spacer()
                        Button("Skip") {
                            // Skip 액션
                        }
                        .font(.custom("Sk-Modernist", size: 14))
                        .underline()
                        .foregroundColor(Color(red: 0.98, green: 0.35, blue: 0.12))
                        .padding(.trailing, geometry.size.width * 0.05)
                        .padding(.top, geometry.size.height * 0.05)
                    }
                    
                    Spacer()
                    
                    // TimeEgg 로고
                    VStack(spacing: geometry.size.height * 0.02) {
                        // 로고 배경
                        ZStack {
                            Circle()
                                .fill(Color(red: 0.50, green: 0.23, blue: 0.27).opacity(0.50))
                                .frame(width: geometry.size.width * 0.56, height: geometry.size.width * 0.56)
                            
                            // 여기에 실제 로고 이미지가 들어갈 수 있습니다
                            Image(systemName: "egg.fill")
                                .font(.system(size: geometry.size.width * 0.2))
                                .foregroundColor(.white)
                        }
                        
                        Text("TimeEgg")
                            .font(.custom("Edu AU VIC WA NT Hand", size: 30).weight(.bold))
                            .foregroundColor(Color(red: 0.20, green: 0.20, blue: 0.20))
                    }
                    .padding(.bottom, geometry.size.height * 0.05)
                    
                    // 입력 필드들
                    VStack(spacing: geometry.size.height * 0.025) {
                        // 아이디 입력 필드
                        CustomInputField(
                            text: $username,
                            placeholder: "Enter username",
                            label: "아이디",
                            isSecure: false
                        )
                        
                        // 비밀번호 입력 필드
                        CustomInputField(
                            text: $password,
                            placeholder: "Enter password",
                            label: "비밀번호",
                            isSecure: true
                        )
                        
                        // 비밀번호 확인 입력 필드
                        CustomInputField(
                            text: $confirmPassword,
                            placeholder: "Confirm Password",
                            label: "비밀번호 확인",
                            isSecure: true
                        )
                    }
                    .padding(.horizontal, geometry.size.width * 0.05)
                    
                    Spacer()
                    
                    // 회원가입 버튼
                    Button(action: handleSignUp) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            }
                            
                            Text("회원가입")
                                .font(.custom("Inter", size: 14).weight(.bold))
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, geometry.size.height * 0.02)
                        .background(Color(red: 0.98, green: 0.53, blue: 0.12))
                        .cornerRadius(20)
                        .shadow(
                            color: Color(red: 0.79, green: 0.26, blue: 0.07, opacity: 0.10),
                            radius: 30,
                            y: 10
                        )
                    }
                    .disabled(isLoading)
                    .padding(.horizontal, geometry.size.width * 0.05)
                    .padding(.bottom, geometry.size.height * 0.1)
                }
            }
        }
        .alert("알림", isPresented: $showAlert) {
            Button("확인") { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func handleSignUp() {
        guard validateInputs() else { return }
        
        isLoading = true
        
        authService.signUp(email: username, password: password) { success, error in
            isLoading = false
            if success {
                alertMessage = "회원가입이 완료되었습니다!"
                showAlert = true
            } else {
                alertMessage = error ?? "회원가입에 실패했습니다."
                showAlert = true
            }
        }
    }
    
    private func validateInputs() -> Bool {
        if username.isEmpty || password.isEmpty || confirmPassword.isEmpty {
            alertMessage = "모든 필드를 입력해주세요."
            showAlert = true
            return false
        }
        
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
        
        return true
    }
}

// MARK: - CustomInputField
struct CustomInputField: View {
    @Binding var text: String
    let placeholder: String
    let label: String
    let isSecure: Bool
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading, spacing: geometry.size.height * 0.01) {
                // 라벨
                Text(label)
                    .font(.custom("Inter", size: 12))
                    .foregroundColor(Color(red: 0.24, green: 0.24, blue: 0.24))
                    .padding(.leading, geometry.size.width * 0.02)
                
                // 입력 필드
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(.white)
                        .frame(height: 50)
                        .cornerRadius(15)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .inset(by: 0.5)
                                .stroke(Color(red: 0.87, green: 0.89, blue: 0.90), lineWidth: 0.5)
                        )
                    
                    if text.isEmpty {
                        Text(placeholder)
                            .font(.custom("Inter", size: 14))
                            .foregroundColor(Color(red: 0.67, green: 0.67, blue: 0.68))
                            .padding(.leading, geometry.size.width * 0.04)
                    }
                    
                    if isSecure {
                        SecureField("", text: $text)
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding(.horizontal, geometry.size.width * 0.04)
                    } else {
                        TextField("", text: $text)
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding(.horizontal, geometry.size.width * 0.04)
                    }
                }
            }
        }
        .frame(height: 76)
    }
}

#Preview {
    SignUpView()
        .onAppear {
            // Preview용 초기화
        }
}
