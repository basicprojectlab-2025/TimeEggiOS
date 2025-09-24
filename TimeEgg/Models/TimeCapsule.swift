//
//  TimeCapsule.swift
//  TimeEgg
//
//  Created by donghyeon choi on 9/22/25.
//

import Foundation
import SwiftData
import CoreLocation
import UIKit

@Model
final class TimeCapsule {
    var id: UUID
    var title: String
    var content: String
    var photos: [Data] // 사진 데이터 배열
    var arPhotos: [Data]? // AR 사진 데이터 (선택사항)
    var stickers: [StickerData]? // 스티커 정보
    var location: LocationData
    var createdAt: Date
    var isPublic: Bool // 공개/비공개 설정
    var taggedUsers: [String] // 태그된 사용자 ID 배열
    var creatorId: String // 생성자 ID
    var isUnlocked: Bool // 방문하여 잠금 해제되었는지 여부
    
    init(
        title: String,
        content: String,
        photos: [Data] = [],
        arPhotos: [Data]? = nil,
        stickers: [StickerData]? = nil,
        location: LocationData,
        isPublic: Bool = false,
        taggedUsers: [String] = [],
        creatorId: String
    ) {
        self.id = UUID()
        self.title = title
        self.content = content
        self.photos = photos
        self.arPhotos = arPhotos
        self.stickers = stickers
        self.location = location
        self.createdAt = Date()
        self.isPublic = isPublic
        self.taggedUsers = taggedUsers
        self.creatorId = creatorId
        self.isUnlocked = false
    }
}

@Model
final class LocationData {
    var latitude: Double
    var longitude: Double
    var address: String?
    var radius: Double // 타임캡슐 접근 가능 반경 (미터)
    
    init(latitude: Double, longitude: Double, address: String? = nil, radius: Double = 50.0) {
        self.latitude = latitude
        self.longitude = longitude
        self.address = address
        self.radius = radius
    }
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

struct StickerData: Codable {
    let id: String
    let position: CGPoint
    let scale: CGFloat
    let rotation: Double
    let imageName: String
}
