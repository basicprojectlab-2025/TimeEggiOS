//
//  CreateTimeCapsuleView.swift
//  TimeEgg
//
//  Created by donghyeon choi on 9/22/25.
//

import Combine
import SwiftUI
import PhotosUI
import UIKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth

struct CreateTimeCapsuleView: View {
    @State private var title = ""
    @State private var memo = ""
    @State private var selectedPrivacy = "전체공개"
    @State private var finalSelectedPrivacy = 0
    let privacyOptions = ["전체공개", "친구공개", "비공개"]
    @State private var isAlert: Int = 0
    let alerts: [String] = ["", "제목을 반드시 입력하세요!", "타임캡슐 생성 중...", "타임캡슐 생성 완료!", "타임캡슐 생성 실패"]
    @State private var selectedImages: [UIImage] = []
    @State private var selectedPhotoItems: [PhotosPickerItem] = []
    @State private var showPhotoPicker = false
    @State private var isLoading = false
    @State private var sharedUserEmails: [String] = [] // 공유할 사용자 이메일 목록
    @State private var newSharedEmail = "" // 새로 추가할 이메일
    @State private var showConditionSheet = false // 조건 추가 시트 표시 여부
    @State private var selectedDate = Date() // 선택된 날짜
    @State private var selectedTime = Date() // 선택된 시간
    @State private var hasTimeCondition = false // 시간 조건 설정 여부
    @StateObject private var locationService = LocationService()
    @StateObject private var databaseService: RealtimeDatabaseService
    private let storageService = FirebaseStorageService()
    @Environment(\.dismiss) private var dismiss
    
