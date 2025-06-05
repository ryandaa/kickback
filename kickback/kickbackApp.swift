import SwiftUI

@main
struct KickbackApp: App {
    @StateObject private var authVM = AuthViewModel()
    @StateObject private var kickbackMgr  = ActiveKickbackManager()
    @State private var showSignUp  = false          // toggles between the two screens

    var body: some Scene {
        WindowGroup {
            if authVM.isAuthenticated {
                MainTabView()
                    .environmentObject(authVM)
                    .environmentObject(kickbackMgr)
            } else {
                // A simple gate that switches between Sign‑In and Sign‑Up
                if showSignUp {
                    SignUpScreen(viewModel: authVM) {
                        showSignUp = false
                    }
                } else {
                    SignInScreen(viewModel: authVM) {
                        showSignUp = true
                    }
                }
            }
        }
    }
}
