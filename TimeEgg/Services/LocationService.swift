//
//  LocationService.swift
//  TimeEgg
//
//  Created by donghyeon choi on 9/22/25.
//

import Foundation
import CoreLocation
import MapKit
import Combine

protocol LocationServiceDelegate: AnyObject {
    func locationDidUpdate(_ location: CLLocation)
    func locationPermissionDidChange(_ granted: Bool)
}

protocol LocationServiceProtocol {
    var isLocationPermissionGranted: Bool { get }
    func requestLocationPermission()
    func getCurrentLocation() async -> CLLocation?
    func getAddress(from location: CLLocation) async -> String?
}

class LocationService: NSObject, ObservableObject, LocationServiceProtocol {
    weak var delegate: LocationServiceDelegate?
    
    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()
    
    @Published var currentLocation: CLLocation?
    @Published var isLocationPermissionGranted = false
    
    override init() {
        super.init()
        setupLocationManager()
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10 // 10미터마다 업데이트
        
        checkLocationPermission()
    }
    
    private func checkLocationPermission() {
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            isLocationPermissionGranted = true
            locationManager.startUpdatingLocation()
        case .denied, .restricted:
            isLocationPermissionGranted = false
        case .notDetermined:
            isLocationPermissionGranted = false
        @unknown default:
            isLocationPermissionGranted = false
        }
    }
    
    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func getCurrentLocation() async -> CLLocation? {
        return currentLocation
    }
    
    func getAddress(from location: CLLocation) async -> String? {
        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(location)
            return placemarks.first?.formattedAddress
        } catch {
            print("주소 변환 실패: \(error)")
            return nil
        }
    }
    
    func getCoordinate(from address: String) async -> CLLocationCoordinate2D? {
        do {
            let placemarks = try await geocoder.geocodeAddressString(address)
            return placemarks.first?.location?.coordinate
        } catch {
            print("좌표 변환 실패: \(error)")
            return nil
        }
    }
    
    func calculateDistance(from: CLLocation, to: CLLocation) -> CLLocationDistance {
        return from.distance(from: to)
    }
    
    func isWithinRadius(_ location: CLLocation, center: CLLocation, radius: Double) -> Bool {
        let distance = calculateDistance(from: location, to: center)
        return distance <= radius
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        currentLocation = location
        delegate?.locationDidUpdate(location)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            isLocationPermissionGranted = true
            locationManager.startUpdatingLocation()
        case .denied, .restricted:
            isLocationPermissionGranted = false
            locationManager.stopUpdatingLocation()
        case .notDetermined:
            isLocationPermissionGranted = false
        @unknown default:
            isLocationPermissionGranted = false
        }
        
        delegate?.locationPermissionDidChange(isLocationPermissionGranted)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("위치 업데이트 실패: \(error)")
    }
}

// MARK: - CLPlacemark Extension
extension CLPlacemark {
    var formattedAddress: String {
        var addressComponents: [String] = []
        
        if let subThoroughfare = subThoroughfare {
            addressComponents.append(subThoroughfare)
        }
        if let thoroughfare = thoroughfare {
            addressComponents.append(thoroughfare)
        }
        if let locality = locality {
            addressComponents.append(locality)
        }
        if let administrativeArea = administrativeArea {
            addressComponents.append(administrativeArea)
        }
        if let country = country {
            addressComponents.append(country)
        }
        
        return addressComponents.joined(separator: " ")
    }
}
