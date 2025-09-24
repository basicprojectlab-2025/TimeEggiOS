//
//  TimeEggApp.swift
//  TimeEgg
//
//  Created by donghyeon choi on 9/22/25.
//

import SwiftUI
import SwiftData

@main
struct TimeEggApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            TimeCapsule.self,
            User.self,
            TimeEggNotification.self,
            LocationData.self,
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
            SimpleContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
