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

struct MapView: View {
    @State private var googleMapsService = GoogleMapsService()
    @State private var showingMapTypeSelector = false
    let showControls: Bool
    
    init(showControls: Bool = true) {
        self.showControls = showControls
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Google Maps
                GoogleMapsView(googleMapsService: googleMapsService)
                    .ignoresSafeArea()
                
                // 상단 컨트롤 (조건부 표시)
                if showControls {
                    VStack {
                        
                        HStack {
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
                }
            }
            .navigationTitle("지도")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                setupGoogleMaps()
            }
            .sheet(isPresented: $showingMapTypeSelector) {
                MapTypeSelectorView(googleMapsService: googleMapsService)
            }
        }
    }
    
    private func setupGoogleMaps() {
        googleMapsService.delegate = self
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
extension MapView: GoogleMapsServiceDelegate {
    func mapDidUpdateLocation(_ location: CLLocation) {
        // 위치 업데이트 처리
    }
    
    func mapDidSelectTimeCapsule(_ timeCapsule: TimeCapsule) {
        // 타임캡슐 선택 처리 (사용하지 않음)
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

#Preview {
    MapView()
        .onAppear {
            // Preview용 초기화
        }
}
