//
//  CameraView.swift
//  TimeEgg
//
//  Created by donghyeon choi on 9/22/25.
//

import SwiftUI
import AVFoundation
import PhotosUI

struct CameraView: View {
    @State private var cameraViewModel = CameraViewModel()
    @State private var showingPhotoPicker = false
    @State private var showingARMode = false
    @State private var previewLayer: AVCaptureVideoPreviewLayer?
    
    var body: some View {
        NavigationView {
            ZStack {
                // 카메라 프리뷰
                if cameraViewModel.isCameraAuthorized {
                    CameraPreviewView(previewLayer: $previewLayer)
                        .ignoresSafeArea()
                } else {
                    CameraPermissionView()
                }
                
                VStack {
                    Spacer()
                    
                    // 하단 컨트롤
                    HStack(spacing: 30) {
                        // 사진 라이브러리 버튼
                        Button(action: { showingPhotoPicker = true }) {
                            Image(systemName: "photo.on.rectangle")
                                .font(.title2)
                                .foregroundColor(.white)
                        }
                        .disabled(!cameraViewModel.isPhotoLibraryAuthorized)
                        
                        // 촬영 버튼
                        Button(action: {
                            if showingARMode {
                                cameraViewModel.captureARPhoto()
                            } else {
                                cameraViewModel.capturePhoto()
                            }
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 70, height: 70)
                                Circle()
                                    .stroke(Color.white, lineWidth: 2)
                                    .frame(width: 60, height: 60)
                            }
                        }
                        
                        // AR 모드 토글
                        Button(action: { showingARMode.toggle() }) {
                            Image(systemName: showingARMode ? "arkit" : "camera")
                                .font(.title2)
                                .foregroundColor(showingARMode ? .yellow : .white)
                        }
                    }
                    .padding(.bottom, 50)
                }
                
                // 촬영된 사진들
                if !cameraViewModel.capturedPhotos.isEmpty {
                    VStack {
                        HStack {
                            Spacer()
                            CapturedPhotosView(photos: cameraViewModel.capturedPhotos) { index in
                                cameraViewModel.removePhoto(at: index)
                            }
                        }
                        Spacer()
                    }
                    .padding()
                }
            }
            .navigationTitle("카메라")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                setupCamera()
            }
            .onDisappear {
                cameraViewModel.stopSession()
            }
            .sheet(isPresented: $showingPhotoPicker) {
                PhotoPickerView { image in
                    cameraViewModel.addPhotoFromLibrary(image)
                }
            }
        }
    }
    
    private func setupCamera() {
        previewLayer = cameraViewModel.setupCamera()
        if previewLayer != nil {
            cameraViewModel.startSession()
        }
    }
}

struct CameraPreviewView: UIViewRepresentable {
    @Binding var previewLayer: AVCaptureVideoPreviewLayer?
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        if let previewLayer = previewLayer {
            previewLayer.frame = view.bounds
            view.layer.addSublayer(previewLayer)
        }
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        if let previewLayer = previewLayer {
            previewLayer.frame = uiView.bounds
        }
    }
}

struct CameraPermissionView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "camera.fill")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("카메라 권한이 필요합니다")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("설정에서 카메라 권한을 허용해주세요")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("설정으로 이동") {
                if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsURL)
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

struct CapturedPhotosView: View {
    let photos: [UIImage]
    let onRemove: (Int) -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(Array(photos.enumerated()), id: \.offset) { index, photo in
                    ZStack(alignment: .topTrailing) {
                        Image(uiImage: photo)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 60, height: 60)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        
                        Button(action: { onRemove(index) }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.red)
                                .background(Color.white, in: Circle())
                        }
                        .position(x: 55, y: 5)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    CameraView()
}
