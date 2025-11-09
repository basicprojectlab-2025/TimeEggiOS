//
//  MakeView.swift
//  TimeEgg
//
//  Created by donghyeon choi on 10/28/25.
//

import SwiftUI

struct MakeView: View {
    
    @State private var isPresented: Bool = false
    @State private var selectedPrivacyItems: [String] = ["전체공개", "친구공개", "비공개"]
    @State private var selectedWeatherItems: [String] = ["맑음", "눈", "비", "흐림", "번개"]
    @State var selectedPrivacyId: Int = 0
    @State var selectedWeatherId: Int = 0
        
    func radioGroupCallback(id: Int) {
        selectedPrivacyId = id //선택된 아이디 변경
    }
    
    func weatherGroupCallback(id: Int) {
        selectedWeatherId = id //선택된 아이디 변경
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // 상단 네비게이션 바
                HStack {
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(width: geometry.size.width * 0.107, height: geometry.size.height * 0.049)
                        .background(.white)
                        .cornerRadius(15)
                    
                    Spacer()
                    
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(width: geometry.size.width * 0.107, height: geometry.size.height * 0.049)
                        .background(.white)
                        .cornerRadius(15)
                }
                .padding(.horizontal, geometry.size.width * 0.05)
                .padding(.top, geometry.size.height * 0.05)
                
                // 메인 콘텐츠
                VStack(spacing: geometry.size.height * 0.03) {
                    // 사진 촬영/업로드 섹션
                    VStack(spacing: geometry.size.height * 0.02) {
                        Text("사진 촬영 / 업로드")
                            .font(Font.custom("Inter", size: 16).weight(.bold))
                            .italic()
                            .foregroundColor(Color(red: 0.13, green: 0.13, blue: 0.13))
                        
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(width: geometry.size.width * 0.048, height: geometry.size.height * 0.028)
                            .background(Color(red: 0.50, green: 0.23, blue: 0.27).opacity(0.50))
                            .shadow(
                                color: Color(red: 0.59, green: 0.43, blue: 0.34, opacity: 0.20), radius: 15, y: 8
                            )
                    }
                    .frame(width: geometry.size.width * 0.888, height: geometry.size.height * 0.069)
                    
                    // 제목 입력
                    VStack(alignment: .leading, spacing: geometry.size.height * 0.01) {
                        Text("제목")
                            .font(Font.custom("Inter", size: 14))
                            .foregroundColor(Color(red: 0.20, green: 0.20, blue: 0.20))
                        
                        Text("메모 입력 필드")
                            .font(Font.custom("Inter", size: 14))
                            .foregroundColor(Color(red: 0.20, green: 0.20, blue: 0.20))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, geometry.size.width * 0.05)
                    
                    // 공개범위 및 날씨 선택
                    HStack(spacing: geometry.size.width * 0.3) {
                        
                        VStack(alignment: .leading, spacing: geometry.size.height * 0.02) {
                            Text("공개범위")
                                .font(Font.custom("Poppins", size: 12))
                                .foregroundColor(.black)
                            
                            ForEach(Array(selectedPrivacyItems.enumerated()), id: \.offset) { idx, item in
                                RadioButton(title: item, id: idx, callback: self.radioGroupCallback, selectedID: self.selectedPrivacyId, geometry: geometry)
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: geometry.size.height * 0.02) {
                            Text("날씨 선택")
                                .font(Font.custom("Poppins", size: 12))
                                .foregroundColor(.black)
                            
                            ForEach(Array(selectedWeatherItems.enumerated()), id: \.offset) { idx, item in
                                RadioButton(title: item, id: idx, callback: self.weatherGroupCallback, selectedID: self.selectedWeatherId, geometry: geometry)
                            }
                        }
                    }
                    .padding(.horizontal, geometry.size.width * 0.05)
                    
                    // 알리미 설정
                    HStack(spacing: 10) {
                        Text("알리미 설정")
                            .font(Font.custom("Fira Sans", size: 16).weight(.medium))
                            .lineSpacing(20)
                            .foregroundColor(Color(red: 0.20, green: 0.20, blue: 0.20))
                    }
                    .padding(EdgeInsets(top: 8, leading: 125, bottom: 8, trailing: 125))
                    .frame(width: geometry.size.width * 0.874, height: geometry.size.height * 0.044)
                    .background(.white)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .inset(by: 0.50)
                            .stroke(Color(red: 0.85, green: 0.85, blue: 0.85), lineWidth: 0.50)
                    )
                    
                    Spacer()
                    
                    Text("\(selectedPrivacyItems[selectedPrivacyId]) : \(selectedWeatherItems[selectedWeatherId])")
                    
                    Spacer()
                    
                    // 하단 버튼
                    Button {
                        isPresented = true
                    } label: {
                        HStack(alignment: .top, spacing: 10) {
                            Text("타임캡슐 생성")
                                .font(Font.custom("Inter", size: 14).weight(.bold))
                                .lineSpacing(21.32)
                                .foregroundColor(.white)
                        }
                        .padding(EdgeInsets(top: 15, leading: 20, bottom: 15, trailing: 20))
                        .frame(width: geometry.size.width * 0.893)
                        .background(Color(red: 0.98, green: 0.53, blue: 0.12))
                        .cornerRadius(20)
                        .shadow(
                            color: Color(red: 0.79, green: 0.26, blue: 0.07, opacity: 0.10), radius: 30, y: 10
                        )
                    }
                    
                }
                .padding(.horizontal, geometry.size.width * 0.05)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .background(Color(red: 0.97, green: 0.99, blue: 1))
        }
    }
}

struct RadioButton: View {
    let id: Int
    let title: String
    let callback: (Int)->()
    let selectedId: Int
    let geometry: GeometryProxy
    
    init(
        title: String,
        id: Int,
        callback: @escaping (Int)->(),
        selectedID: Int,
        geometry: GeometryProxy
    ) {
        self.title = title
        self.id = id
        self.selectedId = selectedID
        self.callback = callback
        self.geometry = geometry
    }
    
    var body: some View {
        Button {
            self.callback(id)
        } label: {
            HStack {
                Ellipse()
                    .foregroundColor(.clear)
                    .frame(width: geometry.size.width * 0.053, height: geometry.size.height * 0.025)
                    .overlay(
                        Ellipse()
                            .inset(by: 0.50)
                            .stroke(Color(red: 0.68, green: 0.68, blue: 0.70), lineWidth: 0.50)
                    )
                    .overlay(
                        selectedId == id ? 
                        Ellipse()
                            .fill(Color(red: 0.68, green: 0.68, blue: 0.70))
                            .frame(width: geometry.size.width * 0.03, height: geometry.size.height * 0.015) : nil
                    )
                Text(title)
                    .font(Font.custom("Poppins", size: 12))
                    .foregroundColor(Color(red: 0.20, green: 0.20, blue: 0.20))
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    MakeView()
}
