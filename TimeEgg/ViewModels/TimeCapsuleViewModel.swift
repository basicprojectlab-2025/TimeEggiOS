//
//  TimeCapsuleViewModel.swift
//  TimeEgg
//
//  Created by donghyeon choi on 9/22/25.
//

import Foundation
import CoreLocation
import Combine
import FirebaseAuth
import FirebaseDatabase

// Note: TimeCapsule.swift의 모델을 사용합니다. (내장 DB 사용 안 함)

@Observable
class TimeCapsuleViewModel {
    private var databaseService: RealtimeDatabaseService
    private var locationService: LocationServiceProtocol
    private var notificationService: NotificationServiceProtocol?
    
    var timeCapsules: [TimeCapsule] = []
    var isLoading = false
    var errorMessage: String?
    
    init(databaseService: RealtimeDatabaseService = RealtimeDatabaseService(), locationService: LocationServiceProtocol, notificationService: NotificationServiceProtocol? = nil) {
        self.databaseService = databaseService
        self.locationService = locationService
        self.notificationService = notificationService
        Task {
            await loadTimeCapsules()
        }
    }
    
    // MARK: - TimeCapsule Management
    
    func loadTimeCapsules() async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        guard let userId = Auth.auth().currentUser?.uid else {
            await MainActor.run {
                errorMessage = "사용자가 로그인되지 않았습니다."
                isLoading = false
            }
            return
        }
        
        databaseService.getUserTimeCapsules { result in
            DispatchQueue.main.async {
                self.isLoading = false
                
                switch result {
                case .success(let capsules):
                    self.timeCapsules = capsules
                case .failure(let error):
                    self.errorMessage = "타임캡슐 목록을 불러오는데 실패했습니다: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func getNearbyTimeCapsules() async -> [TimeCapsule] {
        guard let currentLocation = await locationService.getCurrentLocation() else {
            return []
        }
        
        return timeCapsules.filter { timeCapsule in
            guard let location = timeCapsule.additionalData?.location else { return false }
            
            let timeCapsuleLocation = CLLocation(
                latitude: location.latitude,
                longitude: location.longitude
            )
            let distance = currentLocation.distance(from: timeCapsuleLocation)
            return distance <= location.radius
        }
    }
    
    func getTimeCapsulesInRegion(center: CLLocationCoordinate2D, radius: Double) -> [TimeCapsule] {
        let centerLocation = CLLocation(latitude: center.latitude, longitude: center.longitude)
        
        return timeCapsules.filter { timeCapsule in
            guard let location = timeCapsule.additionalData?.location else { return false }
            
            let timeCapsuleLocation = CLLocation(
                latitude: location.latitude,
                longitude: location.longitude
            )
            let distance = centerLocation.distance(from: timeCapsuleLocation)
            return distance <= radius
        }
    }
}
