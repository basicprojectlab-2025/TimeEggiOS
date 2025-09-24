//
//  ContentView.swift
//  TimeEgg
//
//  Created by donghyeon choi on 9/22/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selectedTab = 0
    @State private var timeCapsuleViewModel: TimeCapsuleViewModel?
    @State private var mapViewModel: MapViewModel?
    @State private var locationService = LocationService()
    @State private var notificationService = NotificationService()
    
    var body: some View {
        Group {
            if timeCapsuleViewModel == nil || mapViewModel == nil {
                // 로딩 화면
                VStack {
                    ProgressView()
                        .scaleEffect(1.5)
                    Text("TimeEgg을 시작하는 중...")
                        .font(.headline)
                        .padding(.top)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemBackground))
            } else {
                TabView(selection: $selectedTab) {
                    // 홈 탭
                    HomeView()
                        .tabItem {
                            Image(systemName: "house.fill")
                            Text("홈")
                        }
                        .tag(0)
                    
                    // 지도 탭
                    if let mapViewModel = mapViewModel {
                        TimeEggMapView(mapViewModel: mapViewModel)
                            .tabItem {
                                Image(systemName: "map.fill")
                                Text("지도")
                            }
                            .tag(1)
                    }
                    
                    // 카메라 탭
                    CameraView()
                        .tabItem {
                            Image(systemName: "camera.fill")
                            Text("카메라")
                        }
                        .tag(2)
                    
                    // 알림 탭
                    NotificationView()
                        .tabItem {
                            Image(systemName: "bell.fill")
                            Text("알림")
                        }
                        .tag(3)
                    
                    // 프로필 탭
                    ProfileView()
                        .tabItem {
                            Image(systemName: "person.fill")
                            Text("프로필")
                        }
                        .tag(4)
                }
                .accentColor(.timeEggPrimary)
            }
        }
        .onAppear {
            setupViewModels()
        }
    }
    
    private func setupViewModels() {
        // 이미 초기화되었으면 다시 하지 않음
        guard timeCapsuleViewModel == nil else { return }
        
        timeCapsuleViewModel = TimeCapsuleViewModel(
            modelContext: modelContext,
            locationService: locationService,
            notificationService: notificationService
        )
        
        if let timeCapsuleViewModel = timeCapsuleViewModel {
            mapViewModel = MapViewModel(
                locationService: locationService,
                timeCapsuleViewModel: timeCapsuleViewModel
            )
        }
        
        notificationService.setModelContext(modelContext)
    }
}

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var timeCapsules: [TimeCapsule]
    @State private var showingCreateTimeCapsule = false

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 16) {
                    // 최근 타임캡슐들
                    ForEach(timeCapsules.prefix(5)) { timeCapsule in
                        TimeCapsuleCard(timeCapsule: timeCapsule)
                    }
                }
                .padding()
            }
            .navigationTitle("TimeEgg")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("새 타임캡슐") {
                        showingCreateTimeCapsule = true
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .sheet(isPresented: $showingCreateTimeCapsule) {
                CreateTimeCapsuleView()
            }
        }
    }
}

struct TimeCapsuleCard: View {
    let timeCapsule: TimeCapsule
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(timeCapsule.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: timeCapsule.isUnlocked ? "lock.open.fill" : "lock.fill")
                    .foregroundColor(timeCapsule.isUnlocked ? .green : .orange)
            }
            
            Text(timeCapsule.content)
                .font(.body)
                .foregroundColor(.secondary)
                .lineLimit(3)
            
            HStack {
                Text(timeCapsule.createdAt.formattedString())
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if timeCapsule.isPublic {
                    Text("공개")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.2), in: Capsule())
                        .foregroundColor(.blue)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 12))
        .shadow(radius: 4)
    }
}

struct NotificationView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var notifications: [TimeEggNotification]
    
    var body: some View {
        NavigationView {
            List {
                ForEach(notifications) { notification in
                    NotificationRow(notification: notification)
                }
            }
            .navigationTitle("알림")
        }
    }
}

struct NotificationRow: View {
    let notification: TimeEggNotification
    
    var body: some View {
        HStack {
            Image(systemName: notificationTypeIcon(notification.type))
                .foregroundColor(.blue)
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(notification.title)
                    .font(.headline)
                    .foregroundColor(notification.isRead ? .secondary : .primary)
                
                Text(notification.message)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                Text(notification.createdAt.timeAgo())
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if !notification.isRead {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 8, height: 8)
            }
        }
        .padding(.vertical, 4)
    }
    
    private func notificationTypeIcon(_ type: NotificationType) -> String {
        switch type {
        case .timeCapsuleTagged:
            return "tag.fill"
        case .timeCapsuleUnlocked:
            return "lock.open.fill"
        case .newPublicTimeCapsule:
            return "globe"
        case .friendRequest:
            return "person.badge.plus"
        case .system:
            return "gear"
        }
    }
}

struct ProfileView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var showingSettings = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // 프로필 이미지
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.timeEggPrimary)
                
                Text("사용자 이름")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("user@example.com")
                    .foregroundColor(.secondary)
                
                Spacer()
                
                // 설정 버튼
                Button("설정") {
                    showingSettings = true
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .navigationTitle("프로필")
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
        }
    }
}

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var notificationEnabled = true
    @State private var locationSharingEnabled = true
    @State private var publicTimeCapsuleVisible = true
    
    var body: some View {
        NavigationView {
            Form {
                Section("알림") {
                    Toggle("알림 허용", isOn: $notificationEnabled)
                }
                
                Section("위치") {
                    Toggle("위치 공유", isOn: $locationSharingEnabled)
                }
                
                Section("타임캡슐") {
                    Toggle("공개 타임캡슐 표시", isOn: $publicTimeCapsuleVisible)
                }
                
                Section("정보") {
                    HStack {
                        Text("앱 버전")
                        Spacer()
                        Text(AppConstants.appVersion)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("설정")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("완료") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [TimeCapsule.self, User.self, TimeEggNotification.self], inMemory: true)
}
