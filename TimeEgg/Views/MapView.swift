//
//  MapView.swift
//  TimeEgg
//
//  Created by donghyeon choi on 9/22/25.
//

import SwiftUI
import GoogleMaps
import GooglePlaces
import CoreLocation
import UIKit
import SwiftData

struct TimeEggMapView: View {
    @State private var mapViewModel: MapViewModel
    @State private var googleMapsService = GoogleMapsService()
    @State private var showingTimeCapsuleDetail = false
    @State private var selectedTimeCapsule: TimeCapsule?
    @State private var showingCreateTimeCapsule = false
    @State private var showingMapTypeSelector = false
    
    init(mapViewModel: MapViewModel) {
        self._mapViewModel = State(initialValue: mapViewModel)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Google Maps
                GoogleMapsView(googleMapsService: googleMapsService)
                    .ignoresSafeArea()
                
                // 상단 컨트롤
                VStack {
                    HStack {
                        // 위치 권한 요청 버튼
                        if !mapViewModel.isLocationPermissionGranted {
                            Button("위치 권한 허용") {
                                mapViewModel.requestLocationPermission()
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        
                        Spacer()
                        
                        // 지도 타입 선택 버튼
                        Button(action: { showingMapTypeSelector = true }) {
                            Image(systemName: "map")
                                .font(.title2)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.blue, in: Circle())
                        }
                        
                        // 내 위치로 이동 버튼
                        Button(action: { 
                            if let location = googleMapsService.currentLocation {
                                googleMapsService.moveToLocation(location)
                            }
                        }) {
                            Image(systemName: "location.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.blue, in: Circle())
                        }
                    }
                    .padding()
                    
                    Spacer()
                }
                
                // 하단 타임캡슐 정보
                if let selectedTimeCapsule = selectedTimeCapsule {
                    VStack {
                        Spacer()
                        TimeCapsuleInfoCard(timeCapsule: selectedTimeCapsule) {
                            showingTimeCapsuleDetail = true
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("타임캡슐 지도")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("새 타임캡슐") {
                        showingCreateTimeCapsule = true
                    }
                }
            }
            .onAppear {
                setupGoogleMaps()
            }
            .sheet(isPresented: $showingTimeCapsuleDetail) {
                if let timeCapsule = selectedTimeCapsule {
                    TimeCapsuleDetailView(timeCapsule: timeCapsule)
                }
            }
            .sheet(isPresented: $showingCreateTimeCapsule) {
                CreateTimeCapsuleView()
            }
            .sheet(isPresented: $showingMapTypeSelector) {
                MapTypeSelectorView(googleMapsService: googleMapsService)
            }
        }
    }
    
    private func setupGoogleMaps() {
        googleMapsService.delegate = self
        mapViewModel.updateTimeCapsuleAnnotations()
        
        // 타임캡슐 마커들을 Google Maps에 추가
        googleMapsService.addTimeCapsuleMarkers(mapViewModel.timeCapsules)
    }
}

// MARK: - GoogleMapsView
struct GoogleMapsView: UIViewRepresentable {
    let googleMapsService: GoogleMapsService
    
    func makeUIView(context: Context) -> GMSMapView {
        return googleMapsService.setupMapView(frame: .zero)
    }
    
    func updateUIView(_ uiView: GMSMapView, context: Context) {
        // 필요시 업데이트 로직
    }
}

// MARK: - GoogleMapsServiceDelegate
extension TimeEggMapView: GoogleMapsServiceDelegate {
    func mapDidUpdateLocation(_ location: CLLocation) {
        // 위치 업데이트 처리
    }
    
    func mapDidSelectTimeCapsule(_ timeCapsule: TimeCapsule) {
        selectedTimeCapsule = timeCapsule
    }
    
    func mapDidTapAtCoordinate(_ coordinate: CLLocationCoordinate2D) {
        // 지도 탭 처리
    }
}

// MARK: - MapTypeSelectorView
struct MapTypeSelectorView: View {
    let googleMapsService: GoogleMapsService
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                Section("지도 타입") {
                    Button("일반") {
                        googleMapsService.setMapType(.normal)
                        dismiss()
                    }
                    
                    Button("위성") {
                        googleMapsService.setMapType(.satellite)
                        dismiss()
                    }
                    
                    Button("하이브리드") {
                        googleMapsService.setMapType(.hybrid)
                        dismiss()
                    }
                    
                    Button("지형") {
                        googleMapsService.setMapType(.terrain)
                        dismiss()
                    }
                }
            }
            .navigationTitle("지도 타입")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("닫기") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct TimeCapsuleMapPin: View {
    let timeCapsule: TimeCapsule
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                Circle()
                    .fill(timeCapsule.isUnlocked ? Color.green : Color.orange)
                    .frame(width: 30, height: 30)
                
                Image(systemName: timeCapsule.isUnlocked ? "lock.open.fill" : "lock.fill")
                    .foregroundColor(.white)
                    .font(.caption)
            }
        }
        .scaleEffect(isSelected ? 1.2 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

struct TimeCapsuleInfoCard: View {
    let timeCapsule: TimeCapsule
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
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
                    .lineLimit(2)
                
                HStack {
                    Text(timeCapsule.createdAt, style: .date)
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
            .customShadow(radius: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    TimeEggMapView(mapViewModel: MapViewModel(
        locationService: LocationService(),
        timeCapsuleViewModel: TimeCapsuleViewModel(
            modelContext: ModelContext(try! ModelContainer(for: TimeCapsule.self)),
            locationService: LocationService(),
            notificationService: NotificationService()
        )
    ))
}
