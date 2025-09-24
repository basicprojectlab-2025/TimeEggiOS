//
//  NotificationService.swift
//  TimeEgg
//
//  Created by donghyeon choi on 9/22/25.
//

import Foundation
import UserNotifications
import SwiftData
import Combine

protocol NotificationServiceProtocol {
    func setModelContext(_ context: ModelContext)
    func sendTagNotification(timeCapsuleId: UUID, taggedUsers: [String], senderId: String) async
    func sendUnlockNotification(timeCapsuleId: UUID, receiverId: String) async
}

class NotificationService: NSObject, ObservableObject, NotificationServiceProtocol {
    private let notificationCenter = UNUserNotificationCenter.current()
    private var modelContext: ModelContext?
    
    @Published var isNotificationPermissionGranted = false
    
    override init() {
        super.init()
        notificationCenter.delegate = self
        checkNotificationPermission()
    }
    
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }
    
    // MARK: - Permission Management
    
    private func checkNotificationPermission() {
        notificationCenter.getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                self?.isNotificationPermissionGranted = settings.authorizationStatus == .authorized
            }
        }
    }
    
    func requestNotificationPermission() async -> Bool {
        do {
            let granted = try await notificationCenter.requestAuthorization(options: [.alert, .sound, .badge])
            await MainActor.run {
                self.isNotificationPermissionGranted = granted
            }
            return granted
        } catch {
            print("알림 권한 요청 실패: \(error)")
            await MainActor.run {
                self.isNotificationPermissionGranted = false
            }
            return false
        }
    }
    
    // MARK: - Local Notifications
    
    func scheduleLocalNotification(
        title: String,
        body: String,
        timeInterval: TimeInterval = 1.0,
        identifier: String? = nil
    ) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        let request = UNNotificationRequest(
            identifier: identifier ?? UUID().uuidString,
            content: content,
            trigger: trigger
        )
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("로컬 알림 스케줄링 실패: \(error)")
            }
        }
    }
    
    // MARK: - TimeCapsule Notifications
    
    func sendTagNotification(
        timeCapsuleId: UUID,
        taggedUsers: [String],
        senderId: String
    ) async {
        guard let modelContext = modelContext else { return }
        
        for userId in taggedUsers {
            let notification = TimeEggNotification(
                type: .timeCapsuleTagged,
                title: "새로운 타임캡슐 태그",
                message: "당신이 태그된 새로운 타임캡슐이 있습니다.",
                timeCapsuleId: timeCapsuleId,
                senderId: senderId,
                receiverId: userId
            )
            
            modelContext.insert(notification)
            
            // 로컬 알림도 발송
            scheduleLocalNotification(
                title: notification.title,
                body: notification.message,
                identifier: "tag_\(timeCapsuleId)_\(userId)"
            )
        }
        
        do {
            try modelContext.save()
        } catch {
            print("태그 알림 저장 실패: \(error)")
        }
    }
    
    func sendUnlockNotification(
        timeCapsuleId: UUID,
        receiverId: String
    ) async {
        guard let modelContext = modelContext else { return }
        
        let notification = TimeEggNotification(
            type: .timeCapsuleUnlocked,
            title: "타임캡슐 잠금 해제",
            message: "누군가 당신의 타임캡슐을 잠금 해제했습니다.",
            timeCapsuleId: timeCapsuleId,
            senderId: "system",
            receiverId: receiverId
        )
        
        modelContext.insert(notification)
        
        // 로컬 알림도 발송
        scheduleLocalNotification(
            title: notification.title,
            body: notification.message,
            identifier: "unlock_\(timeCapsuleId)_\(receiverId)"
        )
        
        do {
            try modelContext.save()
        } catch {
            print("잠금 해제 알림 저장 실패: \(error)")
        }
    }
    
    func sendPublicTimeCapsuleNotification(
        timeCapsuleId: UUID,
        creatorId: String,
        nearbyUsers: [String]
    ) async {
        guard let modelContext = modelContext else { return }
        
        for userId in nearbyUsers {
            guard userId != creatorId else { continue }
            
            let notification = TimeEggNotification(
                type: .newPublicTimeCapsule,
                title: "새로운 공개 타임캡슐",
                message: "근처에 새로운 공개 타임캡슐이 생성되었습니다.",
                timeCapsuleId: timeCapsuleId,
                senderId: creatorId,
                receiverId: userId
            )
            
            modelContext.insert(notification)
            
            // 로컬 알림도 발송
            scheduleLocalNotification(
                title: notification.title,
                body: notification.message,
                identifier: "public_\(timeCapsuleId)_\(userId)"
            )
        }
        
        do {
            try modelContext.save()
        } catch {
            print("공개 타임캡슐 알림 저장 실패: \(error)")
        }
    }
    
    // MARK: - Notification Management
    
    func markAsRead(_ notification: TimeEggNotification) {
        notification.isRead = true
        try? modelContext?.save()
    }
    
    func deleteNotification(_ notification: TimeEggNotification) {
        modelContext?.delete(notification)
        try? modelContext?.save()
    }
    
    func getUnreadCount() async -> Int {
        guard let modelContext = modelContext else { return 0 }
        
        do {
            let descriptor = FetchDescriptor<TimeEggNotification>(
                predicate: #Predicate { !$0.isRead }
            )
            let unreadNotifications = try modelContext.fetch(descriptor)
            return unreadNotifications.count
        } catch {
            print("읽지 않은 알림 개수 조회 실패: \(error)")
            return 0
        }
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension NotificationService: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // 앱이 포그라운드에 있을 때도 알림을 표시
        completionHandler([.alert, .sound, .badge])
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        // 알림 탭 처리
        let identifier = response.notification.request.identifier
        
        if identifier.hasPrefix("tag_") {
            // 태그 알림 처리
            handleTagNotification(identifier: identifier)
        } else if identifier.hasPrefix("unlock_") {
            // 잠금 해제 알림 처리
            handleUnlockNotification(identifier: identifier)
        } else if identifier.hasPrefix("public_") {
            // 공개 타임캡슐 알림 처리
            handlePublicTimeCapsuleNotification(identifier: identifier)
        }
        
        completionHandler()
    }
    
    private func handleTagNotification(identifier: String) {
        // 태그 알림 처리 로직
        print("태그 알림 처리: \(identifier)")
    }
    
    private func handleUnlockNotification(identifier: String) {
        // 잠금 해제 알림 처리 로직
        print("잠금 해제 알림 처리: \(identifier)")
    }
    
    private func handlePublicTimeCapsuleNotification(identifier: String) {
        // 공개 타임캡슐 알림 처리 로직
        print("공개 타임캡슐 알림 처리: \(identifier)")
    }
}
