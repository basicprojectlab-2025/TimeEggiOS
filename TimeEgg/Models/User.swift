//
//  User.swift
//  TimeEgg
//
//  Created by donghyeon choi on 9/22/25.
//

import Foundation
import SwiftData

@Model
final class User {
    var id: String
    var username: String
    var email: String
    var profileImage: Data?
    var deviceToken: String? // 푸시 알림용 디바이스 토큰
    var createdAt: Date
    var lastActiveAt: Date
    var preferences: UserPreferences
    
    init(
        id: String,
        username: String,
        email: String,
        profileImage: Data? = nil,
        deviceToken: String? = nil
    ) {
        self.id = id
        self.username = username
        self.email = email
        self.profileImage = profileImage
        self.deviceToken = deviceToken
        self.createdAt = Date()
        self.lastActiveAt = Date()
        self.preferences = UserPreferences()
    }
}

@Model
final class UserPreferences {
    var notificationEnabled: Bool
    var locationSharingEnabled: Bool
    var publicTimeCapsuleVisible: Bool
    var language: String
    
    init(
        notificationEnabled: Bool = true,
        locationSharingEnabled: Bool = true,
        publicTimeCapsuleVisible: Bool = true,
        language: String = "ko"
    ) {
        self.notificationEnabled = notificationEnabled
        self.locationSharingEnabled = locationSharingEnabled
        self.publicTimeCapsuleVisible = publicTimeCapsuleVisible
        self.language = language
    }
}