    init() {
        let locationService = LocationService()
        _locationService = StateObject(wrappedValue: locationService)
        _databaseService = StateObject(wrappedValue: RealtimeDatabaseService(locationService: locationService))
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 배경
                Color(red: 0.97, green: 0.99, blue: 1)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // 상단 네비게이션 바
//                    HStack {
//                        // 뒤로가기 버튼
//                        Button(action: {
//                            // 뒤로가기 액션
//                        }) {
//                            Image(systemName: "chevron.left")
//                                .font(.system(size: geometry.size.width * 0.064))
//                                .foregroundColor(.black)
//                                .frame(width: geometry.size.width * 0.107, height: geometry.size.width * 0.107)
//                                .background(.white)
//                                .cornerRadius(geometry.size.width * 0.04)
//                        }
//                        
//                        Spacer()
//                        
//                        // 프로필 버튼
//                        Button(action: {
//                            // 프로필 액션
//                        }) {
//                            Image(systemName: "person.fill")
//                                .font(.system(size: geometry.size.width * 0.048))
//                                .foregroundColor(Color(red: 0.50, green: 0.23, blue: 0.27))
//                                .frame(width: geometry.size.width * 0.107, height: geometry.size.width * 0.107)
//                                .background(.white)
//                                .cornerRadius(geometry.size.width * 0.04)
//                        }
//                    }
//                    .padding(.horizontal, geometry.size.width * 0.053)
//                    .padding(.top, geometry.size.height * 0.01)
//                   
//                    Spacer()
                   
                    // 메인 콘텐츠
                    VStack(spacing: geometry.size.height * 0.025) {
                        // 사진 촬영/업로드 버튼
                        PhotosPicker(
                            selection: $selectedPhotoItems,
                            maxSelectionCount: 10,
                            matching: .images
                        ) {
                            HStack {
                                if selectedImages.isEmpty {
                                    Text("사진 촬영/업로드")
                                        .font(Font.custom("Inter", size: geometry.size.width * 0.043).weight(.bold))
                                        .italic()
                                        .foregroundColor(Color(red: 0.98, green: 0.53, blue: 0.12))
                                } else {
                                    Text("\(selectedImages.count)장 선택됨")
                                        .font(Font.custom("Inter", size: geometry.size.width * 0.043).weight(.bold))
                                        .foregroundColor(Color(red: 0.98, green: 0.53, blue: 0.12))
                                }
                            }
                            .frame(width: geometry.size.width * 0.893, height: geometry.size.height * 0.062)
                            .background(Color.clear)
                            .overlay(
                                RoundedRectangle(cornerRadius: geometry.size.width * 0.053)
                                    .stroke(Color(red: 0.98, green: 0.53, blue: 0.12), lineWidth: 1)
                            )
                        }
                        .onChange(of: selectedPhotoItems) { oldItems, newItems in
                            Task {
                                var loadedImages: [UIImage] = []
                                
                                for item in newItems {
                                    if let data = try? await item.loadTransferable(type: Data.self),
                                       let image = UIImage(data: data) {
                                        loadedImages.append(image)
                                    }
                                }
                                
                                await MainActor.run {
                                    selectedImages = loadedImages
                                }
                            }
                        }
                        
                        // 선택된 사진 미리보기
                        if !selectedImages.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    ForEach(Array(selectedImages.enumerated()), id: \.offset) { index, image in
                                        ZStack(alignment: .topTrailing) {
                                            Image(uiImage: image)
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 100, height: 100)
                                                .clipped()
                                                .cornerRadius(8)
                                            
                                            Button(action: {
                                                selectedImages.remove(at: index)
                                                selectedPhotoItems.remove(at: index)
                                            }) {
                                                Image(systemName: "xmark.circle.fill")
                                                    .foregroundColor(.red)
                                                    .background(Color.white)
                                                    .clipShape(Circle())
                                            }
                                            .padding(4)
                                        }
                                    }
                                }
                                .padding(.horizontal, geometry.size.width * 0.053)
                            }
                            .frame(height: 110)
                        }
                        
                        // 제목 입력 필드
                        VStack(alignment: .leading, spacing: geometry.size.height * 0.01) {
                            Text("제목")
                                .font(Font.custom("Inter", size: geometry.size.width * 0.037))
                                .foregroundColor(Color(red: 0.20, green: 0.20, blue: 0.20))
                            
                            TextField("제목을 입력하세요(최대 20자)", text: $title.limit(20))
                                .font(Font.custom("Inter", size: geometry.size.width * 0.037))
                                .foregroundColor(Color(red: 0.20, green: 0.20, blue: 0.20))
                                .padding(EdgeInsets(
                                    top: geometry.size.height * 0.015,
                                    leading: geometry.size.width * 0.043,
                                    bottom: geometry.size.height * 0.015,
                                    trailing: geometry.size.width * 0.043
                                ))
                                .frame(height: geometry.size.height * 0.062)
                                .background(.white)
                                .cornerRadius(geometry.size.width * 0.021)
                                .overlay(
                                    RoundedRectangle(cornerRadius: geometry.size.width * 0.021)
                                        .stroke(Color(red: 0.85, green: 0.85, blue: 0.85), lineWidth: 0.5)
                                )
                                
                        }
                        .frame(width: geometry.size.width * 0.893)
                        
                        // 메모 입력 필드
                        VStack(alignment: .leading, spacing: geometry.size.height * 0.01) {
                            Text("메모")
                                .font(Font.custom("Inter", size: geometry.size.width * 0.037))
                                .foregroundColor(Color(red: 0.20, green: 0.20, blue: 0.20))
                            
                            TextField("메모를 입력하세요(최대 100자)", text: $memo.limit(100), axis: .vertical)
                                .font(Font.custom("Inter", size: geometry.size.width * 0.037))
                                .foregroundColor(Color(red: 0.20, green: 0.20, blue: 0.20))
                                .padding(EdgeInsets(
                                    top: geometry.size.height * 0.015,
                                    leading: geometry.size.width * 0.043,
                                    bottom: geometry.size.height * 0.015,
                                    trailing: geometry.size.width * 0.043
                                ))
                                .frame(height: geometry.size.height * 0.123)
                                .background(.white)
                                .cornerRadius(geometry.size.width * 0.021)
                                .overlay(
                                    RoundedRectangle(cornerRadius: geometry.size.width * 0.021)
                                        .stroke(Color(red: 0.85, green: 0.85, blue: 0.85), lineWidth: 0.5)
                                )
                        }
                        .frame(width: geometry.size.width * 0.893)
                        
                        // 조건추가 버튼
                        VStack(alignment: .leading, spacing: geometry.size.height * 0.01) {
                            Button(action: {
                                showConditionSheet = true
                            }) {
                                HStack {
                                    Text("조건추가")
                                        .font(Font.custom("Fira Sans", size: geometry.size.width * 0.043).weight(.medium))
                                        .foregroundColor(Color(red: 0.20, green: 0.20, blue: 0.20))
                                    
                                    Spacer()
                                    
                                    if hasTimeCondition {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(Color(red: 0.98, green: 0.53, blue: 0.12))
                                            .font(.system(size: geometry.size.width * 0.048))
                                    }
                                }
                                .frame(width: geometry.size.width * 0.435, height: geometry.size.height * 0.044)
                                .background(.white)
                                .cornerRadius(geometry.size.width * 0.021)
                                .overlay(
                                    RoundedRectangle(cornerRadius: geometry.size.width * 0.021)
                                        .stroke(Color(red: 0.85, green: 0.85, blue: 0.85), lineWidth: 0.5)
                                )
                            }
                            
                            // 설정된 조건 표시
                            if hasTimeCondition {
                                Text("잠금 해제: \(formatDateTime(selectedDate, selectedTime))")
                                    .font(Font.custom("Inter", size: geometry.size.width * 0.032))
                                    .foregroundColor(Color(red: 0.98, green: 0.53, blue: 0.12))
                                    .padding(.leading, geometry.size.width * 0.01)
                            }
                        }
                        .frame(width: geometry.size.width * 0.893, alignment: .leading)
                        .sheet(isPresented: $showConditionSheet) {
                            ConditionSheetView(
                                selectedDate: $selectedDate,
                                selectedTime: $selectedTime,
                                hasTimeCondition: $hasTimeCondition,
                                onDismiss: {
                                    showConditionSheet = false
                                }
                            )
                        }
                        
                        // 공개범위 섹션
                        VStack(alignment: .leading, spacing: geometry.size.height * 0.015) {
                            HStack {
                                Text("공개범위")
                                    .font(Font.custom("Fira Sans", size: geometry.size.width * 0.043).weight(.medium))
                                    .foregroundColor(Color(red: 0.20, green: 0.20, blue: 0.20))
                                
                                Spacer()
                                
                                
                            }
                            
                            // 라디오 버튼 옵션들
                            VStack(spacing: geometry.size.height * 0.01) {
                                ForEach(privacyOptions, id: \.self) { option in
                                    HStack {
                                        Button(action: {
                                            selectedPrivacy = option
                                        }) {
                                            ZStack {
                                                Circle()
                                                    .stroke(Color(red: 0.85, green: 0.85, blue: 0.85), lineWidth: 1)
                                                    .frame(width: geometry.size.width * 0.048, height: geometry.size.width * 0.048)
                                                
                                                if selectedPrivacy == option {
                                                    Circle()
                                                        .fill(Color(red: 0.98, green: 0.53, blue: 0.12))
                                                        .frame(width: geometry.size.width * 0.027, height: geometry.size.width * 0.027)
                                                }
                                            }
                                        }
                                        
                                        Text(option)
                                            .font(Font.custom("Inter", size: geometry.size.width * 0.037))
                                            .foregroundColor(Color(red: 0.20, green: 0.20, blue: 0.20))
                                        
                                        Spacer()
                                    }
                                }
                            }
                        }
                        .frame(width: geometry.size.width * 0.893)
                        
                        // 공유할 사용자 선택 섹션
                        VStack(alignment: .leading, spacing: geometry.size.height * 0.015) {
                            Text("공유할 사용자")
                                .font(Font.custom("Fira Sans", size: geometry.size.width * 0.043).weight(.medium))
                                .foregroundColor(Color(red: 0.20, green: 0.20, blue: 0.20))
                            
                            // 이메일 입력 및 추가
                            HStack(spacing: geometry.size.width * 0.027) {
                                TextField("이메일 입력", text: $newSharedEmail)
                                    .font(Font.custom("Inter", size: geometry.size.width * 0.037))
                                    .foregroundColor(.black)
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                                    .keyboardType(.emailAddress)
                                    .padding(EdgeInsets(
                                        top: geometry.size.height * 0.015,
                                        leading: geometry.size.width * 0.043,
                                        bottom: geometry.size.height * 0.015,
                                        trailing: geometry.size.width * 0.043
                                    ))
                                    .frame(height: geometry.size.height * 0.062)
                                    .background(.white)
                                    .cornerRadius(geometry.size.width * 0.04)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: geometry.size.width * 0.04)
                                            .stroke(Color(red: 0.85, green: 0.85, blue: 0.85), lineWidth: 0.50)
                                    )
                                
                                Button(action: {
                                    if !newSharedEmail.isEmpty && newSharedEmail.contains("@") {
                                        if !sharedUserEmails.contains(newSharedEmail) {
                                            sharedUserEmails.append(newSharedEmail)
                                            newSharedEmail = ""
                                        }
                                    }
                                }) {
                                    Text("추가")
                                        .font(Font.custom("Inter", size: geometry.size.width * 0.037).weight(.medium))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, geometry.size.width * 0.053)
                                        .padding(.vertical, geometry.size.height * 0.015)
                                        .background(Color(red: 0.98, green: 0.53, blue: 0.12))
                                        .cornerRadius(geometry.size.width * 0.04)
                                }
                            }
                            
                            // 선택된 사용자 목록
                            if !sharedUserEmails.isEmpty {
                                VStack(alignment: .leading, spacing: geometry.size.height * 0.01) {
                                    ForEach(sharedUserEmails, id: \.self) { email in
                                        HStack {
                                            Text(email)
                                                .font(Font.custom("Inter", size: geometry.size.width * 0.037))
                                                .foregroundColor(Color(red: 0.20, green: 0.20, blue: 0.20))
                                            
                                            Spacer()
                                            
                                            Button(action: {
                                                sharedUserEmails.removeAll { $0 == email }
                                            }) {
                                                Image(systemName: "xmark.circle.fill")
                                                    .foregroundColor(.gray)
                                                    .font(.system(size: geometry.size.width * 0.048))
                                            }
                                        }
                                        .padding(.vertical, geometry.size.height * 0.005)
                                    }
                                }
                                .padding(.top, geometry.size.height * 0.01)
                            }
                        }
                        .frame(width: geometry.size.width * 0.893)
                    }
                    
                    Spacer()
                    
                    Text("\(alerts[isAlert])")
                        .font(.system(size: 25))
                        .foregroundStyle(Color.red)
                    
                    
                    Spacer()
                    
                    // 하단 타임캡슐 생성 버튼
                    Button(action: {
                        createTimeCapsule()
                    }) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            }
                            Text("타임캡슐 생성")
                                .font(Font.custom("Inter", size: geometry.size.width * 0.037).weight(.bold))
                                .foregroundColor(.white)
                        }
                        .frame(width: geometry.size.width * 0.893, height: geometry.size.height * 0.062)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 0.98, green: 0.53, blue: 0.12),
                                    Color(red: 0.79, green: 0.26, blue: 0.07)
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(geometry.size.width * 0.053)
                        .shadow(
                            color: Color(red: 0.79, green: 0.26, blue: 0.07, opacity: 0.10),
                            radius: geometry.size.width * 0.08,
                            y: geometry.size.height * 0.012
                        )
                    }
                    .disabled(isLoading)
                    .padding(.bottom, geometry.size.height * 0.03)
                }
            }
        }
    }
}

