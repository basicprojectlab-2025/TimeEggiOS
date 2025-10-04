//
//  LoginView.swift
//  TimeEgg
//
//  Created by donghyeon choi on 10/4/25.
//

import SwiftUI

struct LoginView: View {
    @State private var username = ""
    @State private var password = ""
    
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
                    
                    Spacer()
                    
                    // 입력 필드
                    VStack(spacing: geometry.size.height * 0.02) {
                        
                        // 아이디 입력 필드
                        VStack(alignment: .leading, spacing: geometry.size.height * 0.01) {
                            Text("아이디")
                                .font(Font.custom("Inter", size: geometry.size.width * 0.032))
                                .foregroundColor(Color(red: 0.24, green: 0.24, blue: 0.24))
                            
                            HStack {
                                Image(systemName: "person")
                                    .foregroundColor(Color(red: 0.67, green: 0.67, blue: 0.68))
                                    .frame(width: geometry.size.width * 0.064, height: geometry.size.width * 0.064)
                                
                                // Placeholder 커스텀
                                ZStack(alignment: .leading) {
                                    if username.isEmpty {
                                        Text("Enter your id")
                                            .font(Font.custom("Inter", size: geometry.size.width * 0.037))
                                            .foregroundColor(Color.gray.opacity(0.6))
                                    }
                                    TextField("", text: $username)
                                        .font(Font.custom("Inter", size: geometry.size.width * 0.037))
                                        .foregroundColor(.black)
                                        .autocapitalization(.none)
                                        .disableAutocorrection(true)
                                }
                            }
                            .padding(EdgeInsets(
                                top: geometry.size.height * 0.015,
                                leading: geometry.size.width * 0.043,
                                bottom: geometry.size.height * 0.015,
                                trailing: geometry.size.width * 0.043
                            ))
                            .frame(height: geometry.size.height * 0.062)
                            .background(.white)
                            .cornerRadius(geometry.size.width * 0.04)
                            .overlay(
                                RoundedRectangle(cornerRadius: geometry.size.width * 0.04)
                                    .stroke(Color(red: 0.87, green: 0.89, blue: 0.90), lineWidth: 0.50)
                            )
                        }
                        
                        // 비밀번호 입력 필드
                        VStack(alignment: .leading, spacing: geometry.size.height * 0.01) {
                            Text("비밀번호")
                                .font(Font.custom("Inter", size: geometry.size.width * 0.032))
                                .foregroundColor(Color(red: 0.24, green: 0.24, blue: 0.24))
                            
                            HStack {
                                Image(systemName: "lock")
                                    .foregroundColor(Color(red: 0.67, green: 0.67, blue: 0.68))
                                    .frame(width: geometry.size.width * 0.064, height: geometry.size.width * 0.064)
                                
                                // Placeholder 커스텀
                                ZStack(alignment: .leading) {
                                    if password.isEmpty {
                                        Text("Enter your password")
                                            .font(Font.custom("Inter", size: geometry.size.width * 0.037))
                                            .foregroundColor(Color.gray.opacity(0.6))
                                    }
                                    SecureField("", text: $password)
                                        .font(Font.custom("Inter", size: geometry.size.width * 0.037))
                                        .foregroundColor(.black)
                                }
                            }
                            .padding(EdgeInsets(
                                top: geometry.size.height * 0.015,
                                leading: geometry.size.width * 0.043,
                                bottom: geometry.size.height * 0.015,
                                trailing: geometry.size.width * 0.043
                            ))
                            .frame(height: geometry.size.height * 0.062)
                            .background(.white)
                            .cornerRadius(geometry.size.width * 0.04)
                            .overlay(
                                RoundedRectangle(cornerRadius: geometry.size.width * 0.04)
                                    .stroke(Color(red: 0.87, green: 0.89, blue: 0.90), lineWidth: 0.50)
                            )
                        }
                    }
                    .frame(width: geometry.size.width * 0.89)
                    
                    Spacer()
                    
                    // 버튼 영역
                    VStack(spacing: geometry.size.height * 0.02) {
                        Button(action: {
                            // 로그인 액션
                        }) {
                            Text("로그인")
                                .font(Font.custom("Inter", size: geometry.size.width * 0.037).weight(.bold))
                                .foregroundColor(Color(red: 0.98, green: 0.35, blue: 0.12))
                                .frame(width: geometry.size.width * 0.89, height: geometry.size.height * 0.062)
                                .background(.white)
                                .cornerRadius(geometry.size.width * 0.053)
                                .overlay(
                                    RoundedRectangle(cornerRadius: geometry.size.width * 0.053)
                                        .stroke(Color(red: 0.93, green: 0.41, blue: 0.27), lineWidth: 0.50)
                                )
                        }
                        
                        Button(action: {
                            // 회원가입 액션
                        }) {
                            Text("회원가입")
                                .font(Font.custom("Inter", size: geometry.size.width * 0.037).weight(.bold))
                                .foregroundColor(.white)
                                .frame(width: geometry.size.width * 0.89, height: geometry.size.height * 0.062)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(red: 0.98, green: 0.53, blue: 0.12),
                                            Color(red: 0.79, green: 0.26, blue: 0.07)
                                        ]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(geometry.size.width * 0.053)
                                .shadow(
                                    color: Color(red: 0.79, green: 0.26, blue: 0.07, opacity: 0.10),
                                    radius: geometry.size.width * 0.08, y: geometry.size.height * 0.012
                                )
                        }
                        
                        Button(action: {
                            // TODO: Google 로그인 액션
                        }) {
                            HStack {
                                ZStack {
                                    Circle()
                                        .fill(.white)
                                        .frame(width: geometry.size.width * 0.064, height: geometry.size.width * 0.064)
                                    Text("G")
                                        .font(.system(size: geometry.size.width * 0.032, weight: .bold))
                                        .foregroundColor(.blue)
                                }
                                
                                Text("Sign-in with Google")
                                    .font(Font.custom("Sk-Modernist", size: geometry.size.width * 0.037))
                                    .foregroundColor(.black)
                            }
                            .frame(width: geometry.size.width * 0.544, height: geometry.size.height * 0.062)
                            .background(.white)
                            .cornerRadius(geometry.size.width * 0.053)
                            .shadow(
                                color: Color(red: 0.01, green: 0.12, blue: 0.17, opacity: 0.05),
                                radius: geometry.size.width * 0.107, y: geometry.size.height * 0.025
                            )
                        }
                    }
                    
                    Spacer()
                }
            }
        }
    }
}

#Preview {
    LoginView()
}
