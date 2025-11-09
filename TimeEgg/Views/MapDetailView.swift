//
//  MapDetailView.swift
//  TimeEgg
//
//  Created by donghyeon choi on 10/7/25.
//

import SwiftUI

struct MapDetailView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 배경
                Color(red: 0.97, green: 0.98, blue: 1)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // 상단 영역
                    VStack(spacing: geometry.size.height * 0.02) {
                        // TimeEgg 로고
                        Text("TimeEgg")
                            .font(Font.custom("Edu AU VIC WA NT Hand", size: geometry.size.width * 0.08).weight(.bold))
                            .foregroundColor(Color(red: 0.20, green: 0.20, blue: 0.20))
                            .padding(.top, geometry.size.height * 0.05)
                        
                        // 지도 마커들
                        HStack(spacing: geometry.size.width * 0.1) {
                            // 마커 1
                            VStack {
                                Circle()
                                    .fill(Color(red: 0.50, green: 0.23, blue: 0.27).opacity(0.50))
                                    .frame(width: geometry.size.width * 0.15, height: geometry.size.width * 0.15)
                                    .shadow(
                                        color: Color(red: 0, green: 0, blue: 0, opacity: 0.40), 
                                        radius: geometry.size.width * 0.02, 
                                        y: geometry.size.height * 0.01
                                    )
                            }
                            
                            // 마커 2
                            VStack {
                                Circle()
                                    .fill(Color(red: 0.50, green: 0.23, blue: 0.27).opacity(0.50))
                                    .frame(width: geometry.size.width * 0.24, height: geometry.size.width * 0.24)
                                    .shadow(
                                        color: Color(red: 0, green: 0, blue: 0, opacity: 0.40), 
                                        radius: geometry.size.width * 0.02, 
                                        y: geometry.size.height * 0.01
                                    )
                            }
                            
                            // 마커 3
                            VStack {
                                Circle()
                                    .fill(Color(red: 0.50, green: 0.23, blue: 0.27).opacity(0.50))
                                    .frame(width: geometry.size.width * 0.2, height: geometry.size.width * 0.2)
                                    .shadow(
                                        color: Color(red: 0, green: 0, blue: 0, opacity: 0.40), 
                                        radius: geometry.size.width * 0.02, 
                                        y: geometry.size.height * 0.01
                                    )
                            }
                        }
                        .padding(.top, geometry.size.height * 0.1)
                    }
                    
                    Spacer()
                    
                    // 하단 컨트롤 영역
                    VStack(spacing: geometry.size.height * 0.02) {
                        // 중앙 버튼
                        Button(action: {
                            // 중앙 버튼 액션
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Color(red: 0.98, green: 0.53, blue: 0.12))
                                    .frame(width: geometry.size.width * 0.16, height: geometry.size.width * 0.16)
                                    .shadow(
                                        color: Color(red: 0.59, green: 0.43, blue: 0.34, opacity: 0.20), 
                                        radius: geometry.size.width * 0.04, 
                                        y: geometry.size.height * 0.01
                                    )
                                
                                Image(systemName: "plus")
                                    .font(.system(size: geometry.size.width * 0.08, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                        
                        // 하단 네비게이션 버튼들
                        HStack(spacing: geometry.size.width * 0.15) {
                            // 버튼 1
                            Button(action: {}) {
                                ZStack {
                                    Circle()
                                        .fill(.white)
                                        .frame(width: geometry.size.width * 0.06, height: geometry.size.width * 0.06)
                                    
                                    Image(systemName: "house")
                                        .font(.system(size: geometry.size.width * 0.04))
                                        .foregroundColor(.black)
                                }
                            }
                            
                            // 버튼 2
                            Button(action: {}) {
                                ZStack {
                                    Circle()
                                        .fill(.white)
                                        .frame(width: geometry.size.width * 0.06, height: geometry.size.width * 0.06)
                                    
                                    Image(systemName: "bell")
                                        .font(.system(size: geometry.size.width * 0.04))
                                        .foregroundColor(.black)
                                }
                            }
                            
                            // 버튼 3
                            Button(action: {}) {
                                ZStack {
                                    Circle()
                                        .fill(.white)
                                        .frame(width: geometry.size.width * 0.06, height: geometry.size.width * 0.06)
                                    
                                    Image(systemName: "magnifyingglass")
                                        .font(.system(size: geometry.size.width * 0.04))
                                        .foregroundColor(.black)
                                }
                            }
                            
                            // 버튼 4
                            Button(action: {}) {
                                ZStack {
                                    Circle()
                                        .fill(.white)
                                        .frame(width: geometry.size.width * 0.06, height: geometry.size.width * 0.06)
                                    
                                    Image(systemName: "person")
                                        .font(.system(size: geometry.size.width * 0.04))
                                        .foregroundColor(.black)
                                }
                            }
                        }
                        .padding(.bottom, geometry.size.height * 0.05)
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("뒤로") {
                    dismiss()
                }
                .foregroundColor(.blue)
            }
        }
    }
}

#Preview {
    NavigationStack {
        MapDetailView()
    }
}


