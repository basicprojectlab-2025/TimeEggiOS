//
//  CreateTimeCapsuleView.swift
//  TimeEgg
//
//  Created by donghyeon choi on 9/22/25.
//

import SwiftUI
import PhotosUI
import SwiftData

struct CreateTimeCapsuleView: View {
    var body: some View {
        ZStack() {
            // 배경
            Color(red: 0.97, green: 0.99, blue: 1)
                .ignoresSafeArea()
            VStack {
                Spacer()
                HStack () {
                    // 상단 네비게이션 바 (뒤로가기 버튼, 프로필)
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(width: 40, height: 40)
                        .background(.white)
                        .cornerRadius(15)
                    
                    Spacer()
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(width: 40, height: 40)
                        .background(.white)
                        .cornerRadius(15)
                        .offset(x: 147.50, y: -352)
                    
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(width: 18, height: 23)
                        .background(Color(red: 0.50, green: 0.23, blue: 0.27).opacity(0.50))
                        .offset(x: 147.50, y: -352.50)
                        .shadow(
                            color: Color(red: 0.59, green: 0.43, blue: 0.34, opacity: 0.20), radius: 15, y: 8
                        )
                }

                
                // 사진 촬영/업로드 버튼
                Text("사진 촬영/업로드")
                    .font(Font.custom("Inter", size: 16).weight(.bold))
                    .italic()
                    .foregroundColor(Color(red: 0.98, green: 0.53, blue: 0.12))
                    .padding(EdgeInsets(top: 15, leading: 20, bottom: 15, trailing: 20))
                    .frame(width: 335)
                    .background(Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color(red: 0.98, green: 0.53, blue: 0.12), lineWidth: 1)
                    )
                        
                Spacer(minLength: 20)
                // 제목 입력 필드
                TextField("제목", text: .constant(""))
                    .font(Font.custom("Inter", size: 14))
                    .foregroundColor(Color(red: 0.20, green: 0.20, blue: 0.20))
                    .padding(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
                    .frame(width: 335, height: 50)
                    .background(.white)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .inset(by: 0.50)
                            .stroke(Color(red: 0.85, green: 0.85, blue: 0.85), lineWidth: 0.50)
                    )
                    
                
                // 메모 입력 필드
                TextField("메모 입력 필드", text: .constant(""), axis: .vertical)
                    .font(Font.custom("Inter", size: 14))
                    .foregroundColor(Color(red: 0.20, green: 0.20, blue: 0.20))
                    .padding(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
                    .frame(width: 335, height: 100)
                    .background(.white)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .inset(by: 0.50)
                            .stroke(Color(red: 0.85, green: 0.85, blue: 0.85), lineWidth: 0.50)
                    )
                        
                
                HStack {
                    // 조건추가 버튼
                    ZStack() {
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(width: 163, height: 36)
                            .background(.white)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .inset(by: 0.50)
                                    .stroke(Color(red: 0.85, green: 0.85, blue: 0.85), lineWidth: 0.50)
                            )
                        Text("조건추가")
                            .font(Font.custom("Fira Sans", size: 16).weight(.medium))
                            .lineSpacing(20)
                            .foregroundColor(Color(red: 0.20, green: 0.20, blue: 0.20))
                    }
                    .frame(width: 163, height: 36)
                    
                    
                    // 공개범위 버튼
                    ZStack() {
                        HStack(alignment: .top, spacing: 41) {
                            Text("공개범위")
                                .font(Font.custom("Fira Sans", size: 16).weight(.medium))
                                .lineSpacing(20)
                                .foregroundColor(Color(red: 0.20, green: 0.20, blue: 0.20))
                            ZStack() {
                                
                            }
                            .frame(width: 18, height: 18)
                            .opacity(0.50)
                        }
                        .padding(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        .frame(width: 163)
                        .background(.white)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .inset(by: 0.50)
                                .stroke(Color(red: 0.85, green: 0.85, blue: 0.85), lineWidth: 0.50)
                        )
                    }
                    .frame(width: 163, height: 36)
                    .cornerRadius(8)
                    
                }
                
                // 드롭다운 텍스트
                Text("2. 드롭다운")
                    .font(Font.custom("Fira Sans", size: 30).weight(.medium))
                    .lineSpacing(18)
                    .foregroundColor(Color(red: 0.32, green: 0.78, blue: 0.23))
                    .offset(x: -8.50, y: 147)
                
                // 하단 타임캡슐 생성 버튼
                HStack(alignment: .top, spacing: 10) {
                    Text("타임캡슐 생성")
                        .font(Font.custom("Inter", size: 14).weight(.bold))
                        .lineSpacing(21.32)
                        .foregroundColor(.white)
                }
                .padding(EdgeInsets(top: 15, leading: 20, bottom: 15, trailing: 20))
                .frame(width: 335)
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
                .cornerRadius(20)
                .offset(x: 0, y: 349.50)
                .shadow(
                    color: Color(red: 0.79, green: 0.26, blue: 0.07, opacity: 0.10), radius: 30, y: 10
                )
                Spacer()
            }
            
        }
        .ignoresSafeArea()
    }
    
}

#Preview {
    CreateTimeCapsuleView()
}
