//
//  TimeCapsuleViewModel.swift
//  TimeEgg
//
//  Created by donghyeon choi on 9/22/25.
//

import Foundation
import SwiftData
import CoreLocation
import Combine

@Observable
class TimeCapsuleViewModel {
    private var modelContext: ModelContext
    private var locationService: LocationServiceProtocol
    private var notificationService: NotificationServiceProtocol
    
    var timeCapsules: [TimeCapsule] = []
    var currentUser: User?
    var isLoading = false
    var errorMessage: String?
    
    init(modelContext: ModelContext, locationService: LocationServiceProtocol, notificationService: NotificationServiceProtocol) {
        self.modelContext = modelContext
        self.locationService = locationService
        self.notificationService = notificationService
        Task {
            await loadTimeCapsules()
        }
    }
    
    // MARK: - TimeCapsule Management
    
    func createTimeCapsule(
        title: String,
        content: String,
        photos: [Data],
        arPhotos: [Data]? = nil,
        stickers: [StickerData]? = nil,
        isPublic: Bool = false,
        taggedUsers: [String] = []
    ) async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            guard let currentLocation = await locationService.getCurrentLocation() else {
                await MainActor.run {
                    errorMessage = "위치 정보를 가져올 수 없습니다."
                    isLoading = false
                }
                return
            }
            
            let locationData = LocationData(
                latitude: currentLocation.coordinate.latitude,
                longitude: currentLocation.coordinate.longitude,
                address: await locationService.getAddress(from: currentLocation)
            )
            
            let timeCapsule = TimeCapsule(
                title: title,
                content: content,
                photos: photos,
                arPhotos: arPhotos,
                stickers: stickers,
                location: locationData,
                isPublic: isPublic,
                taggedUsers: taggedUsers,
                creatorId: currentUser?.id ?? ""
            )
            
            modelContext.insert(timeCapsule)
            try modelContext.save()
            
            // 태그된 사용자들에게 알림 전송
            if !taggedUsers.isEmpty {
                await notificationService.sendTagNotification(
                    timeCapsuleId: timeCapsule.id,
                    taggedUsers: taggedUsers,
                    senderId: currentUser?.id ?? ""
                )
            }
            
            await loadTimeCapsules()
            
        } catch {
            await MainActor.run {
                errorMessage = "타임캡슐 생성에 실패했습니다: \(error.localizedDescription)"
            }
        }
        
        await MainActor.run {
            isLoading = false
        }
    }
    
    func unlockTimeCapsule(_ timeCapsule: TimeCapsule) async {
        do {
            guard let currentLocation = await locationService.getCurrentLocation() else {
                errorMessage = "위치 정보를 가져올 수 없습니다."
                return
            }
            
            let timeCapsuleLocation = CLLocation(
                latitude: timeCapsule.location.latitude,
                longitude: timeCapsule.location.longitude
            )
            
            let distance = currentLocation.distance(from: timeCapsuleLocation)
            
            if distance <= timeCapsule.location.radius {
                timeCapsule.isUnlocked = true
                try modelContext.save()
                
                // 잠금 해제 알림 전송
                await notificationService.sendUnlockNotification(
                    timeCapsuleId: timeCapsule.id,
                    receiverId: timeCapsule.creatorId
                )
            } else {
                errorMessage = "타임캡슐 위치에 가까이 가야 합니다. (현재 거리: \(Int(distance))m)"
            }
        } catch {
            errorMessage = "타임캡슐 잠금 해제에 실패했습니다: \(error.localizedDescription)"
        }
    }
    
    func loadTimeCapsules() async {
        do {
            let descriptor = FetchDescriptor<TimeCapsule>(
                sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
            )
            timeCapsules = try modelContext.fetch(descriptor)
        } catch {
            errorMessage = "타임캡슐 목록을 불러오는데 실패했습니다: \(error.localizedDescription)"
        }
    }
    
    func getNearbyTimeCapsules() async -> [TimeCapsule] {
        guard let currentLocation = await locationService.getCurrentLocation() else {
            return []
        }
        
        return timeCapsules.filter { timeCapsule in
            let timeCapsuleLocation = CLLocation(
                latitude: timeCapsule.location.latitude,
                longitude: timeCapsule.location.longitude
            )
            let distance = currentLocation.distance(from: timeCapsuleLocation)
            return distance <= 1000 // 1km 반경 내의 타임캡슐
        }
    }
}
