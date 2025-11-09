//
//  TimeEggApp.swift
//  TimeEgg
//
//  Created by donghyeon choi on 9/22/25.
//

import SwiftUI
import SwiftData
import FirebaseCore
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth
import GoogleSignIn

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    // Firebase 초기화
    FirebaseApp.configure()
    
    // Firebase 연결 상태 확인
    checkFirebaseConnection()
    
    return true
  }
  
  // Google Sign-In URL 핸들링
  func application(_ app: UIApplication,
                   open url: URL,
                   options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    return GIDSignIn.sharedInstance.handle(url)
  }
  
  // MARK: - Firebase 연결 확인
  private func checkFirebaseConnection() {
    // Firebase 앱 초기화 확인
    guard let app = FirebaseApp.app() else {
      print("❌ Firebase 초기화 실패")
      return
    }
    
    print("✅ Firebase 초기화 완료")
    print("✅ Firebase 프로젝트: \(app.name)")
    
    // Client ID 확인 (Google Sign-In용)
    if let clientID = app.options.clientID {
      print("✅ Firebase Client ID: \(clientID)")
    } else {
      print("⚠️ Firebase Client ID를 찾을 수 없습니다. Google Sign-In을 사용하려면 필요합니다.")
      
      // GoogleService-Info.plist에서 직접 확인
      if let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
         let plist = NSDictionary(contentsOfFile: path) {
        if let clientID = plist["CLIENT_ID"] as? String {
          print("✅ GoogleService-Info.plist에서 CLIENT_ID 발견: \(clientID)")
        } else {
          print("❌ GoogleService-Info.plist에 CLIENT_ID가 없습니다.")
        }
      } else {
        print("❌ GoogleService-Info.plist 파일을 찾을 수 없습니다.")
      }
    }
    
    // Realtime Database 연결 확인
    let database = Database.database().reference()
    print("✅ Firebase Realtime Database 연결됨")
    
    // Storage 연결 확인
    let storage = Storage.storage()
    print("✅ Firebase Storage 연결됨")
    
    // Auth 연결 확인
    let auth = Auth.auth()
    print("✅ Firebase Auth 연결됨")
    if let user = auth.currentUser {
      print("✅ 현재 로그인된 사용자: \(user.email ?? "이메일 없음")")
    } else {
      print("ℹ️ 로그인된 사용자 없음")
    }
  }
}

@main
struct TimeEggApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var authService = FirebaseAuthService()
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            User.self,
            TimeEggNotification.self,
            UserPreferences.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            Group {
                if !authService.isInitialized {
                    // 초기 로딩 화면 (인증 상태 확인 중)
                    VStack(spacing: 20) {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("TimeEgg")
                            .font(.title)
                            .fontWeight(.bold)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(red: 0.97, green: 0.98, blue: 1))
                } else if authService.isAuthenticated {
                    // 자동 로그인된 경우 MainView 표시
                    NavigationStack {
                        MainView()
                    }
                } else {
                    // 로그인되지 않은 경우 LoginView 표시
                    NavigationStack {
                        LoginView()
                    }
                }
            }
        }
        .modelContainer(sharedModelContainer)
    }
}
