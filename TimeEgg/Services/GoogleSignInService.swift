//
//  GoogleSignInService.swift
//  TimeEgg
//
//  Created by donghyeon choi on 10/7/25.
//

import Foundation
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import Combine
import UIKit
import GoogleSignIn

class GoogleSignInService: ObservableObject {
    @Published var isSignedIn = false
    @Published var currentUser: User?
    @Published var errorMessage: String?
    
    private var authStateListener: AuthStateDidChangeListenerHandle?
    
    init() {
        setupAuthStateListener()
    }
    
    deinit {
        if let listener = authStateListener {
            Auth.auth().removeStateDidChangeListener(listener)
        }
    }
    
    private func setupAuthStateListener() {
        // Firebase Auth 상태 리스너 설정
        authStateListener = Auth.auth().addStateDidChangeListener { [weak self] _, firebaseUser in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                if let firebaseUser = firebaseUser {
                    // Firebase 사용자가 있으면 User 모델로 변환
                    self.currentUser = User(from: firebaseUser)
                    self.isSignedIn = true
                    self.errorMessage = nil
                } else {
                    self.currentUser = nil
                    self.isSignedIn = false
                }
            }
        }
    }
    
    func signInWithGoogle() async -> Bool {
        // Firebase가 초기화되었는지 확인
        guard FirebaseApp.app() != nil else {
            await MainActor.run {
                self.errorMessage = "Firebase가 초기화되지 않았습니다. 앱을 다시 시작해주세요."
            }
            return false
        }
        
        // clientID 가져오기 (여러 방법 시도)
        var clientID: String?
        
        // 방법 1: Firebase options에서 가져오기
        if let firebaseClientID = FirebaseApp.app()?.options.clientID, !firebaseClientID.isEmpty {
            clientID = firebaseClientID
        }
        
        // 방법 2: GoogleService-Info.plist에서 직접 읽기
        if clientID == nil {
            if let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
               let plist = NSDictionary(contentsOfFile: path),
               let plistClientID = plist["CLIENT_ID"] as? String, !plistClientID.isEmpty {
                clientID = plistClientID
            }
        }
        
        guard let finalClientID = clientID else {
            await MainActor.run {
                self.errorMessage = "Google Sign-In 설정을 찾을 수 없습니다. GoogleService-Info.plist 파일에 CLIENT_ID가 있는지 확인해주세요."
            }
            return false
        }
        
        // Google Sign-In 설정
        let config = GIDConfiguration(clientID: finalClientID)
        GIDSignIn.sharedInstance.configuration = config
        
        guard let windowScene = await UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = await windowScene.windows.first,
              let rootViewController = await window.rootViewController else {
            await MainActor.run {
                self.errorMessage = "화면을 찾을 수 없습니다."
            }
            return false
        }
        
        do {
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
            
            guard let idToken = result.user.idToken?.tokenString else {
                await MainActor.run {
                    self.errorMessage = "Google 로그인 토큰을 가져올 수 없습니다."
                }
                return false
            }
            
            // Firebase Auth에 Google 인증 정보 전달
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                         accessToken: result.user.accessToken.tokenString)
            
            let authResult = try await Auth.auth().signIn(with: credential)
            
            await MainActor.run {
                // Firebase Auth 상태 리스너가 자동으로 currentUser를 업데이트함
                self.errorMessage = nil
            }
            
            return true
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
            }
            return false
        }
    }
    
    func signOut() {
        // Google Sign-In 로그아웃
        GIDSignIn.sharedInstance.signOut()
        
        // Firebase Auth 로그아웃
        do {
            try Auth.auth().signOut()
        } catch {
            print("Firebase Auth 로그아웃 오류: \(error.localizedDescription)")
            self.errorMessage = error.localizedDescription
        }
        
        // 로컬 상태 초기화
        currentUser = nil
        isSignedIn = false
    }
    
    func getUserInfo() -> (name: String, email: String, profileImageURL: String?) {
        guard let user = currentUser else {
            return ("", "", nil)
        }
        
        let name = user.username
        let email = user.email
        let profileImageURL: String? = nil // SwiftData 모델은 Data 타입 이미지이므로 URL 없음
        return (name, email, profileImageURL)
    }
}

