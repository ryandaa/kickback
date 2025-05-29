//
//  KickbackApp.swift
//  kickback
//
//  Created by Ryan Da on 5/28/25.
//


//
//  kickbackApp.swift
//  kickback
//
//  Created by Ryan Da on 4/28/25.
//

import SwiftUI
import SwiftData

@main
struct KickbackApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
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
            MainTabView()
        }
        .modelContainer(sharedModelContainer)
    }
}

