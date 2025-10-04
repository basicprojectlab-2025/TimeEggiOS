//
//  MainView.swift
//  TimeEgg
//
//  Created by donghyeon choi on 10/4/25.
//

import SwiftUI

struct MainView: View {
    
    var images: [String] = ["greenEgg", "orangeEgg", "purpleEgg", "skyblueEgg"]
    var dates: [String] = ["2025.09.12", "2025.10.05", "2025.11.20", "2025.12.25"]
    var dDays: [String] = ["D-12", "D-35", "D-81", "D-126"]
    var eggName: [String] = ["첫 만남", "여행", "생일", "크리스마스"]
    let name: String = "재혁"
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 배경
                Color(red: 0.97, green: 0.98, blue: 1)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    
                    // 상단 헤더
                    HStack {
                        VStack(alignment: .leading, spacing: geometry.size.height * 0.005) {
                            Image("textLogo")
                            Text("\(name)님, 반가워요!")
                                .font(Font.custom("DM Sans", size: geometry.size.width * 0.075).weight(.bold))
                                .foregroundColor(Color(red: 0.24, green: 0.24, blue: 0.24))
                        }
                        
                        Spacer()
                        
                        // 프로필 버튼
                        Button(action: {
                            // 프로필 액션
                        }) {
                            ZStack {
                                Circle()
                                    .fill(.white)
                                    .frame(width: geometry.size.width * 0.107, height: geometry.size.width * 0.107)
                                    .overlay(
                                        Circle()
                                            .stroke(Color(red: 0.85, green: 0.85, blue: 0.85).opacity(0.40), lineWidth: 0.5)
                                    )
                                
                                Image(systemName: "person.fill")
                                    .font(.system(size: geometry.size.width * 0.048))
                                    .foregroundColor(Color(red: 0.50, green: 0.23, blue: 0.27))
                            }
                        }
                    }
                    .padding(.horizontal, geometry.size.width * 0.053)
                    .padding(.top, geometry.size.height * 0.02)
                    
                    Spacer()
                    
                    // 지도 섹션
                    ZStack {
                        // 지도 배경
                        RoundedRectangle(cornerRadius: geometry.size.width * 0.053)
                            .fill(
                                ImagePaint(
                                    image: Image("dummyMap"),
                                    scale: 1.0
                                )
                            )
                            .frame(width: geometry.size.width * 0.872, height: geometry.size.height * 0.232)
                            .blur(radius: 0.5)
                        
                        // 지도 위 마커들
                        HStack {
                            Spacer()
                            
                            VStack {
                                Spacer()
                                
                                // +2 마커
                                ZStack {
                                    Circle()
                                        .fill(Color(red: 0.97, green: 0.52, blue: 0.52))
                                        .frame(width: geometry.size.width * 0.08, height: geometry.size.width * 0.08)
                                    
                                    Text("+2")
                                        .font(Font.custom("Inter", size: geometry.size.width * 0.037).weight(.black))
                                        .foregroundColor(.black)
                                }
                                
                                Spacer()
                            }
                            
                            Spacer()
                            
                            VStack {
                                // +5 마커
                                ZStack {
                                    Circle()
                                        .fill(Color(red: 0.93, green: 0.27, blue: 0.27))
                                        .frame(width: geometry.size.width * 0.08, height: geometry.size.width * 0.08)
                                    
                                    Text("+5")
                                        .font(Font.custom("Inter", size: geometry.size.width * 0.037).weight(.black))
                                        .foregroundColor(.black)
                                }
                                
                                Spacer()
                            }
                            
                            Spacer()
                            
                            VStack {
                                Spacer()
                                
                                // +1 마커
                                ZStack {
                                    Circle()
                                        .fill(Color(red: 0.93, green: 0.41, blue: 0.27))
                                        .frame(width: geometry.size.width * 0.08, height: geometry.size.width * 0.08)
                                    
                                    Text("+1")
                                        .font(Font.custom("Inter", size: geometry.size.width * 0.037).weight(.black))
                                        .foregroundColor(.black)
                                }
                                
                                Spacer()
                            }
                            
                            Spacer()
                        }
                        .frame(width: geometry.size.width * 0.872, height: geometry.size.height * 0.232)
                    }
                    
                    Spacer()
                    
