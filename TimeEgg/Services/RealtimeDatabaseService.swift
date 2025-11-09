//
//  RealtimeDatabaseService.swift
//  TimeEgg
//
//  Created by donghyeon choi on 10/28/25.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth
import Combine
import UIKit
import CoreLocation

// Note: TimeCapsule.swift의 모델을 사용합니다. (내장 DB 사용 안 함)

class RealtimeDatabaseService: ObservableObject {
    private let database = Database.database().reference()
    private let mainPath = "timeCapsules"
    private let additionalPath = "timeCapsuleAdditional"
    private var locationService: LocationServiceProtocol?
    
    init(locationService: LocationServiceProtocol? = nil) {
        self.locationService = locationService
    }
    
    // MARK: - Firebase 연결 테스트
    func testConnection(completion: @escaping (Bool, String) -> Void) {
        database.child("_test").setValue(["connection": "test"]) { error, _ in
            if let error = error {
                completion(false, "Firebase 연결 실패: \(error.localizedDescription)")
            } else {
                // 테스트 데이터 삭제
                self.database.child("_test").removeValue()
                completion(true, "Firebase 연결 성공")
            }
        }
    }
    
    // MARK: - 이메일로 사용자 ID 찾기
    func findUserIdsByEmails(_ emails: [String], completion: @escaping ([String]) -> Void) {
        guard !emails.isEmpty else {
            completion([])
            return
        }
        
        // Firebase Realtime Database에 users 컬렉션이 있다고 가정
        // 없으면 이메일을 직접 사용 (나중에 이메일로 매칭)
        database.child("users").observeSingleEvent(of: .value) { snapshot in
            guard let usersData = snapshot.value as? [String: [String: Any]] else {
                // users 컬렉션이 없으면 빈 배열 반환 (이메일 직접 사용)
                completion([])
                return
            }
            
            var userIds: [String] = []
            for (userId, userData) in usersData {
                if let userEmail = userData["email"] as? String,
                   emails.contains(userEmail) {
                    userIds.append(userId)
                }
            }
            completion(userIds)
        }
    }
    
    // MARK: - 타임캡슐 생성 (메인 데이터)
    func createTimeCapsule(
        title: String,
        memo: String,
        privacy: String,
        photoUrls: [String]? = nil,
        sharedUserIds: [String]? = nil,
        documentId: String? = nil,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "RealtimeDatabaseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "사용자가 로그인되지 않았습니다."])))
            return
        }
        
        let documentId = documentId ?? UUID().uuidString
        let now = Date().timeIntervalSince1970
        
        var mainData: [String: Any] = [
            "id": documentId,
            "title": title,
            "memo": memo,
            "privacy": privacy,
            "photoUrls": photoUrls ?? [],
            "creatorId": userId,
            "createdAt": now,
            "updatedAt": now
        ]
        
        // sharedUserIds가 있으면 추가
        if let sharedUserIds = sharedUserIds {
            mainData["sharedUserIds"] = sharedUserIds
        }
        
