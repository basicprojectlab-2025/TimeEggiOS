////
////  FirestoreService.swift
////  TimeEgg
////
////  Created by donghyeon choi on 10/28/25.
////
//
//import Foundation
//import FirebaseFirestore
//import FirebaseAuth
//import Combine
//
//// MARK: - 메인 인스턴스 (제목, 메모, 공개범위)
//struct TimeCapsuleMainData: Codable {
//    let id: String
//    let title: String
//    let memo: String
//    let privacy: String // "전체공개", "친구공개", "비공개"
//    let photoUrls: [String]? // 사진 URL 배열
//    let creatorId: String
//    let createdAt: Timestamp
//    let updatedAt: Timestamp
//    
//    enum CodingKeys: String, CodingKey {
//        case id
//        case title
//        case memo
//        case privacy
//        case photoUrls
//        case creatorId
//        case createdAt
//        case updatedAt
//    }
//}
//
//// MARK: - 추가 조건 인스턴스 (날씨, 위치, 시간)
//struct TimeCapsuleAdditionalData: Codable {
//    let timeCapsuleId: String
//    let weather: String? // "맑음", "눈", "비", "흐림", "번개"
//    let location: LocationCondition?
//    let timeCondition: TimeCondition?
//    let createdAt: Timestamp
//    let updatedAt: Timestamp
//    
//    enum CodingKeys: String, CodingKey {
//        case timeCapsuleId
//        case weather
//        case location
//        case timeCondition
//        case createdAt
//        case updatedAt
//    }
//}
//
//// MARK: - 위치 조건
//struct LocationCondition: Codable {
//    let latitude: Double
//    let longitude: Double
//    let address: String?
//    let radius: Double // 반경 (미터)
//    
//    enum CodingKeys: String, CodingKey {
//        case latitude
//        case longitude
//        case address
//        case radius
//    }
//}
//
//// MARK: - 시간 조건
//struct TimeCondition: Codable {
//    let targetDate: Timestamp? // 특정 날짜
//    let timeRange: TimeRange? // 시간 범위
//    
//    enum CodingKeys: String, CodingKey {
//        case targetDate
//        case timeRange
//    }
//}
//
//struct TimeRange: Codable {
//    let startTime: String // HH:mm 형식
//    let endTime: String // HH:mm 형식
//    
//    enum CodingKeys: String, CodingKey {
//        case startTime
//        case endTime
//    }
//}
//
//class FirestoreService: ObservableObject {
//    private let db = Firestore.firestore()
//    private let mainCollection = "timeCapsules"
//    private let additionalCollection = "timeCapsuleAdditional"
//    
//    // MARK: - Firebase 연결 테스트
//    func testConnection(completion: @escaping (Bool, String) -> Void) {
//        // 간단한 읽기 작업으로 연결 확인
//        db.collection("_test").limit(to: 1).getDocuments { snapshot, error in
//            if let error = error {
//                // 네트워크 에러는 정상적인 반응 (컬렉션이 없어도 연결은 성공)
//                if error.localizedDescription.contains("permission") {
//                    completion(false, "Firebase 연결 실패: 권한 문제")
//                } else {
//                    // _test 컬렉션이 없어도 연결은 성공한 것으로 간주
//                    completion(true, "Firebase 연결 성공")
//                }
//            } else {
//                completion(true, "Firebase 연결 성공")
//            }
//        }
//    }
//    
//    // MARK: - 타임캡슐 생성 (메인 데이터)
//    func createTimeCapsule(
//        title: String,
//        memo: String,
//        privacy: String,
//        photoUrls: [String]? = nil,
//        documentId: String? = nil,
//        completion: @escaping (Result<String, Error>) -> Void
//    ) {
//        guard let userId = Auth.auth().currentUser?.uid else {
//            completion(.failure(NSError(domain: "FirestoreService", code: -1, userInfo: [NSLocalizedDescriptionKey: "사용자가 로그인되지 않았습니다."])))
//            return
//        }
//        
//        let documentId = documentId ?? UUID().uuidString
//        let now = Timestamp()
//        
//        let mainData = TimeCapsuleMainData(
//            id: documentId,
//            title: title,
//            memo: memo,
//            privacy: privacy,
//            photoUrls: photoUrls,
//            creatorId: userId,
//            createdAt: now,
//            updatedAt: now
//        )
//        
//        do {
//            try db.collection(mainCollection).document(documentId).setData(from: mainData) { error in
//                if let error = error {
//                    completion(.failure(error))
//                } else {
//                    completion(.success(documentId))
//                }
//            }
//        } catch {
//            completion(.failure(error))
//        }
//    }
//    
//    // MARK: - 추가 조건 데이터 저장
//    func saveAdditionalConditions(
//        timeCapsuleId: String,
//        weather: String?,
//        location: LocationCondition?,
//        timeCondition: TimeCondition?,
//        completion: @escaping (Result<Void, Error>) -> Void
//    ) {
//        let now = Timestamp()
//        
//        let additionalData = TimeCapsuleAdditionalData(
//            timeCapsuleId: timeCapsuleId,
//            weather: weather,
//            location: location,
//            timeCondition: timeCondition,
//            createdAt: now,
//            updatedAt: now
//        )
//        
//        do {
//            try db.collection(additionalCollection).document(timeCapsuleId).setData(from: additionalData) { error in
//                if let error = error {
//                    completion(.failure(error))
//                } else {
//                    completion(.success(()))
//                }
//            }
//        } catch {
//            completion(.failure(error))
//        }
//    }
//    
//    // MARK: - 타임캡슐 생성 (메인 + 추가 조건)
//    func createTimeCapsuleWithConditions(
//        title: String,
//        memo: String,
//        privacy: String,
//        photoUrls: [String]? = nil,
//        weather: String?,
//        location: LocationCondition?,
//        timeCondition: TimeCondition?,
//        documentId: String? = nil,
//        completion: @escaping (Result<String, Error>) -> Void
//    ) {
//        // 먼저 메인 데이터 저장
//        createTimeCapsule(title: title, memo: memo, privacy: privacy, photoUrls: photoUrls, documentId: documentId) { [weak self] result in
//            switch result {
//            case .success(let timeCapsuleId):
//                // 메인 데이터 저장 성공 시 추가 조건 저장
//                self?.saveAdditionalConditions(
//                    timeCapsuleId: timeCapsuleId,
//                    weather: weather,
//                    location: location,
//                    timeCondition: timeCondition
//                ) { additionalResult in
//                    switch additionalResult {
//                    case .success:
//                        completion(.success(timeCapsuleId))
//                    case .failure(let error):
//                        completion(.failure(error))
//                    }
//                }
//            case .failure(let error):
//                completion(.failure(error))
//            }
//        }
//    }
//    
//    // MARK: - 사진과 함께 타임캡슐 생성 (통합 메서드)
//    func createTimeCapsuleWithPhotos(
//        images: [UIImage],
//        title: String,
//        memo: String,
//        privacy: String,
//        weather: String?,
//        location: LocationCondition?,
//        timeCondition: TimeCondition?,
//        storageService: FirebaseStorageService,
//        completion: @escaping (Result<String, Error>) -> Void
//    ) {
//        // 먼저 documentId 생성 (사진 업로드와 타임캡슐 생성에 동일한 ID 사용)
//        let documentId = UUID().uuidString
//        storageService.uploadImages(images: images, timeCapsuleId: documentId) { [weak self] uploadResult in
//            switch uploadResult {
//            case .success(let photoUrls):
//                // 사진 업로드 성공 시 타임캡슐 생성 (동일한 documentId 사용)
//                self?.createTimeCapsuleWithConditions(
//                    title: title,
//                    memo: memo,
//                    privacy: privacy,
//                    photoUrls: photoUrls.isEmpty ? nil : photoUrls,
//                    weather: weather,
//                    location: location,
//                    timeCondition: timeCondition,
//                    documentId: documentId
//                ) { createResult in
//                    switch createResult {
//                    case .success(let timeCapsuleId):
//                        completion(.success(timeCapsuleId))
//                    case .failure(let error):
//                        // 타임캡슐 생성 실패 시 업로드한 사진 삭제
//                        storageService.deleteTimeCapsuleImages(timeCapsuleId: documentId) { _ in }
//                        completion(.failure(error))
//                    }
//                }
//            case .failure(let error):
//                completion(.failure(error))
//            }
//        }
//    }
//    
//    // MARK: - 타임캡슐에 사진 추가
//    func addPhotosToTimeCapsule(
//        timeCapsuleId: String,
//        images: [UIImage],
//        storageService: FirebaseStorageService,
//        completion: @escaping (Result<Void, Error>) -> Void
//    ) {
//        storageService.uploadImages(images: images, timeCapsuleId: timeCapsuleId) { [weak self] uploadResult in
//            switch uploadResult {
//            case .success(let newPhotoUrls):
//                // 기존 사진 URL 가져오기
//                self?.getTimeCapsule(id: timeCapsuleId) { getResult in
//                    switch getResult {
//                    case .success(let timeCapsule):
//                        let existingUrls = timeCapsule.photoUrls ?? []
//                        let allUrls = existingUrls + newPhotoUrls
//                        
//                        // Firestore 업데이트
//                        self?.db.collection(self?.mainCollection ?? "timeCapsules")
//                            .document(timeCapsuleId)
//                            .updateData([
//                                "photoUrls": allUrls,
//                                "updatedAt": Timestamp()
//                            ]) { error in
//                                if let error = error {
//                                    completion(.failure(error))
//                                } else {
//                                    completion(.success(()))
//                                }
//                            }
//                    case .failure(let error):
//                        completion(.failure(error))
//                    }
//                }
//            case .failure(let error):
//                completion(.failure(error))
//            }
//        }
//    }
//    
//    // MARK: - 타임캡슐 조회 (메인 데이터)
//    func getTimeCapsule(id: String, completion: @escaping (Result<TimeCapsuleMainData, Error>) -> Void) {
//        db.collection(mainCollection).document(id).getDocument { document, error in
//            if let error = error {
//                completion(.failure(error))
//                return
//            }
//            
//            guard let document = document, document.exists else {
//                completion(.failure(NSError(domain: "FirestoreService", code: -1, userInfo: [NSLocalizedDescriptionKey: "타임캡슐을 찾을 수 없습니다."])))
//                return
//            }
//            
//            do {
//                let data = try document.data(as: TimeCapsuleMainData.self)
//                completion(.success(data))
//            } catch {
//                completion(.failure(error))
//            }
//        }
//    }
//    
//    // MARK: - 추가 조건 조회
//    func getAdditionalConditions(timeCapsuleId: String, completion: @escaping (Result<TimeCapsuleAdditionalData, Error>) -> Void) {
//        db.collection(additionalCollection).document(timeCapsuleId).getDocument { document, error in
//            if let error = error {
//                completion(.failure(error))
//                return
//            }
//            
//            guard let document = document, document.exists else {
//                completion(.failure(NSError(domain: "FirestoreService", code: -1, userInfo: [NSLocalizedDescriptionKey: "추가 조건을 찾을 수 없습니다."])))
//                return
//            }
//            
//            do {
//                let data = try document.data(as: TimeCapsuleAdditionalData.self)
//                completion(.success(data))
//            } catch {
//                completion(.failure(error))
//            }
//        }
//    }
//    
//    // MARK: - 사용자의 타임캡슐 목록 조회
//    func getUserTimeCapsules(completion: @escaping (Result<[TimeCapsuleMainData], Error>) -> Void) {
//        guard let userId = Auth.auth().currentUser?.uid else {
//            completion(.failure(NSError(domain: "FirestoreService", code: -1, userInfo: [NSLocalizedDescriptionKey: "사용자가 로그인되지 않았습니다."])))
//            return
//        }
//        
//        db.collection(mainCollection)
//            .whereField("creatorId", isEqualTo: userId)
//            .order(by: "createdAt", descending: true)
//            .getDocuments { snapshot, error in
//                if let error = error {
//                    completion(.failure(error))
//                    return
//                }
//                
//                guard let documents = snapshot?.documents else {
//                    completion(.success([]))
//                    return
//                }
//                
//                var timeCapsules: [TimeCapsuleMainData] = []
//                for document in documents {
//                    do {
//                        let data = try document.data(as: TimeCapsuleMainData.self)
//                        timeCapsules.append(data)
//                    } catch {
//                        print("Error decoding document: \(error)")
//                    }
//                }
//                
//                completion(.success(timeCapsules))
//            }
//    }
//    
//    // MARK: - 타임캡슐 업데이트
//    func updateTimeCapsule(
//        id: String,
//        title: String?,
//        memo: String?,
//        privacy: String?,
//        photoUrls: [String]? = nil,
//        completion: @escaping (Result<Void, Error>) -> Void
//    ) {
//        var updateData: [String: Any] = ["updatedAt": Timestamp()]
//        
//        if let title = title {
//            updateData["title"] = title
//        }
//        if let memo = memo {
//            updateData["memo"] = memo
//        }
//        if let privacy = privacy {
//            updateData["privacy"] = privacy
//        }
//        if let photoUrls = photoUrls {
//            updateData["photoUrls"] = photoUrls
//        }
//        
//        db.collection(mainCollection).document(id).updateData(updateData) { error in
//            if let error = error {
//                completion(.failure(error))
//            } else {
//                completion(.success(()))
//            }
//        }
//    }
//    
//    // MARK: - 타임캡슐 삭제
//    func deleteTimeCapsule(
//        id: String,
//        storageService: FirebaseStorageService? = nil,
//        completion: @escaping (Result<Void, Error>) -> Void
//    ) {
//        // 먼저 사진 삭제 (있는 경우)
//        if let storageService = storageService {
//            storageService.deleteTimeCapsuleImages(timeCapsuleId: id) { _ in }
//        }
//        
//        // 메인 데이터 삭제
//        db.collection(mainCollection).document(id).delete { [weak self] error in
//            if let error = error {
//                completion(.failure(error))
//                return
//            }
//            
//            // 추가 조건 데이터도 삭제
//            self?.db.collection(self?.additionalCollection ?? "timeCapsuleAdditional").document(id).delete { error in
//                if let error = error {
//                    completion(.failure(error))
//                } else {
//                    completion(.success(()))
//                }
//            }
//        }
//    }
//    
//    // MARK: - 타임캡슐에서 사진 삭제
//    func removePhotosFromTimeCapsule(
//        timeCapsuleId: String,
//        photoUrls: [String],
//        storageService: FirebaseStorageService,
//        completion: @escaping (Result<Void, Error>) -> Void
//    ) {
//        // Storage에서 사진 삭제
//        storageService.deleteImages(imageUrls: photoUrls) { [weak self] deleteResult in
//            if case .failure(let error) = deleteResult {
//                completion(.failure(error))
//                return
//            }
//            
//            // 기존 사진 URL 가져오기
//            self?.getTimeCapsule(id: timeCapsuleId) { getResult in
//                switch getResult {
//                case .success(let timeCapsule):
//                    let existingUrls = timeCapsule.photoUrls ?? []
//                    let remainingUrls = existingUrls.filter { !photoUrls.contains($0) }
//                    
//                    // Firestore 업데이트
//                    self?.db.collection(self?.mainCollection ?? "timeCapsules")
//                        .document(timeCapsuleId)
//                        .updateData([
//                            "photoUrls": remainingUrls.isEmpty ? FieldValue.delete() : remainingUrls,
//                            "updatedAt": Timestamp()
//                        ]) { error in
//                            if let error = error {
//                                completion(.failure(error))
//                            } else {
//                                completion(.success(()))
//                            }
//                        }
//                case .failure(let error):
//                    completion(.failure(error))
//                }
//            }
//        }
//    }
//}
//