                    // 나의 캡슐 섹션
                    VStack(alignment: .leading, spacing: geometry.size.height * 0.015) {
                        HStack {
                            Text("나의 캡슐")
                                .font(Font.custom("DM Sans", size: geometry.size.width * 0.043).weight(.bold))
                                .foregroundColor(Color(red: 0.24, green: 0.24, blue: 0.24))
                            
                            Spacer()
                            
                            Button(action: {
                                // 전체 보기 액션
                            }) {
                                Text("view all(\(images.count))")
                                    .font(Font.custom("Inter", size: geometry.size.width * 0.037))
                                    .underline()
                                    .foregroundColor(Color(red: 1, green: 0.33, blue: 0.29))
                            }
                        }
                        .padding(.horizontal, geometry.size.width * 0.053)
                        
                        // 캡슐 카드들
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: geometry.size.width * 0.053) {
                                ForEach(0..<4) { index in
                                    VStack(spacing: geometry.size.height * 0.012) {
                                        // 달걀 일러스트
                                        Image("\(images[index])")
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: geometry.size.width * 0.4,
                                                   height: geometry.size.width * 0.4)
                                            .clipShape(RoundedRectangle(cornerRadius: geometry.size.width * 0.067))
                                        
                                        VStack(spacing: geometry.size.height * 0.005) {
                                            Text("\(eggName[index])")
                                                .font(Font.custom("Inter", size: geometry.size.width * 0.04))
                                                .foregroundColor(Color(red: 0.16, green: 0.18, blue: 0.25))
                                                .multilineTextAlignment(.center)
                                            
                                            Text("\(dates[index])")
                                                .font(Font.custom("Inter", size: geometry.size.width * 0.027))
                                                .foregroundColor(Color(red: 0.36, green: 0.39, blue: 0.47))
                                            
                                            // D-Day 태그
                                            Text("\(dDays[index])")
                                                .font(Font.custom("Inter", size: geometry.size.width * 0.032))
                                                .foregroundColor(.black)
                                                .padding(.horizontal, geometry.size.width * 0.04)
                                                .padding(.vertical, geometry.size.height * 0.005)
                                                .background(
                                                    RoundedRectangle(cornerRadius: geometry.size.width * 0.08)
                                                        .fill(Color(red: 0.98, green: 0.74, blue: 0.02).opacity(0.60))
                                                )
                                        }
                                    }
                                    .frame(width: geometry.size.width * 0.493)
                                    .padding(geometry.size.width * 0.04)
                                    .background(.white)
                                    .cornerRadius(geometry.size.width * 0.067)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: geometry.size.width * 0.067)
                                            .stroke(Color(red: 0.85, green: 0.85, blue: 0.85), lineWidth: 0.5)
                                    )
                                }
                            }
                            .padding(.horizontal, geometry.size.width * 0.053)
                        }
                    }
                    
                    Spacer()
                    
                    // 하단 네비게이션 바
                    HStack(spacing: 0) {
                        // 홈
                        Button(action: {}) {
                            Image(systemName: "house.fill")
                                .font(.system(size: geometry.size.width * 0.064))
                                .foregroundColor(Color(red: 0.98, green: 0.53, blue: 0.12))
                        }
                        .frame(maxWidth: .infinity)
                        
                        // 알림
                        Button(action: {}) {
                            Image(systemName: "bell")
                                .font(.system(size: geometry.size.width * 0.064))
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity)
                        
                        // 중앙 + 버튼
                        VStack(spacing: 0) {
                            Button(action: {}) {
                                ZStack {
                                    Circle()
                                        .fill(Color(red: 0.98, green: 0.53, blue: 0.12))
                                        .frame(width: geometry.size.width * 0.16, height: geometry.size.width * 0.16)
                                        .shadow(
                                            color: Color(red: 0.59, green: 0.43, blue: 0.34, opacity: 0.20),
                                            radius: geometry.size.width * 0.04,
                                            y: geometry.size.width * 0.021
                                        )
                                    
                                    Image(systemName: "plus")
                                        .font(.system(size: geometry.size.width * 0.064, weight: .bold))
                                        .foregroundColor(.white)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            
                            // 버튼을 위로 올리기 위한 투명한 공간
                            Rectangle()
                                .fill(Color.clear)
                                .frame(height: geometry.size.height * 0.022)
                        }
                        
                        // 검색
                        Button(action: {}) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: geometry.size.width * 0.064))
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity)
                        
                        // 프로필
                        Button(action: {}) {
                            Image(systemName: "person")
                                .font(.system(size: geometry.size.width * 0.064))
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding(.horizontal, geometry.size.width * 0.053)
                    .padding(.vertical, geometry.size.height * 0.015)
                    .background(.white)
                    .clipShape(
                        UnevenRoundedRectangle(
                            topLeadingRadius: geometry.size.width * 0.067,
                            topTrailingRadius: geometry.size.width * 0.067
                        )
                    )
                }
            }
        }
        .ignoresSafeArea(edges: .bottom)
    }
}

#Preview {
    MainView()
}
