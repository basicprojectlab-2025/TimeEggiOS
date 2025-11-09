//
//  TimeCapsule.swift
//  TimeEgg
//
//  Created by donghyeon choi on 9/22/25.
//

import Foundation
import CoreLocation
import UIKit

// MARK: - RealtimeDatabaseService 구조에 맞춘 TimeCapsule 모델 (내장 DB 사용 안 함)

// MARK: - 메인 인스턴스 (제목, 메모, 공개범위)
final class TimeCapsule {
    var id: String
    var title: String
    var memo: String
    var privacy: String // "전체공개", "친구공개", "비공개"
    var photoUrls: [String]? // 사진 URL 배열
    var creatorId: String
    var sharedUserIds: [String]? // 공유할 사용자 ID 목록 (nil이면 비공개, 빈 배열이면 생성자만)
    var createdAt: Date
    var updatedAt: Date
    
    // 추가 조건 참조 (옵셔널)
    var additionalData: TimeCapsuleAdditionalData?
    
    init(
        id: String,
        title: String,
        memo: String,
        privacy: String,
        photoUrls: [String]? = nil,
        creatorId: String,
        sharedUserIds: [String]? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.memo = memo
        self.privacy = privacy
        self.photoUrls = photoUrls
        self.creatorId = creatorId
        self.sharedUserIds = sharedUserIds
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - 추가 조건 인스턴스 (날씨, 위치, 시간)
final class TimeCapsuleAdditionalData {
    var timeCapsuleId: String
    var weather: String? // "맑음", "눈", "비", "흐림", "번개"
    var location: TimeCapsuleLocationData?
    var timeCondition: TimeCapsuleTimeCondition?
    var createdAt: Date
    var updatedAt: Date
    
    init(
        timeCapsuleId: String,
        weather: String? = nil,
        location: TimeCapsuleLocationData? = nil,
        timeCondition: TimeCapsuleTimeCondition? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.timeCapsuleId = timeCapsuleId
        self.weather = weather
        self.location = location
        self.timeCondition = timeCondition
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - 위치 조건
final class TimeCapsuleLocationData {
    var latitude: Double
    var longitude: Double
    var address: String?
    var radius: Double // 반경 (미터)
    
    init(
        latitude: Double,
        longitude: Double,
        address: String? = nil,
        radius: Double = 50.0
    ) {
        self.latitude = latitude
        self.longitude = longitude
        self.address = address
        self.radius = radius
    }
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

// MARK: - 시간 조건
final class TimeCapsuleTimeCondition {
    var targetDate: Date?
    var timeRange: TimeCapsuleTimeRange?
    
    init(
        targetDate: Date? = nil,
        timeRange: TimeCapsuleTimeRange? = nil
    ) {
        self.targetDate = targetDate
        self.timeRange = timeRange
    }
}

// MARK: - 시간 범위
final class TimeCapsuleTimeRange {
    var startTime: String // HH:mm 형식
    var endTime: String // HH:mm 형식
    
    init(
        startTime: String,
        endTime: String
    ) {
        self.startTime = startTime
        self.endTime = endTime
    }
}
