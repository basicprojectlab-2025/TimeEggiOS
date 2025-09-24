//
//  MapViewModel.swift
//  TimeEgg
//
//  Created by donghyeon choi on 9/22/25.
//

import Foundation
import CoreLocation
import Combine
import SwiftData

@Observable
class MapViewModel: NSObject {
    private var locationService: LocationServiceProtocol
    private var timeCapsuleViewModel: TimeCapsuleViewModel
    
    var timeCapsules: [TimeCapsule] = []
    var selectedTimeCapsule: TimeCapsule?
    var isLocationPermissionGranted = false
    var userLocation: CLLocation?
    
    init(locationService: LocationServiceProtocol, timeCapsuleViewModel: TimeCapsuleViewModel) {
        self.locationService = locationService
        self.timeCapsuleViewModel = timeCapsuleViewModel
        super.init()
        setupLocationService()
    }
    
    private func setupLocationService() {
        if let locationService = locationService as? LocationService {
            locationService.delegate = self
        }
        isLocationPermissionGranted = locationService.isLocationPermissionGranted
    }
    
    func requestLocationPermission() {
        locationService.requestLocationPermission()
    }
    
    func updateTimeCapsuleAnnotations() {
        timeCapsules = timeCapsuleViewModel.timeCapsules
    }
    
    func centerOnUserLocation() {
        guard let userLocation = userLocation else { return }
        // Google Maps에서는 GoogleMapsService를 통해 처리
    }
    
    func centerOnTimeCapsule(_ timeCapsule: TimeCapsule) {
        selectedTimeCapsule = timeCapsule
        // Google Maps에서는 GoogleMapsService를 통해 처리
    }
    
    func getNearbyTimeCapsules() async -> [TimeCapsule] {
        return await timeCapsuleViewModel.getNearbyTimeCapsules()
    }
    
    func getTimeCapsulesInRegion(center: CLLocationCoordinate2D, radius: Double) -> [TimeCapsule] {
        let centerLocation = CLLocation(latitude: center.latitude, longitude: center.longitude)
        
        return timeCapsules.filter { timeCapsule in
            let timeCapsuleLocation = CLLocation(
                latitude: timeCapsule.location.latitude,
                longitude: timeCapsule.location.longitude
            )
            let distance = centerLocation.distance(from: timeCapsuleLocation)
            return distance <= radius
        }
    }
}

// MARK: - LocationServiceDelegate
extension MapViewModel: LocationServiceDelegate {
    func locationDidUpdate(_ location: CLLocation) {
        userLocation = location
    }
    
    func locationPermissionDidChange(_ granted: Bool) {
        isLocationPermissionGranted = granted
    }
}
