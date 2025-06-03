import Foundation
import Supabase

// MARK: – DTO used for the INSERT
private struct ProfileInsert: Encodable {
    let id: UUID
    let username: String
    let full_name: String?     // snake_case = column name
    let email: String?
    let avatar_url: String?
}

struct AuthService {
    private let auth   = SupabaseManager.shared.client.auth
    private let client = SupabaseManager.shared.client

    /// Registers a user in Supabase Auth *and* inserts a row in `profiles`.
    func signUp(email: String,
                password: String,
                username: String,
                fullName: String?) async throws {

        // 1. Auth
        let result = try await auth.signUp(email: email, password: password)
        let uid    = result.user.id

        // 2. Profile row
        let row = ProfileInsert(id: uid,
                                username: username,
                                full_name: fullName,
                                email: email,
                                avatar_url: nil)
        try await client.from("profiles").insert(row).execute()
    }

    func signIn(email: String, password: String) async throws {
        _ = try await auth.signIn(email: email, password: password)
    }

    func signOut() async throws { try await auth.signOut() }

    var currentUser: User? { auth.currentUser }
}
