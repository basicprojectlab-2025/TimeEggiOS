//
//  CreateTimeCapsuleView.swift
//  TimeEgg
//
//  Created by donghyeon choi on 9/22/25.
//

import SwiftUI
import PhotosUI
import SwiftData

struct CreateTimeCapsuleView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var cameraViewModel = CameraViewModel()
    @State private var timeCapsuleViewModel: TimeCapsuleViewModel?
    
    @State private var title = ""
    @State private var content = ""
    @State private var isPublic = false
    @State private var taggedUsers: [String] = []
    @State private var showingCamera = false
    @State private var showingPhotoPicker = false
    @State private var showingStickerPicker = false
    @State private var showingUserSearch = false
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            Form {
                Section("기본 정보") {
                    TextField("제목", text: $title)
                    TextField("내용", text: $content, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("사진") {
                    HStack {
                        Button("카메라로 촬영") {
                            showingCamera = true
                        }
                        .buttonStyle(.bordered)
                        
                        Button("사진 라이브러리") {
                            showingPhotoPicker = true
                        }
                        .buttonStyle(.bordered)
                    }
                    
                    if !cameraViewModel.capturedPhotos.isEmpty {
                        CapturedPhotosGridView(photos: cameraViewModel.capturedPhotos) { index in
                            cameraViewModel.removePhoto(at: index)
                        }
                    }
                }
                
                Section("스티커") {
                    Button("스티커 추가") {
                        showingStickerPicker = true
                    }
                    .buttonStyle(.bordered)
                    
                    if !cameraViewModel.selectedStickers.isEmpty {
                        StickerGridView(stickers: cameraViewModel.selectedStickers) { index in
                            cameraViewModel.removeSticker(at: index)
                        }
                    }
                }
                
                Section("설정") {
                    Toggle("공개 타임캡슐", isOn: $isPublic)
                        .help("공개 타임캡슐은 다른 사용자도 볼 수 있습니다")
                    
                    Button("사용자 태그") {
                        showingUserSearch = true
                    }
                    .buttonStyle(.bordered)
                    
                    if !taggedUsers.isEmpty {
                        TaggedUsersView(taggedUsers: taggedUsers) { user in
                            taggedUsers.removeAll { $0 == user }
                        }
                    }
                }
                
                if let errorMessage = errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("새 타임캡슐")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("생성") {
                        createTimeCapsule()
                    }
                    .disabled(title.isEmpty || content.isEmpty || isLoading)
                }
            }
            .sheet(isPresented: $showingCamera) {
                CameraView()
            }
            .sheet(isPresented: $showingPhotoPicker) {
                PhotoPickerView { image in
                    cameraViewModel.addPhotoFromLibrary(image)
                }
            }
            .sheet(isPresented: $showingStickerPicker) {
                StickerPickerView { sticker in
                    cameraViewModel.addSticker(sticker)
                }
            }
            .sheet(isPresented: $showingUserSearch) {
                UserSearchView { user in
                    if !taggedUsers.contains(user) {
                        taggedUsers.append(user)
                    }
                }
            }
            .onAppear {
                setupViewModel()
            }
        }
    }
    
    private func setupViewModel() {
        let locationService = LocationService()
        let notificationService = NotificationService()
        timeCapsuleViewModel = TimeCapsuleViewModel(
            modelContext: modelContext,
            locationService: locationService,
            notificationService: notificationService
        )
    }
    
    private func createTimeCapsule() {
        guard let timeCapsuleViewModel = timeCapsuleViewModel else { 
            errorMessage = "뷰모델이 초기화되지 않았습니다."
            return 
        }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            await timeCapsuleViewModel.createTimeCapsule(
                title: title,
                content: content,
                photos: cameraViewModel.getPhotoData(),
                arPhotos: cameraViewModel.getARPhotoData(),
                stickers: cameraViewModel.getStickerData(),
                isPublic: isPublic,
                taggedUsers: taggedUsers
            )
            
            await MainActor.run {
                isLoading = false
                if timeCapsuleViewModel.errorMessage == nil {
                    dismiss()
                } else {
                    errorMessage = timeCapsuleViewModel.errorMessage
                }
            }
        }
    }
}

struct CapturedPhotosGridView: View {
    let photos: [UIImage]
    let onRemove: (Int) -> Void
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 10) {
            ForEach(Array(photos.enumerated()), id: \.offset) { index, photo in
                ZStack(alignment: .topTrailing) {
                    Image(uiImage: photo)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    
                    Button(action: { onRemove(index) }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.red)
                            .background(Color.white, in: Circle())
                    }
                    .offset(x: 5, y: -5)
                }
            }
        }
    }
}

struct StickerGridView: View {
    let stickers: [TimeEgg.StickerData]
    let onRemove: (Int) -> Void
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 10) {
            ForEach(Array(stickers.enumerated()), id: \.offset) { index, sticker in
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "face.smiling")
                        .font(.title2)
                        .foregroundColor(.blue)
                        .frame(width: 50, height: 50)
                        .background(Color.blue.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
                    
                    Button(action: { onRemove(index) }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.red)
                            .background(Color.white, in: Circle())
                    }
                    .offset(x: 5, y: -5)
                }
            }
        }
    }
}

struct TaggedUsersView: View {
    let taggedUsers: [String]
    let onRemove: (String) -> Void
    
    var body: some View {
        ForEach(taggedUsers, id: \.self) { user in
            HStack {
                Text(user)
                Spacer()
                Button("제거") {
                    onRemove(user)
                }
                .foregroundColor(.red)
            }
        }
    }
}

#Preview {
    CreateTimeCapsuleView()
        .modelContainer(for: TimeCapsule.self, inMemory: true)
}