extension Binding where Value == String {
    func limit(_ length: Int) -> Binding<String> {
        return Binding(
            get: { self.wrappedValue },
            set: { newValue in
                if newValue.count <= length {
                    self.wrappedValue = newValue
                } else {
                    self.wrappedValue = String(newValue.prefix(length))
                }
            }
        )
    }
}

// MARK: - 타임캡슐 생성 함수
extension CreateTimeCapsuleView {
    private func createTimeCapsule() {
        // 제목 검증
        guard !title.isEmpty else {
            isAlert = 1
            return
        }
        
        // 로그인 상태 확인
        guard Auth.auth().currentUser != nil else {
            isAlert = 4
            print("❌ 타임캡슐 생성 실패: 사용자가 로그인되지 않았습니다.")
            return
        }
        
        print("✅ 사용자 로그인 확인: \(Auth.auth().currentUser?.uid ?? "없음")")
        print("📝 타임캡슐 생성 시작 - 제목: \(title), 메모: \(memo), 공개범위: \(selectedPrivacy)")
        
        isLoading = true
        isAlert = 2 // "타임캡슐 생성 중..."
        
        // 공유할 사용자 이메일을 사용자 ID로 변환
        databaseService.findUserIdsByEmails(sharedUserEmails) { sharedUserIds in
            // 시간 조건 생성
            let timeCondition: TimeCapsuleTimeCondition? = hasTimeCondition ? {
                // 날짜와 시간을 합쳐서 targetDate 생성
                let calendar = Calendar.current
                let dateComponents = calendar.dateComponents([.year, .month, .day], from: selectedDate)
                let timeComponents = calendar.dateComponents([.hour, .minute], from: selectedTime)
                
                var combinedComponents = DateComponents()
                combinedComponents.year = dateComponents.year
                combinedComponents.month = dateComponents.month
                combinedComponents.day = dateComponents.day
                combinedComponents.hour = timeComponents.hour
                combinedComponents.minute = timeComponents.minute
                
                if let targetDate = calendar.date(from: combinedComponents) {
                    return TimeCapsuleTimeCondition(targetDate: targetDate, timeRange: nil)
                }
                return nil
            }() : nil
            
            // 사진이 있는 경우 사진과 함께 생성, 없는 경우 메인 데이터만 저장
            if !selectedImages.isEmpty {
                print("📸 사진 \(selectedImages.count)장과 함께 타임캡슐 생성")
                // 사진이 있는 경우: 사진 업로드 후 타임캡슐 생성
                databaseService.createTimeCapsuleWithPhotos(
                    images: selectedImages,
                    title: title,
                    memo: memo,
                    privacy: selectedPrivacy,
                    sharedUserIds: sharedUserIds.isEmpty ? nil : sharedUserIds,
                    weather: nil, // 날씨는 MakeView에서 설정할 수 있도록 나중에 추가 가능
                    location: nil, // 위치는 MakeView에서 설정할 수 있도록 나중에 추가 가능
                    timeCondition: timeCondition,
                    storageService: storageService
                ) { result in
                    DispatchQueue.main.async {
                        isLoading = false
                        switch result {
                        case .success(let timeCapsuleId):
                            isAlert = 3 // "타임캡슐 생성 완료!"
                            print("✅ 타임캡슐 생성 성공: \(timeCapsuleId)")
                            // 성공 후 1초 뒤에 화면 닫기
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                                dismiss()
                            })
                        case .failure(let error):
                            isAlert = 4 // "타임캡슐 생성 실패"
                            print("❌ 타임캡슐 생성 실패: \(error.localizedDescription)")
                            print("❌ 에러 상세: \(error)")
                            if let nsError = error as NSError? {
                                print("❌ 에러 도메인: \(nsError.domain), 코드: \(nsError.code)")
                                print("❌ 에러 정보: \(nsError.userInfo)")
                            }
                        }
                    }
                }
            } else {
                print("📝 사진 없이 타임캡슐 생성")
                // 사진이 없는 경우: 메인 데이터와 추가 조건 데이터 모두 저장 (JSON 구조에 맞게)
                databaseService.createTimeCapsuleWithConditions(
                    title: title,
                    memo: memo,
                    privacy: selectedPrivacy,
                    photoUrls: [], // 빈 배열로 저장 (JSON 구조에 맞게)
                    sharedUserIds: sharedUserIds.isEmpty ? nil : sharedUserIds,
                    weather: nil,
                    location: nil,
                    timeCondition: timeCondition
                ) { result in
                    DispatchQueue.main.async {
                        isLoading = false
                        switch result {
                        case .success(let timeCapsuleId):
                            isAlert = 3 // "타임캡슐 생성 완료!"
                            print("✅ 타임캡슐 생성 성공: \(timeCapsuleId)")
                            // 성공 후 1초 뒤에 화면 닫기
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                                dismiss()
                            })
                        case .failure(let error):
                            isAlert = 4 // "타임캡슐 생성 실패"
                            print("❌ 타임캡슐 생성 실패: \(error.localizedDescription)")
                            print("❌ 에러 상세: \(error)")
                            if let nsError = error as NSError? {
                                print("❌ 에러 도메인: \(nsError.domain), 코드: \(nsError.code)")
                                print("❌ 에러 정보: \(nsError.userInfo)")
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func formatDateTime(_ date: Date, _ time: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 MM월 dd일"
        let dateString = dateFormatter.string(from: date)
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        let timeString = timeFormatter.string(from: time)
        
        return "\(dateString) \(timeString)"
    }
}

// MARK: - 조건 추가 시트
struct ConditionSheetView: View {
    @Binding var selectedDate: Date
    @Binding var selectedTime: Date
    @Binding var hasTimeCondition: Bool
    var onDismiss: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            NavigationView {
                ScrollView {
                    VStack(spacing: geometry.size.height * 0.03) {
                        // 제목
                        VStack(spacing: geometry.size.height * 0.01) {
                            Text("잠금 해제 날짜 및 시간 설정")
                                .font(Font.custom("Fira Sans", size: geometry.size.width * 0.05).weight(.bold))
                                .foregroundColor(Color(red: 0.24, green: 0.24, blue: 0.24))
                            
                            Text("타임캡슐이 열릴 날짜와 시간을 선택하세요")
                                .font(Font.custom("Inter", size: geometry.size.width * 0.035))
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, geometry.size.height * 0.02)
                        .padding(.bottom, geometry.size.height * 0.01)
                        
                        // 선택된 날짜/시간 미리보기
                        VStack(spacing: geometry.size.height * 0.015) {
                            Text("선택된 시간")
                                .font(Font.custom("Inter", size: geometry.size.width * 0.038).weight(.medium))
                                .foregroundColor(.secondary)
                            
                            VStack(spacing: geometry.size.height * 0.01) {
                                HStack {
                                    Image(systemName: "calendar")
                                        .font(.system(size: geometry.size.width * 0.05))
                                        .foregroundColor(Color(red: 0.98, green: 0.53, blue: 0.12))
                                    
                                    Text(formatDatePreview(selectedDate))
                                        .font(Font.custom("Inter", size: geometry.size.width * 0.045).weight(.semibold))
                                        .foregroundColor(Color(red: 0.24, green: 0.24, blue: 0.24))
                                }
                                
                                HStack {
                                    Image(systemName: "clock")
                                        .font(.system(size: geometry.size.width * 0.05))
                                        .foregroundColor(Color(red: 0.98, green: 0.53, blue: 0.12))
                                    
                                    Text(formatTimePreview(selectedTime))
                                        .font(Font.custom("Inter", size: geometry.size.width * 0.045).weight(.semibold))
                                        .foregroundColor(Color(red: 0.24, green: 0.24, blue: 0.24))
                                }
                            }
                            .padding(.vertical, geometry.size.height * 0.02)
                            .padding(.horizontal, geometry.size.width * 0.05)
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color(red: 0.98, green: 0.53, blue: 0.12).opacity(0.1))
                            )
                        }
                        .padding(.horizontal, geometry.size.width * 0.05)
                        
                        // 날짜 선택
                        VStack(alignment: .leading, spacing: geometry.size.height * 0.015) {
                            Text("날짜 선택")
                                .font(Font.custom("Inter", size: geometry.size.width * 0.04).weight(.semibold))
                                .foregroundColor(Color(red: 0.24, green: 0.24, blue: 0.24))
                                .padding(.horizontal, geometry.size.width * 0.05)
                            
                            DatePicker(
                                "날짜",
                                selection: $selectedDate,
                                displayedComponents: .date
                            )
                            .datePickerStyle(.graphical)
                            .labelsHidden()
                            .accentColor(Color(red: 0.98, green: 0.53, blue: 0.12))
                            .padding(.horizontal, geometry.size.width * 0.02)
                        }
                        .padding(.vertical, geometry.size.height * 0.02)
                        .background(Color.white)
                        .cornerRadius(15)
                        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                        .padding(.horizontal, geometry.size.width * 0.05)
                        
                        // 시간 선택
                        VStack(alignment: .leading, spacing: geometry.size.height * 0.015) {
                            Text("시간 선택")
                                .font(Font.custom("Inter", size: geometry.size.width * 0.04).weight(.semibold))
                                .foregroundColor(Color(red: 0.24, green: 0.24, blue: 0.24))
                                .padding(.horizontal, geometry.size.width * 0.05)
                            
                            DatePicker(
                                "시간",
                                selection: $selectedTime,
                                displayedComponents: .hourAndMinute
                            )
                            .datePickerStyle(.wheel)
                            .labelsHidden()
                            .frame(height: geometry.size.height * 0.25)
                            .padding(.horizontal, geometry.size.width * 0.02)
                        }
                        .padding(.vertical, geometry.size.height * 0.02)
                        .background(Color.white)
                        .cornerRadius(15)
                        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                        .padding(.horizontal, geometry.size.width * 0.05)
                        
                        // 버튼들
                        HStack(spacing: geometry.size.width * 0.04) {
                            Button(action: {
                                hasTimeCondition = false
                                onDismiss()
                            }) {
                                Text("취소")
                                    .font(Font.custom("Inter", size: geometry.size.width * 0.04).weight(.semibold))
                                    .foregroundColor(Color(red: 0.36, green: 0.39, blue: 0.47))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, geometry.size.height * 0.02)
                                    .background(Color(red: 0.85, green: 0.85, blue: 0.85).opacity(0.3))
                                    .cornerRadius(12)
                            }
                            
                            Button(action: {
                                hasTimeCondition = true
                                onDismiss()
                            }) {
                                Text("확인")
                                    .font(Font.custom("Inter", size: geometry.size.width * 0.04).weight(.semibold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, geometry.size.height * 0.02)
                                    .background(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color(red: 0.98, green: 0.53, blue: 0.12),
                                                Color(red: 0.79, green: 0.26, blue: 0.07)
                                            ]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .cornerRadius(12)
                                    .shadow(color: Color(red: 0.98, green: 0.53, blue: 0.12).opacity(0.3), radius: 8, x: 0, y: 4)
                            }
                        }
                        .padding(.horizontal, geometry.size.width * 0.05)
                        .padding(.top, geometry.size.height * 0.02)
                        .padding(.bottom, geometry.size.height * 0.03)
                    }
                }
                .background(Color(red: 0.97, green: 0.99, blue: 1))
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("닫기") {
                            hasTimeCondition = false
                            onDismiss()
                        }
                        .foregroundColor(Color(red: 0.24, green: 0.24, blue: 0.24))
                    }
                }
            }
        }
    }
    
    private func formatDatePreview(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 MM월 dd일"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }
    
    private func formatTimePreview(_ time: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH시 mm분"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: time)
    }
}

#Preview {
    CreateTimeCapsuleView()
}
