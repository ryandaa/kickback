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
    @StateObject private var authVM = AuthViewModel()
    @State private var showSignUp = false

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
            if !authVM.isAuthenticated {
                if showSignUp {
                    SignUpScreen(viewModel: authVM) {
                        showSignUp = false
                    }
                } else {
                    SignInScreen(viewModel: authVM) {
                        showSignUp = true
                    }
                }
            } else {
                MainTabView()
            }
        }
        .modelContainer(sharedModelContainer)
    }
}

