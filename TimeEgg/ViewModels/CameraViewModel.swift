//
//  CameraViewModel.swift
//  TimeEgg
//
//  Created by donghyeon choi on 9/22/25.
//

import Foundation
import AVFoundation
import UIKit
import Photos
import Combine

@Observable
class CameraViewModel: NSObject {
    private var captureSession: AVCaptureSession?
    private var photoOutput: AVCapturePhotoOutput?
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    
    var isCameraAuthorized = false
    var isPhotoLibraryAuthorized = false
    var capturedPhotos: [UIImage] = []
    var arPhotos: [UIImage] = []
    var isRecording = false
    var errorMessage: String?
    
    override init() {
        super.init()
        checkPermissions()
    }
    
    // MARK: - Permissions
    
    private func checkPermissions() {
        checkCameraPermission()
        checkPhotoLibraryPermission()
    }
    
    private func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            isCameraAuthorized = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    self?.isCameraAuthorized = granted
                }
            }
        case .denied, .restricted:
            isCameraAuthorized = false
        @unknown default:
            isCameraAuthorized = false
        }
    }
    
    private func checkPhotoLibraryPermission() {
        switch PHPhotoLibrary.authorizationStatus() {
        case .authorized, .limited:
            isPhotoLibraryAuthorized = true
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { [weak self] status in
                DispatchQueue.main.async {
                    self?.isPhotoLibraryAuthorized = (status == .authorized || status == .limited)
                }
            }
        case .denied, .restricted:
            isPhotoLibraryAuthorized = false
        @unknown default:
            isPhotoLibraryAuthorized = false
        }
    }
    
    // MARK: - Camera Setup
    
    func setupCamera() -> AVCaptureVideoPreviewLayer? {
        guard isCameraAuthorized else { return nil }
        
        captureSession = AVCaptureSession()
        guard let captureSession = captureSession else { return nil }
        
        captureSession.sessionPreset = .photo
        
        guard let backCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            errorMessage = "카메라를 찾을 수 없습니다."
            return nil
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: backCamera)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }
            
            photoOutput = AVCapturePhotoOutput()
            if let photoOutput = photoOutput, captureSession.canAddOutput(photoOutput) {
                captureSession.addOutput(photoOutput)
            }
            
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer?.videoGravity = .resizeAspectFill
            
            DispatchQueue.global(qos: .background).async {
                captureSession.startRunning()
            }
            
            return videoPreviewLayer
            
        } catch {
            errorMessage = "카메라 설정에 실패했습니다: \(error.localizedDescription)"
            return nil
        }
    }
    
    func startSession() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.captureSession?.startRunning()
        }
    }
    
    func stopSession() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.captureSession?.stopRunning()
        }
    }
    
    // MARK: - Photo Capture
    
    func capturePhoto() {
        guard let photoOutput = photoOutput else { return }
        
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    func addPhotoFromLibrary(_ image: UIImage) {
        capturedPhotos.append(image)
    }
    
    func removePhoto(at index: Int) {
        guard index < capturedPhotos.count else { return }
        capturedPhotos.remove(at: index)
    }
    
    // MARK: - AR Photo
    
    func captureARPhoto() {
        // AR 촬영 로직 (ARKit 구현 필요)
        // 현재는 일반 사진으로 대체
        capturePhoto()
    }
    
    // MARK: - Data Conversion
    
    func getPhotoData() -> [Data] {
        return capturedPhotos.compactMap { $0.jpegData(compressionQuality: 0.8) }
    }
    
    func getARPhotoData() -> [Data]? {
        guard !arPhotos.isEmpty else { return nil }
        return arPhotos.compactMap { $0.jpegData(compressionQuality: 0.8) }
    }
    
    func clearAllData() {
        capturedPhotos.removeAll()
        arPhotos.removeAll()
    }
}

// MARK: - AVCapturePhotoCaptureDelegate
extension CameraViewModel: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            errorMessage = "사진 촬영에 실패했습니다: \(error.localizedDescription)"
            return
        }
        
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else {
            errorMessage = "사진 데이터를 처리할 수 없습니다."
            return
        }
        
        DispatchQueue.main.async {
            self.capturedPhotos.append(image)
        }
    }
}
