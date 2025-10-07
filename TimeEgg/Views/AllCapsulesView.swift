//
//  AllCapsulesView.swift
//  TimeEgg
//
//  Created by donghyeon choi on 10/6/25.
//

import SwiftUI

struct AllCapsulesView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 배경
                Color(red: 0.97, green: 0.98, blue: 1)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: geometry.size.height * 0.02) {
                        // 상단 필터 버튼
                        HStack {
                            Button(action: {
                                // 필터 액션
                            }) {
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color(red: 0.85, green: 0.85, blue: 0.85))
                                    .frame(width: 49, height: 17)
                                    .overlay(
                                        Text("필터")
                                            .font(.custom("Inter", size: 12))
                                            .foregroundColor(.black)
                                    )
                            }
                            
                            Spacer()
                        }
                        .padding(.horizontal, geometry.size.width * 0.05)
                        .padding(.top, geometry.size.height * 0.02)
                        
                        // 제목
                        Text("나의 캡슐")
                            .font(.custom("Fira Sans", size: 18).weight(.medium))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, geometry.size.width * 0.05)
                        
                        // 캡슐 리스트
                        VStack(spacing: geometry.size.height * 0.015) {
                            // 캡슐 1: 친구들과의 여행
                            CapsuleCard(
                                title: "친구들과의 여행",
                                date: "2025.09.12",
                                daysLeft: "D-3",
                                location: "성수역",
                                progress: 99,
                                progressColor: Color(red: 0.67, green: 0.55, blue: 0.23).opacity(0.29)
                            )
                            
                            // 캡슐 2: 졸업 기념 캡슐
                            CapsuleCard(
                                title: "졸업 기념 캡슐",
                                date: "2025.09.12",
                                daysLeft: "D-120",
                                location: "제주도",
                                progress: 80,
                                progressColor: Color(red: 0.67, green: 0.55, blue: 0.23).opacity(0.29)
                            )
                            
                            // 캡슐 3: 첫 데이트 추억
                            CapsuleCard(
                                title: "첫 데이트 추억",
                                date: "2025.09.12",
                                daysLeft: "D-260",
                                location: "성수역",
                                progress: 40,
                                progressColor: Color(red: 0.98, green: 0.74, blue: 0.02).opacity(0.60)
                            )
                            
                            // 캡슐 4: 성수역에서 다시만나!
                            CapsuleCard(
                                title: "성수역에서 다시만나!",
                                date: "2025.09.12",
                                daysLeft: "D+12",
                                location: "성수역",
                                progress: 0,
                                progressColor: Color(red: 0.67, green: 0.55, blue: 0.23).opacity(0.29),
                                isUnlocked: true
                            )
                        }
                        .padding(.horizontal, geometry.size.width * 0.05)
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        
    }
}

// MARK: - CapsuleCard
struct CapsuleCard: View {
    let title: String
    let date: String
    let daysLeft: String
    let location: String
    let progress: Int
    let progressColor: Color
    let isUnlocked: Bool
    
    init(title: String, date: String, daysLeft: String, location: String, progress: Int, progressColor: Color, isUnlocked: Bool = false) {
        self.title = title
        self.date = date
        self.daysLeft = daysLeft
        self.location = location
        self.progress = progress
        self.progressColor = progressColor
        self.isUnlocked = isUnlocked
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 카드 배경
                RoundedRectangle(cornerRadius: 25)
                    .fill(.white)
                    .frame(height: 107)
                    .overlay(
                        RoundedRectangle(cornerRadius: 25)
                            .inset(by: 0.5)
                            .stroke(Color(red: 0.85, green: 0.85, blue: 0.85), lineWidth: 0.5)
                    )
                
                HStack(spacing: geometry.size.width * 0.05) {
                    // 왼쪽: 아이콘
                    ZStack {
                        Circle()
                            .fill(Color(red: 0.50, green: 0.23, blue: 0.27).opacity(0.50))
                            .frame(width: 48, height: 48)
                        
                        if isUnlocked {
                            Image(systemName: "lock.open.fill")
                                .foregroundColor(.white)
                                .font(.system(size: 20))
                        } else {
                            Image(systemName: "lock.fill")
                                .foregroundColor(.white)
                                .font(.system(size: 20))
                        }
                    }
                    
                    // 가운데: 정보
                    VStack(alignment: .leading, spacing: geometry.size.height * 0.005) {
                        HStack {
                            Text(daysLeft)
                                .font(.custom("Inter", size: 12))
                                .foregroundColor(.black)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Color(red: 0.85, green: 0.85, blue: 0.85))
                                .cornerRadius(15)
                            
                            Spacer()
                        }
                        
                        Text(title)
                            .font(.custom("Inter", size: 15))
                            .foregroundColor(Color(red: 0.16, green: 0.18, blue: 0.25))
                            .lineLimit(1)
                        
                        Text(date)
                            .font(.custom("Inter", size: 10))
                            .foregroundColor(Color(red: 0.36, green: 0.39, blue: 0.47))
                        
                        // 위치 정보
                        HStack {
                            Text(location)
                                .font(.custom("Inter", size: 12))
                                .foregroundColor(.black)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Color(red: 0.85, green: 0.85, blue: 0.85))
                                .cornerRadius(15)
                            
                            Spacer()
                        }
                    }
                    
                    // 오른쪽: 진행률
                    VStack {
                        if isUnlocked {
                            Text("위치 조건 캡슐입니다.(?)")
                                .font(.custom("Inter", size: 12))
                                .foregroundColor(.black)
                                .multilineTextAlignment(.center)
                        } else {
                            // 진행률 바
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 30)
                                    .fill(Color(red: 0.67, green: 0.55, blue: 0.23).opacity(0.29))
                                    .frame(width: 116, height: 21)
                                
                                RoundedRectangle(cornerRadius: 30)
                                    .fill(progressColor)
                                    .frame(width: 116 * CGFloat(progress) / 100, height: 21)
                                
                                Text("\(progress)%")
                                    .font(.custom("Inter", size: 12))
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                    }
                }
                .padding(.horizontal, geometry.size.width * 0.05)
            }
        }
        .frame(height: 107)
    }
}

#Preview {
    NavigationStack {
        AllCapsulesView()
    }
}
