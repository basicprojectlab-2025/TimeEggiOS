//
//  FirebaseStorageService.swift
//  TimeEgg
//
//  Created by donghyeon choi on 10/28/25.
//

import Foundation
import FirebaseStorage
import UIKit
import FirebaseAuth

class FirebaseStorageService {
    private let storage = Storage.storage()
    private let timeCapsuleImagesPath = "timeCapsuleImages"
    
    // MARK: - 단일 이미지 업로드
    func uploadImage(
        image: UIImage,
        timeCapsuleId: String,
        imageIndex: Int = 0,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(.failure(NSError(domain: "FirebaseStorageService", code: -1, userInfo: [NSLocalizedDescriptionKey: "이미지를 변환할 수 없습니다."])))
            return
        }
        
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "FirebaseStorageService", code: -1, userInfo: [NSLocalizedDescriptionKey: "사용자가 로그인되지 않았습니다."])))
            return
        }
        
        let imageName = "\(timeCapsuleId)_\(imageIndex)_\(UUID().uuidString).jpg"
        let imagePath = "\(timeCapsuleImagesPath)/\(userId)/\(timeCapsuleId)/\(imageName)"
        let storageRef = storage.reference().child(imagePath)
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        storageRef.putData(imageData, metadata: metadata) { metadata, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            storageRef.downloadURL { url, error in
                if let error = error {
                    completion(.failure(error))
                } else if let url = url {
                    completion(.success(url.absoluteString))
                } else {
                    completion(.failure(NSError(domain: "FirebaseStorageService", code: -1, userInfo: [NSLocalizedDescriptionKey: "다운로드 URL을 가져올 수 없습니다."])))
                }
            }
        }
    }
    
    // MARK: - 여러 이미지 업로드
    func uploadImages(
        images: [UIImage],
        timeCapsuleId: String,
        completion: @escaping (Result<[String], Error>) -> Void
    ) {
        guard !images.isEmpty else {
            completion(.success([]))
            return
        }
        
        var uploadedUrls: [String] = []
        var uploadErrors: [Error] = []
        let group = DispatchGroup()
        
        for (index, image) in images.enumerated() {
            group.enter()
            uploadImage(image: image, timeCapsuleId: timeCapsuleId, imageIndex: index) { result in
                switch result {
                case .success(let url):
                    uploadedUrls.append(url)
                case .failure(let error):
                    uploadErrors.append(error)
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            if !uploadErrors.isEmpty {
                completion(.failure(uploadErrors.first!))
            } else {
                completion(.success(uploadedUrls))
            }
        }
    }
    
    // MARK: - 이미지 삭제
    func deleteImage(imageUrl: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard URL(string: imageUrl) != nil else {
            completion(.failure(NSError(domain: "FirebaseStorageService", code: -1, userInfo: [NSLocalizedDescriptionKey: "유효하지 않은 URL입니다."])))
            return
        }
        
        // Firebase Storage URL에서 경로 추출
        let storageRef = storage.reference(forURL: imageUrl)
        storageRef.delete { error in
            if let error = error {
                // URL 형식이 다를 수 있으므로 경로 기반으로 재시도
                if let path = self.extractPathFromURL(imageUrl) {
                    let pathRef = self.storage.reference().child(path)
                    pathRef.delete { pathError in
                        if let pathError = pathError {
                            completion(.failure(pathError))
                        } else {
                            completion(.success(()))
                        }
                    }
                } else {
                    completion(.failure(error))
                }
            } else {
                completion(.success(()))
            }
        }
    }
    
    // MARK: - URL에서 경로 추출
    private func extractPathFromURL(_ urlString: String) -> String? {
        // Firebase Storage URL 형식: https://firebasestorage.googleapis.com/v0/b/BUCKET/o/PATH?alt=media
        guard let url = URL(string: urlString),
              let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let path = components.path.split(separator: "/").last else {
            return nil
        }
        
        // URL 디코딩
        return String(path).removingPercentEncoding
    }
    
    // MARK: - 여러 이미지 삭제
    func deleteImages(imageUrls: [String], completion: @escaping (Result<Void, Error>) -> Void) {
        guard !imageUrls.isEmpty else {
            completion(.success(()))
            return
        }
        
        let group = DispatchGroup()
        var deleteErrors: [Error] = []
        
        for imageUrl in imageUrls {
            group.enter()
            deleteImage(imageUrl: imageUrl) { result in
                if case .failure(let error) = result {
                    deleteErrors.append(error)
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            if !deleteErrors.isEmpty {
                completion(.failure(deleteErrors.first!))
            } else {
                completion(.success(()))
            }
        }
    }
    
    // MARK: - 타임캡슐의 모든 이미지 삭제
    func deleteTimeCapsuleImages(timeCapsuleId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "FirebaseStorageService", code: -1, userInfo: [NSLocalizedDescriptionKey: "사용자가 로그인되지 않았습니다."])))
            return
        }
        
        let folderPath = "\(timeCapsuleImagesPath)/\(userId)/\(timeCapsuleId)"
        let folderRef = storage.reference().child(folderPath)
        
        folderRef.listAll { result, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let result = result else {
                completion(.success(()))
                return
            }
            
            let group = DispatchGroup()
            var deleteErrors: [Error] = []
            
            for item in result.items {
                group.enter()
                item.delete { error in
                    if let error = error {
                        deleteErrors.append(error)
                    }
                    group.leave()
                }
            }
            
            group.notify(queue: .main) {
                if !deleteErrors.isEmpty {
                    completion(.failure(deleteErrors.first!))
                } else {
                    completion(.success(()))
                }
            }
        }
    }
}

