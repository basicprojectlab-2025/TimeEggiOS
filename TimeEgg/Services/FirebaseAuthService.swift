//
//  FirebaseAuthService.swift
//  TimeEgg
//
//  Created by donghyeon choi on 10/6/25.
//

import Foundation
import FirebaseAuth
import Combine

class FirebaseAuthService: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: FirebaseAuth.User?
    @Published var errorMessage: String?
    @Published var isInitialized = false
    
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
        // 즉시 현재 사용자 상태 확인 (자동 로그인을 위해)
        let currentUser = Auth.auth().currentUser
        DispatchQueue.main.async {
            self.currentUser = currentUser
            self.isAuthenticated = currentUser != nil
            self.isInitialized = true
        }
        
        // 인증 상태 변경 리스너 설정
        authStateListener = Auth.auth().addStateDidChangeListener { [weak self] _, thisUser in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.currentUser = thisUser
                self.isAuthenticated = thisUser != nil
                if !self.isInitialized {
                    self.isInitialized = true
                }
            }
        }
    }
    
    // MARK: - 회원가입
    func signUp(email: String, password: String, completion: @escaping (Bool, String?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    completion(false, error.localizedDescription)
                } else {
                    self?.errorMessage = nil
                    completion(true, nil)
                }
            }
        }
    }
    
    // MARK: - 로그인
    func signIn(email: String, password: String, completion: @escaping (Bool, String?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    completion(false, error.localizedDescription)
                } else {
                    self?.errorMessage = nil
                    completion(true, nil)
                }
            }
        }
    }
    
    // MARK: - 로그아웃
    func signOut() {
        do {
            try Auth.auth().signOut()
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    // MARK: - 비밀번호 재설정
    func resetPassword(email: String, completion: @escaping (Bool, String?) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email) { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    completion(false, error.localizedDescription)
                } else {
                    self?.errorMessage = nil
                    completion(true, nil)
                }
            }
        }
    }
    
    // MARK: - 이메일 인증
    func sendEmailVerification(completion: @escaping (Bool, String?) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(false, "사용자가 로그인되지 않았습니다.")
            return
        }
        
        user.sendEmailVerification { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    completion(false, error.localizedDescription)
                } else {
                    self?.errorMessage = nil
                    completion(true, nil)
                }
            }
        }
    }
    
    // MARK: - 사용자 정보 업데이트
    func updateUserProfile(displayName: String, completion: @escaping (Bool, String?) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(false, "사용자가 로그인되지 않았습니다.")
            return
        }
        
        let changeRequest = user.createProfileChangeRequest()
        changeRequest.displayName = displayName
        changeRequest.commitChanges { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    completion(false, error.localizedDescription)
                } else {
                    self?.errorMessage = nil
                    completion(true, nil)
                }
            }
        }
    }
}

