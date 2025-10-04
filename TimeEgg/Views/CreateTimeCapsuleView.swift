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
    @State private var title = ""
    @State private var memo = ""
    @State private var selectedPrivacy = "전체공개"
    @State private var finalSelectedPrivacy = 0
    let privacyOptions = ["전체공개", "친구공개", "비공개"]
    @State private var isAlert: Int = 0
    let alerts: [String] = ["", "제목을 반드시 입력하세요!"]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 배경
                Color(red: 0.97, green: 0.99, blue: 1)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // 상단 네비게이션 바
                    HStack {
                        // 뒤로가기 버튼
                        Button(action: {
                            // 뒤로가기 액션
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: geometry.size.width * 0.064))
                                .foregroundColor(.black)
                                .frame(width: geometry.size.width * 0.107, height: geometry.size.width * 0.107)
                                .background(.white)
                                .cornerRadius(geometry.size.width * 0.04)
                        }
                        
                        Spacer()
                        
                        // 프로필 버튼
                        Button(action: {
                            // 프로필 액션
                        }) {
                            Image(systemName: "person.fill")
                                .font(.system(size: geometry.size.width * 0.048))
                                .foregroundColor(Color(red: 0.50, green: 0.23, blue: 0.27))
                                .frame(width: geometry.size.width * 0.107, height: geometry.size.width * 0.107)
                                .background(.white)
                                .cornerRadius(geometry.size.width * 0.04)
                        }
                    }
                    .padding(.horizontal, geometry.size.width * 0.053)
                    .padding(.top, geometry.size.height * 0.01)
                   
                    Spacer()
                   
                    // 메인 콘텐츠
                    VStack(spacing: geometry.size.height * 0.025) {
                        // 사진 촬영/업로드 버튼
                        Button(action: {
                            // 사진 촬영/업로드 액션
                        }) {
                            Text("사진 촬영/업로드")
                                .font(Font.custom("Inter", size: geometry.size.width * 0.043).weight(.bold))
                                .italic()
                                .foregroundColor(Color(red: 0.98, green: 0.53, blue: 0.12))
                                .frame(width: geometry.size.width * 0.893, height: geometry.size.height * 0.062)
                                .background(Color.clear)
                                .overlay(
                                    RoundedRectangle(cornerRadius: geometry.size.width * 0.053)
                                        .stroke(Color(red: 0.98, green: 0.53, blue: 0.12), lineWidth: 1)
                                )
                        }
                        
                        // 제목 입력 필드
                        VStack(alignment: .leading, spacing: geometry.size.height * 0.01) {
                            Text("제목")
                                .font(Font.custom("Inter", size: geometry.size.width * 0.037))
                                .foregroundColor(Color(red: 0.20, green: 0.20, blue: 0.20))
                            
                            TextField("제목을 입력하세요(최대 20자)", text: $title.limit(20))
                                .font(Font.custom("Inter", size: geometry.size.width * 0.037))
                                .foregroundColor(Color(red: 0.20, green: 0.20, blue: 0.20))
                                .padding(EdgeInsets(
                                    top: geometry.size.height * 0.015,
                                    leading: geometry.size.width * 0.043,
                                    bottom: geometry.size.height * 0.015,
                                    trailing: geometry.size.width * 0.043
                                ))
                                .frame(height: geometry.size.height * 0.062)
                                .background(.white)
                                .cornerRadius(geometry.size.width * 0.021)
                                .overlay(
                                    RoundedRectangle(cornerRadius: geometry.size.width * 0.021)
                                        .stroke(Color(red: 0.85, green: 0.85, blue: 0.85), lineWidth: 0.5)
                                )
                                
                        }
                        .frame(width: geometry.size.width * 0.893)
                        
                        // 메모 입력 필드
                        VStack(alignment: .leading, spacing: geometry.size.height * 0.01) {
                            Text("메모")
                                .font(Font.custom("Inter", size: geometry.size.width * 0.037))
                                .foregroundColor(Color(red: 0.20, green: 0.20, blue: 0.20))
                            
                            TextField("메모를 입력하세요(최대 100자)", text: $memo.limit(100), axis: .vertical)
                                .font(Font.custom("Inter", size: geometry.size.width * 0.037))
                                .foregroundColor(Color(red: 0.20, green: 0.20, blue: 0.20))
                                .padding(EdgeInsets(
                                    top: geometry.size.height * 0.015,
                                    leading: geometry.size.width * 0.043,
                                    bottom: geometry.size.height * 0.015,
                                    trailing: geometry.size.width * 0.043
                                ))
                                .frame(height: geometry.size.height * 0.123)
                                .background(.white)
                                .cornerRadius(geometry.size.width * 0.021)
                                .overlay(
                                    RoundedRectangle(cornerRadius: geometry.size.width * 0.021)
                                        .stroke(Color(red: 0.85, green: 0.85, blue: 0.85), lineWidth: 0.5)
                                )
                        }
                        .frame(width: geometry.size.width * 0.893)
                        
                        // 조건추가 버튼
                        Button(action: {
                            // TODO:  조건추가 액션
                        }) {
                            Text("조건추가")
                                .font(Font.custom("Fira Sans", size: geometry.size.width * 0.043).weight(.medium))
                                .foregroundColor(Color(red: 0.20, green: 0.20, blue: 0.20))
                                .frame(width: geometry.size.width * 0.435, height: geometry.size.height * 0.044)
                                .background(.white)
                                .cornerRadius(geometry.size.width * 0.021)
                                .overlay(
                                    RoundedRectangle(cornerRadius: geometry.size.width * 0.021)
                                        .stroke(Color(red: 0.85, green: 0.85, blue: 0.85), lineWidth: 0.5)
                                )
                        }
                        .frame(width: geometry.size.width * 0.893, alignment: .leading)
                        
                        // 공개범위 섹션
                        VStack(alignment: .leading, spacing: geometry.size.height * 0.015) {
                            HStack {
                                Text("공개범위")
                                    .font(Font.custom("Fira Sans", size: geometry.size.width * 0.043).weight(.medium))
                                    .foregroundColor(Color(red: 0.20, green: 0.20, blue: 0.20))
                                
                                Spacer()
                                
                                
                            }
                            
                            // 라디오 버튼 옵션들
                            VStack(spacing: geometry.size.height * 0.01) {
                                ForEach(privacyOptions, id: \.self) { option in
                                    HStack {
                                        Button(action: {
                                            selectedPrivacy = option
                                        }) {
                                            ZStack {
                                                Circle()
                                                    .stroke(Color(red: 0.85, green: 0.85, blue: 0.85), lineWidth: 1)
                                                    .frame(width: geometry.size.width * 0.048, height: geometry.size.width * 0.048)
                                                
                                                if selectedPrivacy == option {
                                                    Circle()
                                                        .fill(Color(red: 0.98, green: 0.53, blue: 0.12))
                                                        .frame(width: geometry.size.width * 0.027, height: geometry.size.width * 0.027)
                                                }
                                            }
                                        }
                                        
                                        Text(option)
                                            .font(Font.custom("Inter", size: geometry.size.width * 0.037))
                                            .foregroundColor(Color(red: 0.20, green: 0.20, blue: 0.20))
                                        
                                        Spacer()
                                    }
                                }
                            }
                        }
                        .frame(width: geometry.size.width * 0.893)
                    }
                    
                    Spacer()
                    
                    Text("\(alerts[isAlert])")
                        .font(.system(size: 25))
                        .foregroundStyle(Color.red)
                    
                    
                    Spacer()
                    
                    // 하단 타임캡슐 생성 버튼
                    Button(action: {
                        // 타임캡슐 생성 액션
                        if title == "" {
                            isAlert = 1
                        } else {
                            isAlert = 0
                            // TODO: move next pages
                        }
                    }) {
                        Text("타임캡슐 생성")
                            .font(Font.custom("Inter", size: geometry.size.width * 0.037).weight(.bold))
                            .foregroundColor(.white)
                            .frame(width: geometry.size.width * 0.893, height: geometry.size.height * 0.062)
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
                                radius: geometry.size.width * 0.08,
                                y: geometry.size.height * 0.012
                            )
                    }
                    .padding(.bottom, geometry.size.height * 0.03)
                }
            }
        }
    }
}

extension Binding where Value == String {
    func limit(_ length: Int) -> Self {
        if self.wrappedValue.count > length {
            DispatchQueue.main.async {
                self.wrappedValue = String(self.wrappedValue.prefix(length))
            }
        }
        return self
    }
}

#Preview {
    CreateTimeCapsuleView()
}
