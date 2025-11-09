//
//  MainView.swift
//  TimeEgg
//
//  Created by donghyeon choi on 10/4/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseDatabase

// MARK: - 타임캡슐 UI 데이터 모델
struct TimeCapsuleUIData {
    let id: String
    let title: String
    let dateString: String
    let dDayString: String
    let imageName: String
}

struct MainView: View {
    @State private var navigateToAllCapsules = false
    @State private var navigateToMapDetail = false
    @State private var navigateToCreateTimeCapsule = false
    
    @StateObject private var databaseService = RealtimeDatabaseService()
    @StateObject private var authService = FirebaseAuthService()
    @StateObject private var googleSignInService = GoogleSignInService()
    
    @State private var timeCapsules: [TimeCapsuleUIData] = []
    @State private var userName: String = "사용자"
    @State private var isLoading = true
    @State private var showLogoutAlert = false
    
    // 기본 이미지 배열 (타임캡슐이 4개 미만일 때 사용)
    private let defaultImages: [String] = ["greenEgg", "orangeEgg", "purpleEgg", "skyblueEgg"]
    
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
                            Text("\(userName)님, 반가워요!")
                                .font(Font.custom("DM Sans", size: geometry.size.width * 0.075).weight(.bold))
                                .foregroundColor(Color(red: 0.24, green: 0.24, blue: 0.24))
                        }
                        
                        Spacer()
                        
                        // 프로필 버튼
                        Button(action: {
                            showLogoutAlert = true
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
                        // 지도
                        MapView(showControls: false)
                            .frame(width: geometry.size.width * 0.872, height: geometry.size.height * 0.232)
                            .cornerRadius(geometry.size.width * 0.053)
                            .clipped()
                            .onTapGesture {
                                navigateToMapDetail = true
                            }
                        
//                        // 지도 위 마커들
//                        HStack {
//                            Spacer()
//                            
//                            VStack {
//                                Spacer()
//                                
//                                // +2 마커
//                                ZStack {
//                                    Circle()
//                                        .fill(Color(red: 0.97, green: 0.52, blue: 0.52))
//                                        .frame(width: geometry.size.width * 0.08, height: geometry.size.width * 0.08)
//                                    
//                                    Text("+2")
//                                        .font(Font.custom("Inter", size: geometry.size.width * 0.037).weight(.black))
//                                        .foregroundColor(.black)
//                                }
//                                
//                                Spacer()
//                            }
//                            
//                            Spacer()
//                            
//                            VStack {
//                                // +5 마커
//                                ZStack {
//                                    Circle()
//                                        .fill(Color(red: 0.93, green: 0.27, blue: 0.27))
//                                        .frame(width: geometry.size.width * 0.08, height: geometry.size.width * 0.08)
//                                    
//                                    Text("+5")
//                                        .font(Font.custom("Inter", size: geometry.size.width * 0.037).weight(.black))
//                                        .foregroundColor(.black)
//                                }
//                                
//                                Spacer()
//                            }
//                            
//                            Spacer()
//                            
//                            VStack {
//                                Spacer()
//                                
//                                // +1 마커
//                                ZStack {
//                                    Circle()
//                                        .fill(Color(red: 0.93, green: 0.41, blue: 0.27))
//                                        .frame(width: geometry.size.width * 0.08, height: geometry.size.width * 0.08)
//                                    
//                                    Text("+1")
//                                        .font(Font.custom("Inter", size: geometry.size.width * 0.037).weight(.black))
//                                        .foregroundColor(.black)
//                                }
//                                
//                                Spacer()
//                            }
//                            
//                            Spacer()
//                        }
//                        .frame(width: geometry.size.width * 0.872, height: geometry.size.height * 0.232)
                    }
                    
                    Spacer()
                        
                    
                    // 나의 캡슐 섹션
                    VStack(alignment: .leading, spacing: geometry.size.height * 0.015) {
                        HStack {
                            Text("나의 캡슐")
                                .font(Font.custom("DM Sans", size: geometry.size.width * 0.043).weight(.bold))
                                .foregroundColor(Color(red: 0.24, green: 0.24, blue: 0.24))
                            
                            Spacer()
                            
                        }
                        .padding(.horizontal, geometry.size.width * 0.053)
                        
                        // 캡슐 카드들
                        if isLoading {
                            ProgressView()
                                .frame(height: geometry.size.height * 0.3)
                        } else if timeCapsules.isEmpty {
                            VStack {
                                Text("아직 생성된 타임캡슐이 없습니다")
                                    .font(Font.custom("Inter", size: geometry.size.width * 0.037))
                                    .foregroundColor(Color(red: 0.36, green: 0.39, blue: 0.47))
                                    .padding(.vertical, geometry.size.height * 0.05)
                            }
                            .frame(maxWidth: .infinity)
                        } else {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: geometry.size.width * 0.053) {
                                    ForEach(Array(timeCapsules.enumerated()), id: \.element.id) { index, capsule in
                                        VStack(spacing: geometry.size.height * 0.012) {
                                            // 달걀 일러스트
                                            Image(capsule.imageName)
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: geometry.size.width * 0.4,
                                                       height: geometry.size.width * 0.4)
                                                .clipShape(RoundedRectangle(cornerRadius: geometry.size.width * 0.067))
                                            
                                            VStack(spacing: geometry.size.height * 0.005) {
                                                Text(capsule.title)
                                                    .font(Font.custom("Inter", size: geometry.size.width * 0.04))
                                                    .foregroundColor(Color(red: 0.16, green: 0.18, blue: 0.25))
                                                    .multilineTextAlignment(.center)
                                                
                                                Text(capsule.dateString)
                                                    .font(Font.custom("Inter", size: geometry.size.width * 0.027))
                                                    .foregroundColor(Color(red: 0.36, green: 0.39, blue: 0.47))
                                                
                                                // D-Day 태그
                                                Text(capsule.dDayString)
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
                            Button(action: {
                                navigateToCreateTimeCapsule = true
                            }) {
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
                        Button(action: {
                            // 검색 버튼 액션 - AllCapsulesView로 이동
                            navigateToAllCapsules = true
                        }) {
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
            .navigationDestination(isPresented: $navigateToAllCapsules) {
                AllCapsulesView()
            }
            .navigationDestination(isPresented: $navigateToMapDetail) {
                MapView()
            }
            .navigationDestination(isPresented: $navigateToCreateTimeCapsule) {
                CreateTimeCapsuleView()
            }
            .onAppear {
                loadUserData()
            }
            .onChange(of: navigateToCreateTimeCapsule) { oldValue, newValue in
                // 타임캡슐 생성 화면에서 돌아왔을 때 데이터 새로고침
                if !newValue {
                    loadUserData()
                }
            }
            .alert("로그아웃", isPresented: $showLogoutAlert) {
                Button("취소", role: .cancel) { }
                Button("로그아웃", role: .destructive) {
                    handleLogout()
                }
            } message: {
                Text("정말 로그아웃 하시겠습니까?")
            }
    }
    
    // MARK: - 로그아웃 처리
    private func handleLogout() {
        // Google Sign-In 로그아웃
        googleSignInService.signOut()
        
        // Firebase Auth 로그아웃
        authService.signOut()
        
        // 로그아웃 후 authService.isAuthenticated가 false가 되면
        // TimeEggApp에서 자동으로 LoginView로 이동합니다
    }
    
    // MARK: - 데이터 로드 함수
    private func loadUserData() {
        // 사용자 이름 로드
        if let user = Auth.auth().currentUser {
            userName = user.displayName ?? user.email?.components(separatedBy: "@").first ?? "사용자"
        }
        
        // 타임캡슐 목록 로드
        isLoading = true
        self.databaseService.getUserTimeCapsules { result in
            DispatchQueue.main.async {
                self.isLoading = false
                
                switch result {
                case .success(let capsules):
                    // TimeCapsule 모델 사용 (내장 DB 사용 안 함)
                    let limitedCapsules = Array(capsules.prefix(4))
                    
                    // 모든 추가 조건을 먼저 가져오기
                    let group = DispatchGroup()
                    var additionalDataMap: [String: TimeCapsuleAdditionalData] = [:]
                    
                    for capsule in limitedCapsules {
                        group.enter()
                        self.databaseService.getAdditionalConditions(timeCapsuleId: capsule.id) { additionalResult in
                            if case .success(let additional) = additionalResult {
                                additionalDataMap[capsule.id] = additional
                            }
                            group.leave()
                        }
                    }
                    
                    // 모든 추가 조건 로드 완료 후 UI 데이터 생성
                    group.notify(queue: .main) {
                        var uiCapsules: [TimeCapsuleUIData] = []
                        
                        for (index, timeCapsule) in limitedCapsules.enumerated() {
                            // TimeCapsule에서 날짜 가져오기
                            let date = timeCapsule.createdAt
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "yyyy.MM.dd"
                            let dateString = dateFormatter.string(from: date)
                            
                            // TimeCapsuleAdditionalData에서 D-Day 계산
                            let additionalData = additionalDataMap[timeCapsule.id]
                            var targetDate: Date?
                            
                            if let additional = additionalData,
                               let timeCondition = additional.timeCondition,
                               let targetDateValue = timeCondition.targetDate {
                                targetDate = targetDateValue
                            }
                            
                            // targetDate가 없으면 createdAt + 1년으로 설정
                            let finalTargetDate = targetDate ?? Calendar.current.date(byAdding: .year, value: 1, to: date) ?? date
                            let dDay = Calendar.current.dateComponents([.day], from: Date(), to: finalTargetDate).day ?? 0
                            let dDayString = dDay > 0 ? "D-\(dDay)" : (dDay < 0 ? "D+\(abs(dDay))" : "D-Day")
                            
                            // 이미지 선택 (기본 이미지 순환)
                            let imageName = index < self.defaultImages.count ? self.defaultImages[index] : self.defaultImages[index % self.defaultImages.count]
                            
                            // TimeCapsule 모델을 사용하여 UI 데이터 생성
                            uiCapsules.append(TimeCapsuleUIData(
                                id: timeCapsule.id,
                                title: timeCapsule.title,
                                dateString: dateString,
                                dDayString: dDayString,
                                imageName: imageName
                            ))
                        }
                        
                        self.timeCapsules = uiCapsules
                    }
                    
                case .failure(let error):
                    print("❌ 타임캡슐 로드 실패: \(error.localizedDescription)")
                    self.timeCapsules = []
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        MainView()
    }
    .onAppear {
        // Preview용 초기화
    }
}
