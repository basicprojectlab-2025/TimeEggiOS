//
//  AllCapsulesView.swift
//  TimeEgg
//
//  Created by donghyeon choi on 10/6/25.
//

import SwiftUI
import FirebaseAuth

struct AllCapsulesView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var databaseService = RealtimeDatabaseService()
    @State private var timeCapsules: [TimeCapsule] = []
    @State private var additionalDataMap: [String: TimeCapsuleAdditionalData] = [:]
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var selectedCapsule: TimeCapsule?
    @State private var navigateToDetail = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 배경
                Color(red: 0.97, green: 0.98, blue: 1)
                    .ignoresSafeArea()
                
                if isLoading {
                    VStack(spacing: 20) {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("캡슐을 불러오는 중...")
                            .font(.custom("Inter", size: 14))
                            .foregroundColor(.gray)
                    }
                } else if let error = errorMessage {
                    VStack(spacing: 20) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 40))
                            .foregroundColor(.orange)
                        Text(error)
                            .font(.custom("Inter", size: 14))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        
                        Button("다시 시도") {
                            loadTimeCapsules()
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color(red: 0.98, green: 0.35, blue: 0.12))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                } else {
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
                            if timeCapsules.isEmpty {
                                VStack(spacing: 20) {
                                    Image(systemName: "tray")
                                        .font(.system(size: 50))
                                        .foregroundColor(.gray.opacity(0.5))
                                    Text("아직 생성한 캡슐이 없습니다")
                                        .font(.custom("Inter", size: 14))
                                        .foregroundColor(.gray)
                                }
                                .padding(.top, geometry.size.height * 0.1)
                            } else {
                                VStack(spacing: geometry.size.height * 0.015) {
                                    ForEach(timeCapsules, id: \.id) { capsule in
                                        Button(action: {
                                            // additionalData를 capsule에 연결
                                            capsule.additionalData = additionalDataMap[capsule.id]
                                            selectedCapsule = capsule
                                            navigateToDetail = true
                                        }) {
                                            CapsuleCardView(
                                                capsule: capsule,
                                                additionalData: additionalDataMap[capsule.id]
                                            )
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                                .padding(.horizontal, geometry.size.width * 0.05)
                            }
                        }
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $navigateToDetail) {
            if let capsule = selectedCapsule {
                TimeCapsuleDetailView(timeCapsule: capsule)
            }
        }
        .onAppear {
            loadTimeCapsules()
        }
    }
    
    // MARK: - 데이터 로드
    private func loadTimeCapsules() {
        isLoading = true
        errorMessage = nil
        
        databaseService.getUserTimeCapsules { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let capsules):
                    self.timeCapsules = capsules
                    // 모든 추가 조건 가져오기
                    self.loadAdditionalData(for: capsules)
                case .failure(let error):
                    self.errorMessage = "캡슐을 불러오는데 실패했습니다: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }
    }
    
    private func loadAdditionalData(for capsules: [TimeCapsule]) {
        let group = DispatchGroup()
        var dataMap: [String: TimeCapsuleAdditionalData] = [:]
        
        for capsule in capsules {
            group.enter()
            databaseService.getAdditionalConditions(timeCapsuleId: capsule.id) { result in
                if case .success(let additional) = result {
                    dataMap[capsule.id] = additional
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            self.additionalDataMap = dataMap
            self.isLoading = false
        }
    }
}

// MARK: - CapsuleCardView
struct CapsuleCardView: View {
    let capsule: TimeCapsule
    let additionalData: TimeCapsuleAdditionalData?
    
    private var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter.string(from: capsule.createdAt)
    }
    
    private var daysLeftString: String {
        let targetDate: Date
        if let additional = additionalData,
           let timeCondition = additional.timeCondition,
           let targetDateValue = timeCondition.targetDate {
            targetDate = targetDateValue
        } else {
            // targetDate가 없으면 createdAt + 1년으로 설정
            targetDate = Calendar.current.date(byAdding: .year, value: 1, to: capsule.createdAt) ?? capsule.createdAt
        }
        
        let days = Calendar.current.dateComponents([.day], from: Date(), to: targetDate).day ?? 0
        if days > 0 {
            return "D-\(days)"
        } else if days < 0 {
            return "D+\(abs(days))"
        } else {
            return "D-Day"
        }
    }
    
    private var locationString: String {
        if let additional = additionalData,
           let location = additional.location,
           let address = location.address {
            return address
        }
        return "위치 없음"
    }
    
    private var progress: Int {
        let targetDate: Date
        if let additional = additionalData,
           let timeCondition = additional.timeCondition,
           let targetDateValue = timeCondition.targetDate {
            targetDate = targetDateValue
        } else {
            targetDate = Calendar.current.date(byAdding: .year, value: 1, to: capsule.createdAt) ?? capsule.createdAt
        }
        
        let totalDays = Calendar.current.dateComponents([.day], from: capsule.createdAt, to: targetDate).day ?? 365
        let elapsedDays = Calendar.current.dateComponents([.day], from: capsule.createdAt, to: Date()).day ?? 0
        
        guard totalDays > 0 else { return 100 }
        let progressValue = min(100, max(0, (elapsedDays * 100) / totalDays))
        return progressValue
    }
    
    private var progressColor: Color {
        if progress >= 80 {
            return Color(red: 0.67, green: 0.55, blue: 0.23).opacity(0.29)
        } else if progress >= 50 {
            return Color(red: 0.98, green: 0.74, blue: 0.02).opacity(0.60)
        } else {
            return Color(red: 0.67, green: 0.55, blue: 0.23).opacity(0.29)
        }
    }
    
    private var isUnlocked: Bool {
        // 위치 조건이 있고 현재 위치가 조건을 만족하면 언락
        if let additional = additionalData,
           let location = additional.location {
            // 위치 조건이 있는 경우 언락 여부는 실제 위치 확인이 필요하지만
            // 여기서는 간단히 D-Day가 지났는지로 판단
            let targetDate: Date
            if let timeCondition = additional.timeCondition,
               let targetDateValue = timeCondition.targetDate {
                targetDate = targetDateValue
            } else {
                targetDate = Calendar.current.date(byAdding: .year, value: 1, to: capsule.createdAt) ?? capsule.createdAt
            }
            return Date() >= targetDate
        }
        return false
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
                            Text(daysLeftString)
                                .font(.custom("Inter", size: 12))
                                .foregroundColor(.black)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Color(red: 0.85, green: 0.85, blue: 0.85))
                                .cornerRadius(15)
                            
                            Spacer()
                        }
                        
                        Text(capsule.title)
                            .font(.custom("Inter", size: 15))
                            .foregroundColor(Color(red: 0.16, green: 0.18, blue: 0.25))
                            .lineLimit(1)
                        
                        Text(dateString)
                            .font(.custom("Inter", size: 10))
                            .foregroundColor(Color(red: 0.36, green: 0.39, blue: 0.47))
                        
                        // 위치 정보
                        HStack {
                            Text(locationString)
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
