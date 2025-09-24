//
//  TimeCapsuleDetailView.swift
//  TimeEgg
//
//  Created by donghyeon choi on 9/22/25.
//

import SwiftUI
import MapKit

struct TimeCapsuleDetailView: View {
    let timeCapsule: TimeCapsule
    @Environment(\.dismiss) private var dismiss
    @State private var timeCapsuleViewModel: TimeCapsuleViewModel?
    @State private var showingShareSheet = false
    @State private var showingUnlockAlert = false
    
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
                            
                            Image(systemName: timeCapsule.isUnlocked ? "lock.open.fill" : "lock.fill")
                                .font(.title2)
                                .foregroundColor(timeCapsule.isUnlocked ? .green : .orange)
                        }
                        
                        HStack {
                            Text(timeCapsule.createdAt, style: .date)
                                .foregroundColor(.secondary)
                            
                            if timeCapsule.isPublic {
                                Text("• 공개")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    
                    // 내용
                    if timeCapsule.isUnlocked {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("내용")
                                .font(.headline)
                            
                            Text(timeCapsule.content)
                                .font(.body)
                                .padding()
                                .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 8))
                        }
                        
                        // 사진들
                        if !timeCapsule.photos.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("사진")
                                    .font(.headline)
                                
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 10) {
                                    ForEach(Array(timeCapsule.photos.enumerated()), id: \.offset) { index, photoData in
                                        if let image = UIImage(data: photoData) {
                                            Image(uiImage: image)
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(height: 150)
                                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                        }
                                    }
                                }
                            }
                        }
                        
                        // AR 사진들
                        if let arPhotos = timeCapsule.arPhotos, !arPhotos.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("AR 사진")
                                    .font(.headline)
                                
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 10) {
                                    ForEach(Array(arPhotos.enumerated()), id: \.offset) { index, photoData in
                                        if let image = UIImage(data: photoData) {
                                            Image(uiImage: image)
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(height: 150)
                                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                        }
                                    }
                                }
                            }
                        }
                        
                        // 위치 정보
                        VStack(alignment: .leading, spacing: 12) {
                            Text("위치")
                                .font(.headline)
                            
                            if let address = timeCapsule.location.address {
                                Text(address)
                                    .font(.body)
                                    .foregroundColor(.secondary)
                            }
                            
                            // 미니 지도
                            Map(coordinateRegion: .constant(MKCoordinateRegion(
                                center: timeCapsule.location.coordinate,
                                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                            )), annotationItems: [timeCapsule]) { _ in
                                MapPin(coordinate: timeCapsule.location.coordinate, tint: .orange)
                            }
                            .frame(height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        
                    } else {
                        // 잠금 상태
                        VStack(spacing: 20) {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.orange)
                            
                            Text("이 타임캡슐은 잠겨있습니다")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Text("타임캡슐이 생성된 위치에 가야만 내용을 볼 수 있습니다.")
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                            
                            Button("잠금 해제 시도") {
                                showingUnlockAlert = true
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 12))
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
                
                if timeCapsule.isUnlocked {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("공유") {
                            showingShareSheet = true
                        }
                    }
                }
            }
            .alert("잠금 해제", isPresented: $showingUnlockAlert) {
                Button("시도") {
                    Task {
                        if let timeCapsuleViewModel = timeCapsuleViewModel {
                            await timeCapsuleViewModel.unlockTimeCapsule(timeCapsule)
                        }
                    }
                }
                Button("취소", role: .cancel) { }
            } message: {
                Text("현재 위치에서 타임캡슐을 잠금 해제하시겠습니까?")
            }
            .sheet(isPresented: $showingShareSheet) {
                ShareSheet(items: [timeCapsule.title, timeCapsule.content])
            }
        }
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
        title: "샘플 타임캡슐",
        content: "이것은 샘플 타임캡슐입니다.",
        location: LocationData(latitude: 37.5665, longitude: 126.9780, address: "서울특별시 중구"),
        isPublic: true,
        creatorId: "sample-user"
    )
    
    TimeCapsuleDetailView(timeCapsule: sampleTimeCapsule)
}
