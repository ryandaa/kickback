import Foundation
import SwiftUI                     // ← gives ObservableObject
import Supabase

@MainActor
final class AuthViewModel: ObservableObject {

    // ─────────────── Form fields bound to your TextFields
    @Published var realName   = ""
    @Published var username   = ""
    @Published var email      = ""
    @Published var password   = ""

    // ─────────────── UI state
    @Published var isLoading       = false
    @Published var errorMessage: String?
    @Published var isAuthenticated = false    // used by the app entry point

    private let service = AuthService()

    // MARK: –  Public actions consumed by the views
    func signUp() async {
        isLoading = true
        defer { isLoading = false }

        do {
            try await service.signUp(email: email,
                                     password: password,
                                     username: username,
                                     fullName: realName)
            isAuthenticated = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func signIn() async {
        isLoading = true
        defer { isLoading = false }

        do {
            try await service.signIn(email: email, password: password)
            isAuthenticated = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func signOut() async {
        try? await service.signOut()
        isAuthenticated = false
        // Optional: clear the form
        realName = ""; username = ""; email = ""; password = ""
    }
}