        print("📤 메인 데이터 저장 시도: \(mainData)")
        database.child(mainPath).child(documentId).setValue(mainData) { error, _ in
            if let error = error {
                print("❌ 메인 데이터 저장 실패: \(error.localizedDescription)")
                print("❌ 에러 상세: \(error)")
                if let nsError = error as NSError? {
                    print("❌ 에러 도메인: \(nsError.domain), 코드: \(nsError.code)")
                    print("❌ 에러 정보: \(nsError.userInfo)")
                }
                completion(.failure(error))
            } else {
                print("✅ 메인 데이터 저장 성공: \(documentId)")
                completion(.success(documentId))
            }
        }
    }
    
    // MARK: - 추가 조건 데이터 저장
    func saveAdditionalConditions(
        timeCapsuleId: String,
        weather: String?,
        location: TimeCapsuleLocationData?,
        timeCondition: TimeCapsuleTimeCondition?,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        let now = Date().timeIntervalSince1970
        
        var additionalData: [String: Any] = [
            "timeCapsuleId": timeCapsuleId,
            "createdAt": now,
            "updatedAt": now
        ]
        
        if let weather = weather {
            additionalData["weather"] = weather
        }
        
        if let location = location {
            additionalData["location"] = [
                "latitude": location.latitude,
                "longitude": location.longitude,
                "address": location.address ?? "",
                "radius": location.radius
            ]
        }
        
        if let timeCondition = timeCondition {
            var conditionData: [String: Any] = [:]
            if let targetDate = timeCondition.targetDate {
                conditionData["targetDate"] = targetDate.timeIntervalSince1970
            }
            if let timeRange = timeCondition.timeRange {
                conditionData["timeRange"] = [
                    "startTime": timeRange.startTime,
                    "endTime": timeRange.endTime
                ]
            }
            // conditionData가 비어있지 않을 때만 추가
            if !conditionData.isEmpty {
                additionalData["timeCondition"] = conditionData
            }
        }
        
        print("📤 추가 조건 데이터 저장 시도: \(additionalData)")
        database.child(additionalPath).child(timeCapsuleId).setValue(additionalData) { error, _ in
            if let error = error {
                print("❌ 추가 조건 데이터 저장 실패: \(error.localizedDescription)")
                print("❌ 에러 상세: \(error)")
                if let nsError = error as NSError? {
                    print("❌ 에러 도메인: \(nsError.domain), 코드: \(nsError.code)")
                    print("❌ 에러 정보: \(nsError.userInfo)")
                }
                completion(.failure(error))
            } else {
                print("✅ 추가 조건 데이터 저장 성공: \(timeCapsuleId)")
                completion(.success(()))
            }
        }
    }
    
    // MARK: - 타임캡슐 생성 (메인 + 추가 조건)
    func createTimeCapsuleWithConditions(
        title: String,
        memo: String,
        privacy: String,
        photoUrls: [String]? = nil,
        sharedUserIds: [String]? = nil,
        weather: String?,
        location: TimeCapsuleLocationData?,
        timeCondition: TimeCapsuleTimeCondition?,
        documentId: String? = nil,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        // 위치가 없으면 현재 위치 가져오기
        let finalLocation: TimeCapsuleLocationData? = location ?? {
            // 동기적으로 현재 위치를 가져올 수 없으므로, 비동기로 처리
            // 일단 nil로 전달하고, 내부에서 처리
            return nil
        }()
        
        // 위치가 없고 locationService가 있으면 현재 위치 가져오기
        if location == nil, let locationService = locationService {
            Task {
                if let currentLocation = await locationService.getCurrentLocation() {
                    // 주소 가져오기
                    let address = await locationService.getAddress(from: currentLocation)
                    
                    let currentLocationData = TimeCapsuleLocationData(
                        latitude: currentLocation.coordinate.latitude,
                        longitude: currentLocation.coordinate.longitude,
                        address: address,
                        radius: 50.0 // 기본 반경 50미터
                    )
                    
                    // 메인 데이터 저장
                    self.createTimeCapsule(title: title, memo: memo, privacy: privacy, photoUrls: photoUrls, sharedUserIds: sharedUserIds, documentId: documentId) { [weak self] result in
                        switch result {
                            case .success(let timeCapsuleId):
                                // 메인 데이터 저장 성공 시 추가 조건 저장 (현재 위치 포함)
                                self?.saveAdditionalConditions(
                                    timeCapsuleId: timeCapsuleId,
                                    weather: weather,
                                    location: currentLocationData,
                                    timeCondition: timeCondition
                                ) { additionalResult in
                                    switch additionalResult {
                                        case .success:
                                            completion(.success(timeCapsuleId))
                                        case .failure(let error):
                                            completion(.failure(error))
                                    }
                                }
                            case .failure(let error):
                                completion(.failure(error))
                        }
                    }
                } else {
                    // 위치를 가져올 수 없으면 위치 없이 저장
                    self.createTimeCapsuleWithConditionsSync(
                        title: title,
                        memo: memo,
                        privacy: privacy,
                        photoUrls: photoUrls,
                        weather: weather,
                        location: nil,
                        timeCondition: timeCondition,
                        documentId: documentId,
                        completion: completion
                    )
                }
            }
        } else {
            // 위치가 이미 있거나 locationService가 없으면 기존 로직 사용
            createTimeCapsuleWithConditionsSync(
                title: title,
                memo: memo,
                privacy: privacy,
                photoUrls: photoUrls,
                sharedUserIds: sharedUserIds,
                weather: weather,
                location: location,
                timeCondition: timeCondition,
                documentId: documentId,
                completion: completion
            )
        }
    }
    
    // MARK: - 타임캡슐 생성 (동기 버전 - 내부 사용)
    private func createTimeCapsuleWithConditionsSync(
        title: String,
        memo: String,
        privacy: String,
        photoUrls: [String]? = nil,
        sharedUserIds: [String]? = nil,
        weather: String?,
        location: TimeCapsuleLocationData?,
        timeCondition: TimeCapsuleTimeCondition?,
        documentId: String? = nil,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        // 먼저 메인 데이터 저장
        createTimeCapsule(title: title, memo: memo, privacy: privacy, photoUrls: photoUrls, sharedUserIds: sharedUserIds, documentId: documentId) { [weak self] result in
            switch result {
                case .success(let timeCapsuleId):
                    // 메인 데이터 저장 성공 시 추가 조건 저장
                    self?.saveAdditionalConditions(
                        timeCapsuleId: timeCapsuleId,
                        weather: weather,
                        location: location,
                        timeCondition: timeCondition
                    ) { additionalResult in
                        switch additionalResult {
                            case .success:
                                completion(.success(timeCapsuleId))
                            case .failure(let error):
                                completion(.failure(error))
                        }
                    }
                case .failure(let error):
                    completion(.failure(error))
            }
        }
    }
    
    // MARK: - 사진과 함께 타임캡슐 생성 (통합 메서드)
    func createTimeCapsuleWithPhotos(
        images: [UIImage],
        title: String,
        memo: String,
        privacy: String,
        sharedUserIds: [String]? = nil,
        weather: String?,
        location: TimeCapsuleLocationData?,
        timeCondition: TimeCapsuleTimeCondition?,
        storageService: FirebaseStorageService,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        // 먼저 documentId 생성 (사진 업로드와 타임캡슐 생성에 동일한 ID 사용)
        let documentId = UUID().uuidString
        
        // 위치가 없으면 현재 위치 가져오기
        if location == nil, let locationService = locationService {
            Task {
                if let currentLocation = await locationService.getCurrentLocation() {
                    // 주소 가져오기
                    let address = await locationService.getAddress(from: currentLocation)
                    
                    let currentLocationData = TimeCapsuleLocationData(
                        latitude: currentLocation.coordinate.latitude,
                        longitude: currentLocation.coordinate.longitude,
                        address: address,
                        radius: 50.0 // 기본 반경 50미터
                    )
                    
                    // 사진 업로드
                    storageService.uploadImages(images: images, timeCapsuleId: documentId) { [weak self] uploadResult in
                        switch uploadResult {
                            case .success(let photoUrls):
                                // 사진 업로드 성공 시 타임캡슐 생성 (현재 위치 포함)
                                self?.createTimeCapsuleWithConditionsSync(
                                    title: title,
                                    memo: memo,
                                    privacy: privacy,
                                    photoUrls: photoUrls.isEmpty ? nil : photoUrls,
                                    sharedUserIds: sharedUserIds,
                                    weather: weather,
                                    location: currentLocationData,
                                    timeCondition: timeCondition,
                                    documentId: documentId
                                ) { createResult in
                                    switch createResult {
                                        case .success(let timeCapsuleId):
                                            completion(.success(timeCapsuleId))
                                        case .failure(let error):
                                            // 타임캡슐 생성 실패 시 업로드한 사진 삭제
                                            storageService.deleteTimeCapsuleImages(timeCapsuleId: documentId) { _ in }
                                            completion(.failure(error))
                                    }
                                }
                            case .failure(let error):
                                completion(.failure(error))
                        }
                    }
                } else {
                    // 위치를 가져올 수 없으면 위치 없이 저장
                    storageService.uploadImages(images: images, timeCapsuleId: documentId) { [weak self] uploadResult in
                        switch uploadResult {
                            case .success(let photoUrls):
                                self?.createTimeCapsuleWithConditionsSync(
                                    title: title,
                                    memo: memo,
                                    privacy: privacy,
                                    photoUrls: photoUrls.isEmpty ? nil : photoUrls,
                                    sharedUserIds: sharedUserIds,
                                    weather: weather,
                                    location: nil,
                                    timeCondition: timeCondition,
                                    documentId: documentId
                                ) { createResult in
                                    switch createResult {
                                        case .success(let timeCapsuleId):
                                            completion(.success(timeCapsuleId))
                                        case .failure(let error):
                                            storageService.deleteTimeCapsuleImages(timeCapsuleId: documentId) { _ in }
                                            completion(.failure(error))
                                    }
                                }
                            case .failure(let error):
                                completion(.failure(error))
                        }
                    }
                }
            }
        } else {
            // 위치가 이미 있거나 locationService가 없으면 기존 로직 사용
            storageService.uploadImages(images: images, timeCapsuleId: documentId) { [weak self] uploadResult in
                switch uploadResult {
                    case .success(let photoUrls):
                        // 사진 업로드 성공 시 타임캡슐 생성 (동일한 documentId 사용)
                        self?.createTimeCapsuleWithConditions(
                            title: title,
                            memo: memo,
                            privacy: privacy,
                            photoUrls: photoUrls.isEmpty ? nil : photoUrls,
                            sharedUserIds: sharedUserIds,
                            weather: weather,
                            location: location,
                            timeCondition: timeCondition,
                            documentId: documentId
                        ) { createResult in
                            switch createResult {
                                case .success(let timeCapsuleId):
                                    completion(.success(timeCapsuleId))
                                case .failure(let error):
                                    // 타임캡슐 생성 실패 시 업로드한 사진 삭제
                                    storageService.deleteTimeCapsuleImages(timeCapsuleId: documentId) { _ in }
                                    completion(.failure(error))
                            }
                        }
                    case .failure(let error):
                        completion(.failure(error))
                }
            }
        }
    }
    
    // MARK: - 타임캡슐에 사진 추가
    func addPhotosToTimeCapsule(
        timeCapsuleId: String,
        images: [UIImage],
        storageService: FirebaseStorageService,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        storageService.uploadImages(images: images, timeCapsuleId: timeCapsuleId) { [weak self] uploadResult in
            switch uploadResult {
                case .success(let newPhotoUrls):
                    // 기존 사진 URL 가져오기
                    self?.getTimeCapsule(id: timeCapsuleId) { getResult in
                        switch getResult {
                            case .success(let timeCapsule):
                                let existingUrls = timeCapsule.photoUrls ?? []
                                let allUrls = existingUrls + newPhotoUrls
                                
                                // Realtime Database 업데이트
                                self?.database.child(self?.mainPath ?? "timeCapsules")
                                    .child(timeCapsuleId)
                                    .updateChildValues([
                                        "photoUrls": allUrls,
                                        "updatedAt": Date().timeIntervalSince1970
                                    ]) { error, _ in
                                        if let error = error {
                                            completion(.failure(error))
                                        } else {
                                            completion(.success(()))
                                        }
                                    }
                            case .failure(let error):
                                completion(.failure(error))
                        }
                    }
                case .failure(let error):
                    completion(.failure(error))
            }
        }
    }
    
    // MARK: - 타임캡슐 조회 (메인 데이터)
    func getTimeCapsule(id: String, completion: @escaping (Result<TimeCapsule, Error>) -> Void) {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "RealtimeDatabaseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "사용자가 로그인되지 않았습니다."])))
            return
        }
        
        database.child(mainPath).child(id).observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? [String: Any] else {
                completion(.failure(NSError(domain: "RealtimeDatabaseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "타임캡슐을 찾을 수 없습니다."])))
                return
            }
            
            // Dictionary에서 TimeCapsule 생성
            guard let id = value["id"] as? String,
                  let title = value["title"] as? String,
                  let memo = value["memo"] as? String,
                  let privacy = value["privacy"] as? String,
                  let creatorId = value["creatorId"] as? String,
                  let createdAt = value["createdAt"] as? TimeInterval,
                  let updatedAt = value["updatedAt"] as? TimeInterval else {
                completion(.failure(NSError(domain: "RealtimeDatabaseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "데이터 형식이 올바르지 않습니다."])))
                return
            }
            
            // 소유자 확인: 현재 사용자가 생성자이거나 공유된 사용자인지 확인
            let sharedUserIds = value["sharedUserIds"] as? [String] ?? []
            let hasAccess = creatorId == currentUserId || sharedUserIds.contains(currentUserId)
            
            guard hasAccess else {
                completion(.failure(NSError(domain: "RealtimeDatabaseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "이 타임캡슐에 접근할 권한이 없습니다."])))
                return
            }
            
            let photoUrls = value["photoUrls"] as? [String]
            let timeCapsule = TimeCapsule(
                id: id,
                title: title,
                memo: memo,
                privacy: privacy,
                photoUrls: photoUrls,
                creatorId: creatorId,
                sharedUserIds: sharedUserIds,
                createdAt: Date(timeIntervalSince1970: createdAt),
                updatedAt: Date(timeIntervalSince1970: updatedAt)
            )
            completion(.success(timeCapsule))
        }
    }
    
    // MARK: - 추가 조건 조회
    func getAdditionalConditions(timeCapsuleId: String, completion: @escaping (Result<TimeCapsuleAdditionalData, Error>) -> Void) {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "RealtimeDatabaseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "사용자가 로그인되지 않았습니다."])))
            return
        }
        
        // 먼저 타임캡슐의 소유자 확인
        database.child(mainPath).child(timeCapsuleId).observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let capsuleValue = snapshot.value as? [String: Any],
                  let creatorId = capsuleValue["creatorId"] as? String else {
                completion(.failure(NSError(domain: "RealtimeDatabaseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "타임캡슐을 찾을 수 없습니다."])))
                return
            }
            
            // 소유자 확인: 현재 사용자가 생성자이거나 공유된 사용자인지 확인
            let sharedUserIds = capsuleValue["sharedUserIds"] as? [String] ?? []
            let hasAccess = creatorId == currentUserId || sharedUserIds.contains(currentUserId)
            
            guard hasAccess else {
                completion(.failure(NSError(domain: "RealtimeDatabaseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "이 타임캡슐에 접근할 권한이 없습니다."])))
                return
            }
            
            // 소유자 확인 후 추가 조건 조회
            self?.database.child(self?.additionalPath ?? "timeCapsuleAdditional").child(timeCapsuleId).observeSingleEvent(of: .value) { snapshot in
                guard let value = snapshot.value as? [String: Any] else {
                    completion(.failure(NSError(domain: "RealtimeDatabaseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "추가 조건을 찾을 수 없습니다."])))
                    return
                }
                
                guard let timeCapsuleId = value["timeCapsuleId"] as? String,
                      let createdAt = value["createdAt"] as? TimeInterval,
                      let updatedAt = value["updatedAt"] as? TimeInterval else {
                    completion(.failure(NSError(domain: "RealtimeDatabaseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "데이터 형식이 올바르지 않습니다."])))
                    return
                }
                
                let weather = value["weather"] as? String
                
                // Location 변환
                var location: TimeCapsuleLocationData? = nil
                if let locationDict = value["location"] as? [String: Any],
                   let latitude = locationDict["latitude"] as? Double,
                   let longitude = locationDict["longitude"] as? Double,
                   let radius = locationDict["radius"] as? Double {
                    location = TimeCapsuleLocationData(
                        latitude: latitude,
                        longitude: longitude,
                        address: locationDict["address"] as? String,
                        radius: radius
                    )
                }
                
                // TimeCondition 변환
                var timeCondition: TimeCapsuleTimeCondition? = nil
                if let timeConditionDict = value["timeCondition"] as? [String: Any] {
                    let targetDate = (timeConditionDict["targetDate"] as? TimeInterval).map { Date(timeIntervalSince1970: $0) }
                    var timeRange: TimeCapsuleTimeRange? = nil
                    if let timeRangeDict = timeConditionDict["timeRange"] as? [String: Any],
                       let startTime = timeRangeDict["startTime"] as? String,
                       let endTime = timeRangeDict["endTime"] as? String {
                        timeRange = TimeCapsuleTimeRange(startTime: startTime, endTime: endTime)
                    }
                    timeCondition = TimeCapsuleTimeCondition(targetDate: targetDate, timeRange: timeRange)
                }
                
                let additionalData = TimeCapsuleAdditionalData(
                    timeCapsuleId: timeCapsuleId,
                    weather: weather,
                    location: location,
                    timeCondition: timeCondition,
                    createdAt: Date(timeIntervalSince1970: createdAt),
                    updatedAt: Date(timeIntervalSince1970: updatedAt)
                )
                completion(.success(additionalData))
            }
        }
    }
    
    // MARK: - 사용자의 타임캡슐 목록 조회
    func getUserTimeCapsules(completion: @escaping (Result<[TimeCapsule], Error>) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "RealtimeDatabaseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "사용자가 로그인되지 않았습니다."])))
            return
        }
        
        // 생성한 캡슐과 공유받은 캡슐 모두 가져오기
        database.child(mainPath).observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? [String: [String: Any]] else {
                completion(.success([]))
                return
            }
            
            var timeCapsules: [TimeCapsule] = []
            for (_, capsuleData) in value {
                guard let id = capsuleData["id"] as? String,
                      let title = capsuleData["title"] as? String,
                      let memo = capsuleData["memo"] as? String,
                      let privacy = capsuleData["privacy"] as? String,
                      let creatorId = capsuleData["creatorId"] as? String,
                      let createdAt = capsuleData["createdAt"] as? TimeInterval,
                      let updatedAt = capsuleData["updatedAt"] as? TimeInterval else {
                    print("Error: Invalid timeCapsule data format")
                    continue
                }
                
                // 접근 권한 확인: 생성자이거나 공유된 사용자인지 확인
                let sharedUserIds = capsuleData["sharedUserIds"] as? [String] ?? []
                let hasAccess = creatorId == userId || sharedUserIds.contains(userId)
                
                guard hasAccess else {
                    continue
                }
                
                let photoUrls = capsuleData["photoUrls"] as? [String]
                let timeCapsule = TimeCapsule(
                    id: id,
                    title: title,
                    memo: memo,
                    privacy: privacy,
                    photoUrls: photoUrls,
                    creatorId: creatorId,
                    sharedUserIds: sharedUserIds,
                    createdAt: Date(timeIntervalSince1970: createdAt),
                    updatedAt: Date(timeIntervalSince1970: updatedAt)
                )
                timeCapsules.append(timeCapsule)
            }
            
            // createdAt 기준으로 정렬 (내림차순)
            timeCapsules.sort { $0.createdAt > $1.createdAt }
            
            completion(.success(timeCapsules))
        }
    }
    
    // MARK: - 타임캡슐 업데이트
    func updateTimeCapsule(
        id: String,
        title: String?,
        memo: String?,
        privacy: String?,
        photoUrls: [String]? = nil,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        var updateData: [String: Any] = ["updatedAt": Date().timeIntervalSince1970]
        
        if let title = title {
            updateData["title"] = title
        }
        if let memo = memo {
            updateData["memo"] = memo
        }
        if let privacy = privacy {
            updateData["privacy"] = privacy
        }
        if let photoUrls = photoUrls {
            updateData["photoUrls"] = photoUrls
        }
        
        database.child(mainPath).child(id).updateChildValues(updateData) { error, _ in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    // MARK: - 타임캡슐 삭제
    func deleteTimeCapsule(
        id: String,
        storageService: FirebaseStorageService? = nil,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        // 먼저 사진 삭제 (있는 경우)
        if let storageService = storageService {
            storageService.deleteTimeCapsuleImages(timeCapsuleId: id) { _ in }
        }
        
        // 메인 데이터 삭제
        database.child(mainPath).child(id).removeValue { [weak self] error, _ in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            // 추가 조건 데이터도 삭제
            self?.database.child(self?.additionalPath ?? "timeCapsuleAdditional").child(id).removeValue { error, _ in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        }
    }
    
    // MARK: - 타임캡슐에서 사진 삭제
    func removePhotosFromTimeCapsule(
        timeCapsuleId: String,
        photoUrls: [String],
        storageService: FirebaseStorageService,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        // Storage에서 사진 삭제
        storageService.deleteImages(imageUrls: photoUrls) { [weak self] deleteResult in
            if case .failure(let error) = deleteResult {
                completion(.failure(error))
                return
            }
            
            // 기존 사진 URL 가져오기
            self?.getTimeCapsule(id: timeCapsuleId) { getResult in
                switch getResult {
                case .success(let timeCapsule):
                    let existingUrls = timeCapsule.photoUrls ?? []
                    let remainingUrls = existingUrls.filter { !photoUrls.contains($0) }
                    
                    // Realtime Database 업데이트
                    self?.database.child(self?.mainPath ?? "timeCapsules")
                        .child(timeCapsuleId)
                        .updateChildValues([
                            "photoUrls": remainingUrls.isEmpty ? [] : remainingUrls,
                            "updatedAt": Date().timeIntervalSince1970
                        ]) { error, _ in
                            if let error = error {
                                completion(.failure(error))
                            } else {
                                completion(.success(()))
                            }
                        }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    // MARK: - 실시간 타임캡슐 리스너
    func observeTimeCapsules(userId: String, completion: @escaping ([TimeCapsule]) -> Void) {
        database.child(mainPath).queryOrdered(byChild: "creatorId").queryEqual(toValue: userId).observe(.value) { snapshot in
            guard let value = snapshot.value as? [String: [String: Any]] else {
                completion([])
                return
            }
            
            var timeCapsules: [TimeCapsule] = []
            for (_, capsuleData) in value {
                guard let id = capsuleData["id"] as? String,
                      let title = capsuleData["title"] as? String,
                      let memo = capsuleData["memo"] as? String,
                      let privacy = capsuleData["privacy"] as? String,
                      let creatorId = capsuleData["creatorId"] as? String,
                      let createdAt = capsuleData["createdAt"] as? TimeInterval,
                      let updatedAt = capsuleData["updatedAt"] as? TimeInterval else {
                    print("Error: Invalid timeCapsule data format")
                    continue
                }
                
                let photoUrls = capsuleData["photoUrls"] as? [String]
                let timeCapsule = TimeCapsule(
                    id: id,
                    title: title,
                    memo: memo,
                    privacy: privacy,
                    photoUrls: photoUrls,
                    creatorId: creatorId,
                    createdAt: Date(timeIntervalSince1970: createdAt),
                    updatedAt: Date(timeIntervalSince1970: updatedAt)
                )
                timeCapsules.append(timeCapsule)
            }
            
            // createdAt 기준으로 정렬 (내림차순)
            timeCapsules.sort { $0.createdAt > $1.createdAt }
            
            completion(timeCapsules)
        }
    }
    
    // MARK: - 리스너 제거
    func removeObservers() {
        database.child(mainPath).removeAllObservers()
        database.child(additionalPath).removeAllObservers()
    }
}
