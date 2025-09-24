//
//  SimpleContentView.swift
//  TimeEgg
//
//  Created by donghyeon choi on 9/22/25.
//

import SwiftUI

struct SimpleContentView: View {
    @State private var showMainApp = false
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "egg.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            Text("TimeEgg")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("타임캡슐 앱에 오신 것을 환영합니다!")
                .font(.headline)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            VStack(spacing: 15) {
                FeatureRow(icon: "camera.fill", title: "사진 촬영", description: "소중한 순간을 기록하세요")
                FeatureRow(icon: "map.fill", title: "위치 기반", description: "특별한 장소에 타임캡슐을 남기세요")
                FeatureRow(icon: "lock.fill", title: "잠금 기능", description: "다시 그 장소에 가야만 열 수 있어요")
                FeatureRow(icon: "person.2.fill", title: "공유 기능", description: "친구들과 함께 타임캡슐을 공유하세요")
            }
            .padding()
            
            // 기능 버튼들
            VStack(spacing: 12) {
                // 메인 앱 시작 버튼
                Button(action: {
                    showMainApp = true
                }) {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("TimeEgg 시작하기")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 15)
                    .background(Color.blue, in: Capsule())
                }
                
                // 빠른 액션 버튼들
                HStack(spacing: 12) {
                    QuickActionButton(
                        icon: "camera.fill",
                        title: "카메라",
                        color: .green
                    ) {
                        // 카메라 기능으로 이동
                    }
                    
                    QuickActionButton(
                        icon: "map.fill",
                        title: "지도",
                        color: .orange
                    ) {
                        // 지도 기능으로 이동
                    }
                    
                    QuickActionButton(
                        icon: "plus.circle.fill",
                        title: "새 타임캡슐",
                        color: .purple
                    ) {
                        // 새 타임캡슐 생성으로 이동
                    }
                }
            }
            .padding(.top, 20)
            
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .fullScreenCover(isPresented: $showMainApp) {
            ContentView()
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

struct QuickActionButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .foregroundColor(.white)
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(color, in: RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    SimpleContentView()
}
