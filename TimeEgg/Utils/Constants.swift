//
//  Constants.swift
//  TimeEgg
//
//  Created by donghyeon choi on 9/22/25.
//

import Foundation
import CoreLocation
import MapKit
import UIKit

struct AppConstants {
    // MARK: - App Information
    static let appName = "TimeEgg"
    static let appVersion = Bundle.main.appVersion
    static let buildNumber = Bundle.main.buildNumber
    
    // MARK: - Location Constants
    static let defaultLocationRadius: Double = 50.0 // 미터
    static let maxLocationRadius: Double = 1000.0 // 미터
    static let nearbyRadius: Double = 1000.0 // 1km 반경 내 타임캡슐 검색
    
    // MARK: - TimeCapsule Constants
    static let maxPhotosPerTimeCapsule = 10
    static let maxContentLength = 1000
    static let maxTitleLength = 100
    static let maxTaggedUsers = 20
    
    // MARK: - Camera Constants
    static let photoCompressionQuality: CGFloat = 0.8
    static let thumbnailSize = CGSize(width: 150, height: 150)
    static let maxPhotoSize = CGSize(width: 2048, height: 2048)
    
    // MARK: - AR Constants
    static let arSessionTimeout: TimeInterval = 30.0
    static let maxARAnchors = 50
    
    // MARK: - Notification Constants
    static let notificationSoundName = "default"
    static let maxNotificationRetry = 3
    
    // MARK: - UI Constants
    static let cornerRadius: CGFloat = 12.0
    static let shadowRadius: CGFloat = 4.0
    static let animationDuration: Double = 0.3
    
    // MARK: - Default Values
    static let defaultCoordinate = CLLocationCoordinate2D(latitude: 37.5665, longitude: 126.9780) // 서울
    static let defaultMapSpan = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
}

struct APIEndpoints {
    // MARK: - Base URLs
    static let baseURL = "https://api.timeegg.app"
    static let imageBaseURL = "https://images.timeegg.app"
    
    // MARK: - User Endpoints
    static let userProfile = "/api/v1/user/profile"
    static let userUpdate = "/api/v1/user/update"
    static let userSearch = "/api/v1/user/search"
    
    // MARK: - TimeCapsule Endpoints
    static let timeCapsuleCreate = "/api/v1/timecapsule/create"
    static let timeCapsuleList = "/api/v1/timecapsule/list"
    static let timeCapsuleDetail = "/api/v1/timecapsule/detail"
    static let timeCapsuleUpdate = "/api/v1/timecapsule/update"
    static let timeCapsuleDelete = "/api/v1/timecapsule/delete"
    static let timeCapsuleNearby = "/api/v1/timecapsule/nearby"
    
    // MARK: - Notification Endpoints
    static let notificationList = "/api/v1/notification/list"
    static let notificationRead = "/api/v1/notification/read"
    static let notificationDelete = "/api/v1/notification/delete"
    
    // MARK: - Upload Endpoints
    static let imageUpload = "/api/v1/upload/image"
    static let arImageUpload = "/api/v1/upload/ar"
}

struct UserDefaultsKeys {
    static let isFirstLaunch = "isFirstLaunch"
    static let userID = "userID"
    static let username = "username"
    static let email = "email"
    static let deviceToken = "deviceToken"
    static let lastLocationLatitude = "lastLocationLatitude"
    static let lastLocationLongitude = "lastLocationLongitude"
    static let notificationEnabled = "notificationEnabled"
    static let locationSharingEnabled = "locationSharingEnabled"
    static let publicTimeCapsuleVisible = "publicTimeCapsuleVisible"
    static let language = "language"
}

struct NotificationNames {
    static let timeCapsuleCreated = "TimeCapsuleCreated"
    static let timeCapsuleUnlocked = "TimeCapsuleUnlocked"
    static let locationUpdated = "LocationUpdated"
    static let userLoggedIn = "UserLoggedIn"
    static let userLoggedOut = "UserLoggedOut"
    static let notificationReceived = "NotificationReceived"
}

struct ErrorMessages {
    static let networkError = "네트워크 연결을 확인해주세요."
    static let locationPermissionDenied = "위치 권한이 필요합니다."
    static let cameraPermissionDenied = "카메라 권한이 필요합니다."
    static let photoLibraryPermissionDenied = "사진 라이브러리 권한이 필요합니다."
    static let notificationPermissionDenied = "알림 권한이 필요합니다."
    static let arNotSupported = "AR 기능이 지원되지 않는 기기입니다."
    static let timeCapsuleNotFound = "타임캡슐을 찾을 수 없습니다."
    static let invalidLocation = "유효하지 않은 위치입니다."
    static let uploadFailed = "업로드에 실패했습니다."
    static let saveFailed = "저장에 실패했습니다."
}

struct SuccessMessages {
    static let timeCapsuleCreated = "타임캡슐이 성공적으로 생성되었습니다."
    static let timeCapsuleUnlocked = "타임캡슐이 잠금 해제되었습니다."
    static let photoSaved = "사진이 저장되었습니다."
    static let settingsSaved = "설정이 저장되었습니다."
    static let notificationSent = "알림이 전송되었습니다."
}

// MARK: - Import MapKit for coordinate constants
import MapKit
