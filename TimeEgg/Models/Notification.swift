//
//  Notification.swift
//  TimeEgg
//
//  Created by donghyeon choi on 9/22/25.
//

import Foundation
import SwiftData

@Model
final class TimeEggNotification {
    var id: UUID
    var type: NotificationType
    var title: String
    var message: String
    var timeCapsuleId: UUID?
    var senderId: String
    var receiverId: String
    var isRead: Bool
    var createdAt: Date
    
    init(
        type: NotificationType,
        title: String,
        message: String,
        timeCapsuleId: UUID? = nil,
        senderId: String,
        receiverId: String
    ) {
        self.id = UUID()
        self.type = type
        self.title = title
        self.message = message
        self.timeCapsuleId = timeCapsuleId
        self.senderId = senderId
        self.receiverId = receiverId
        self.isRead = false
        self.createdAt = Date()
    }
}

enum NotificationType: String, CaseIterable, Codable {
    case timeCapsuleTagged = "timeCapsuleTagged"
    case timeCapsuleUnlocked = "timeCapsuleUnlocked"
    case newPublicTimeCapsule = "newPublicTimeCapsule"
    case friendRequest = "friendRequest"
    case system = "system"
    
    var displayName: String {
        switch self {
        case .timeCapsuleTagged:
            return "타임캡슐 태그"
        case .timeCapsuleUnlocked:
            return "타임캡슐 잠금해제"
        case .newPublicTimeCapsule:
            return "새 공개 타임캡슐"
        case .friendRequest:
            return "친구 요청"
        case .system:
            return "시스템 알림"
        }
    }
}
