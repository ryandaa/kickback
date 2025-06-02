import Foundation
import Combine

@MainActor
class AuthViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var isAuthenticated: Bool = false

    private let authService = AuthService.shared

    func signUp() async {
        isLoading = true
        errorMessage = nil
        do {
            try await authService.signUp(email: email, password: password)
            self.isAuthenticated = self.authService.isAuthenticated
            self.isLoading = false
        } catch {
            self.errorMessage = error.localizedDescription
            self.isLoading = false
        }
    }

    func signIn() async {
        isLoading = true
        errorMessage = nil
        do {
            try await authService.signIn(email: email, password: password)
            self.isAuthenticated = self.authService.isAuthenticated
            self.isLoading = false
        } catch {
            self.errorMessage = error.localizedDescription
            self.isLoading = false
        }
    }

    func signOut() async {
        isLoading = true
        errorMessage = nil
        do {
            try await authService.signOut()
            self.isAuthenticated = self.authService.isAuthenticated
            self.isLoading = false
        } catch {
            self.errorMessage = error.localizedDescription
            self.isLoading = false
        }
    }
} 