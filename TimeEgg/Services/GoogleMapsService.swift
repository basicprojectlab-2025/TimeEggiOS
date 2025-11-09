//
//  GoogleMapsService.swift
//  TimeEgg
//
//  Created by donghyeon choi on 9/22/25.
//

import Foundation
import GoogleMaps
import GooglePlaces
import CoreLocation
import Combine

protocol GoogleMapsServiceDelegate {
    func mapDidUpdateLocation(_ location: CLLocation)
    func mapDidSelectTimeCapsule(_ timeCapsule: TimeCapsule)
    func mapDidTapAtCoordinate(_ coordinate: CLLocationCoordinate2D)
}

class GoogleMapsService: NSObject, ObservableObject {
    var delegate: GoogleMapsServiceDelegate?
    
    private var mapView: GMSMapView?
    private var markers: [String: GMSMarker] = [:]
    private var currentLocationMarker: GMSMarker?
    private var locationManager = CLLocationManager()
    
    @Published var isMapReady = false
    @Published var currentLocation: CLLocation?
    @Published var selectedTimeCapsule: TimeCapsule?
    
    override init() {
        super.init()
        setupLocationManager()
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
    }
    
    // MARK: - Map Setup
    
    func setupMapView(frame: CGRect) -> GMSMapView {
        // Google Maps API 키 설정 (실제 사용시에는 API 키를 설정해야 함)
        // GMSServices.provideAPIKey("YOUR_API_KEY")
        GMSServices.provideAPIKey("AIzaSyADHTnDs3L7M3c0t5Yv2tVOT48zaB8rGf8")
        
        let camera = GMSCameraPosition.camera(
            withLatitude: AppConstants.defaultCoordinate.latitude,
            longitude: AppConstants.defaultCoordinate.longitude,
            zoom: 15.0
        )
        
        let mapView = GMSMapView.map(withFrame: frame, camera: camera)
        mapView.delegate = self
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        mapView.settings.compassButton = true
        mapView.settings.zoomGestures = true
        mapView.settings.scrollGestures = true
        mapView.settings.rotateGestures = true
        mapView.settings.tiltGestures = true
        
        self.mapView = mapView
        isMapReady = true
        
        return mapView
    }
    
    // MARK: - TimeCapsule Markers
    
    func addTimeCapsuleMarkers(_ timeCapsules: [TimeCapsule]) {
        guard let mapView = mapView else { return }
        
        // 기존 마커들 제거
        clearTimeCapsuleMarkers()
        
        for timeCapsule in timeCapsules {
            // 위치 정보는 additionalData에서 가져옴
            guard let location = timeCapsule.additionalData?.location else { continue }
            
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2D(
                latitude: location.latitude,
                longitude: location.longitude
            )
            marker.title = timeCapsule.title
            marker.snippet = timeCapsule.memo
            marker.userData = timeCapsule
            
            // 마커 아이콘 설정 (기본 아이콘 사용)
            marker.icon = createTimeCapsuleIcon(isUnlocked: false)
            
            marker.map = mapView
            markers[timeCapsule.id] = marker
        }
    }
    
    func updateTimeCapsuleMarker(_ timeCapsule: TimeCapsule) {
        guard let marker = markers[timeCapsule.id] else { return }
        
        marker.title = timeCapsule.title
        marker.snippet = timeCapsule.memo
        marker.icon = createTimeCapsuleIcon(isUnlocked: false)
    }
    
    func removeTimeCapsuleMarker(_ timeCapsule: TimeCapsule) {
        guard let marker = markers[timeCapsule.id] else { return }
        marker.map = nil
        markers.removeValue(forKey: timeCapsule.id)
    }
    
    func clearTimeCapsuleMarkers() {
        for marker in markers.values {
            marker.map = nil
        }
        markers.removeAll()
    }
    
    // MARK: - Map Controls
    
    func moveToLocation(_ location: CLLocation, zoom: Float = 15.0) {
        guard let mapView = mapView else { return }
        
        let camera = GMSCameraPosition.camera(
            withLatitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude,
            zoom: zoom
        )
        
        mapView.animate(to: camera)
    }
    
    func moveToTimeCapsule(_ timeCapsule: TimeCapsule) {
        guard let locationData = timeCapsule.additionalData?.location else { return }
        
        let location = CLLocation(
            latitude: locationData.latitude,
            longitude: locationData.longitude
        )
        moveToLocation(location, zoom: 18.0)
        
        // 마커 선택
        if let marker = markers[timeCapsule.id] {
            mapView?.selectedMarker = marker
        }
    }
    
    func fitBoundsToShowAllMarkers() {
        guard let mapView = mapView, !markers.isEmpty else { return }
        
        var bounds = GMSCoordinateBounds()
        for marker in markers.values {
            bounds = bounds.includingCoordinate(marker.position)
        }
        
        let update = GMSCameraUpdate.fit(bounds, withPadding: 50.0)
        mapView.animate(with: update)
    }
    
    // MARK: - Helper Methods
    
    private func createTimeCapsuleIcon(isUnlocked: Bool) -> UIImage? {
        let size = CGSize(width: 30, height: 30)
        let color = isUnlocked ? UIColor.systemGreen : UIColor.systemOrange
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        defer { UIGraphicsEndImageContext() }
        
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fillEllipse(in: CGRect(origin: .zero, size: size))
        
        // 아이콘 추가
        let iconName = isUnlocked ? "lock.open.fill" : "lock.fill"
        if let icon = UIImage(systemName: iconName) {
            let iconSize = CGSize(width: 16, height: 16)
            let iconRect = CGRect(
                x: (size.width - iconSize.width) / 2,
                y: (size.height - iconSize.height) / 2,
                width: iconSize.width,
                height: iconSize.height
            )
            icon.draw(in: iconRect)
        }
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    func getCurrentCameraPosition() -> GMSCameraPosition? {
        return mapView?.camera
    }
    
    func setMapType(_ mapType: GMSMapViewType) {
        mapView?.mapType = mapType
    }
}

// MARK: - GMSMapViewDelegate
extension GoogleMapsService: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        if let timeCapsule = marker.userData as? TimeCapsule {
            selectedTimeCapsule = timeCapsule
            delegate?.mapDidSelectTimeCapsule(timeCapsule)
        }
        return true
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        delegate?.mapDidTapAtCoordinate(coordinate)
    }
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        // 카메라 위치 변경 처리
    }
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        // 카메라 이동 완료 처리
    }
}

// MARK: - CLLocationManagerDelegate
extension GoogleMapsService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        currentLocation = location
        delegate?.mapDidUpdateLocation(location)
        
        // 현재 위치 마커 업데이트
        if currentLocationMarker == nil {
            currentLocationMarker = GMSMarker()
            currentLocationMarker?.title = "내 위치"
            currentLocationMarker?.icon = GMSMarker.markerImage(with: .blue)
        }
        
        currentLocationMarker?.position = location.coordinate
        currentLocationMarker?.map = mapView
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        case .denied, .restricted:
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        @unknown default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("위치 업데이트 실패: \(error)")
    }
}
