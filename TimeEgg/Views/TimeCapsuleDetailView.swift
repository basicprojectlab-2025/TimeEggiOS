//
//  TimeCapsuleDetailView.swift
//  TimeEgg
//
//  Created by donghyeon choi on 9/22/25.
//

import SwiftUI
import MapKit

// Note: TimeCapsule.swift의 모델을 사용합니다. (내장 DB 사용 안 함)

struct TimeCapsuleDetailView: View {
    let timeCapsule: TimeCapsule
    @Environment(\.dismiss) private var dismiss
    @State private var showingShareSheet = false
    @State private var loadedImages: [UIImage] = []
    @State private var isLoadingImages = false
    
    // 잠금 해제 여부 확인
    private var isUnlocked: Bool {
        if let additional = timeCapsule.additionalData,
           let timeCondition = additional.timeCondition,
           let targetDate = timeCondition.targetDate {
            return Date() >= targetDate
        }
        // 시간 조건이 없으면 항상 열람 가능
        return true
    }
    
    // 잠금 해제 날짜
    private var unlockDate: Date? {
        return timeCapsule.additionalData?.timeCondition?.targetDate
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // 제목과 상태
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(timeCapsule.title)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            // 공개 범위 표시
                            Text(timeCapsule.privacy)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.blue.opacity(0.2), in: Capsule())
                                .foregroundColor(.blue)
                        }
                        
                        HStack {
                            Text(timeCapsule.createdAt, style: .date)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            // 잠금 해제 상태 표시
                            if let unlockDate = unlockDate {
                                if isUnlocked {
                                    Label("잠금 해제됨", systemImage: "lock.open.fill")
                                        .font(.caption)
                                        .foregroundColor(.green)
                                } else {
                                    Label("잠금됨", systemImage: "lock.fill")
                                        .font(.caption)
                                        .foregroundColor(.orange)
                                }
                            }
                        }
                    }
                    
                    // 잠금 상태에 따라 내용 표시
                    if isUnlocked {
                        // 잠금 해제됨 - 내용 표시
                        unlockedContentView
                    } else {
                        // 잠금됨 - 잠금 메시지 표시
                        lockedContentView
                    }
                    
                }
                .padding()
            }
            .navigationTitle("타임캡슐")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("닫기") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("공유") {
                        showingShareSheet = true
                    }
                }
            }
            .sheet(isPresented: $showingShareSheet) {
                ShareSheet(items: [timeCapsule.title, timeCapsule.memo])
            }
        }
    }
    
    private func loadImages(from urls: [String]) {
        isLoadingImages = true
        loadedImages = []
        
        Task {
            var images: [UIImage] = []
            
            for urlString in urls {
                guard let url = URL(string: urlString) else { continue }
                
                do {
                    let (data, _) = try await URLSession.shared.data(from: url)
                    if let image = UIImage(data: data) {
                        images.append(image)
                    }
                } catch {
                    print("이미지 로드 실패: \(error)")
                }
            }
            
            await MainActor.run {
                loadedImages = images
                isLoadingImages = false
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 MM월 dd일 HH:mm"
        return dateFormatter.string(from: date)
    }
    
    private func formatTimeRemaining(_ targetDate: Date) -> String {
        let timeRemaining = targetDate.timeIntervalSinceNow
        let days = Int(timeRemaining / 86400)
        let hours = Int((timeRemaining.truncatingRemainder(dividingBy: 86400)) / 3600)
        let minutes = Int((timeRemaining.truncatingRemainder(dividingBy: 3600)) / 60)
        return "\(days)일 \(hours)시간 \(minutes)분"
    }
    
    // MARK: - 잠금 해제된 내용 뷰
    @ViewBuilder
    private var unlockedContentView: some View {
        // 내용
        VStack(alignment: .leading, spacing: 12) {
            Text("내용")
                .font(.headline)
            
            Text(timeCapsule.memo)
                .font(.body)
                .padding()
                .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 8))
        }
        
        // 사진들
        if let photoUrls = timeCapsule.photoUrls, !photoUrls.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text("사진")
                    .font(.headline)
                
                if isLoadingImages {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding()
                } else if !loadedImages.isEmpty {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 10) {
                        ForEach(Array(loadedImages.enumerated()), id: \.offset) { index, image in
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 150)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                }
            }
            .onAppear {
                loadImages(from: photoUrls)
            }
        }
        
        // 위치 정보
        if let location = timeCapsule.additionalData?.location {
            VStack(alignment: .leading, spacing: 12) {
                Text("위치")
                    .font(.headline)
                
                if let address = location.address {
                    Text(address)
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                
                // 미니 지도
                Map(position: .constant(.region(MKCoordinateRegion(
                    center: location.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                )))) {
                    Marker("", coordinate: location.coordinate)
                        .tint(.orange)
                }
                .frame(height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        
        // 날씨 정보
        if let weather = timeCapsule.additionalData?.weather {
            VStack(alignment: .leading, spacing: 12) {
                Text("날씨 조건")
                    .font(.headline)
                
                Text(weather)
                    .font(.body)
                    .padding()
                    .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 8))
            }
        }
        
        // 시간 조건 정보
        if let timeCondition = timeCapsule.additionalData?.timeCondition {
            VStack(alignment: .leading, spacing: 12) {
                Text("잠금 해제 시간")
                    .font(.headline)
                
                if let targetDate = timeCondition.targetDate {
                    Text("해제 시간: \(formatDate(targetDate))")
                        .font(.body)
                    
                    Text("잠금이 해제되었습니다!")
                        .font(.caption)
                        .foregroundColor(.green)
                        .padding(.top, 4)
                }
                
                if let timeRange = timeCondition.timeRange {
                    Text("시간 범위: \(timeRange.startTime) ~ \(timeRange.endTime)")
                        .font(.body)
                }
            }
            .padding()
            .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 8))
        }
    }
    
    // MARK: - 잠금된 내용 뷰
    @ViewBuilder
    private var lockedContentView: some View {
        VStack(spacing: 30) {
            Spacer()
                .frame(height: 50)
            
            // 잠금 아이콘
            ZStack {
                Circle()
                    .fill(Color(red: 0.50, green: 0.23, blue: 0.27).opacity(0.2))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "lock.fill")
                    .font(.system(size: 60))
                    .foregroundColor(Color(red: 0.50, green: 0.23, blue: 0.27))
            }
            
            // 잠금 메시지
            VStack(spacing: 12) {
                Text("아직 열람할 수 없습니다")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color(red: 0.24, green: 0.24, blue: 0.24))
                
                if let unlockDate = unlockDate {
                    Text("잠금 해제 시간")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text(formatDate(unlockDate))
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(Color(red: 0.98, green: 0.53, blue: 0.12))
                    
                    Text("남은 시간: \(formatTimeRemaining(unlockDate))")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .padding(.top, 8)
                }
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    let sampleTimeCapsule = TimeCapsule(
        id: "sample-id",
        title: "샘플 타임캡슐",
        memo: "이것은 샘플 타임캡슐입니다.",
        privacy: "전체공개",
        creatorId: "sample-user"
    )
    
    TimeCapsuleDetailView(timeCapsule: sampleTimeCapsule)
}

