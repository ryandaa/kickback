import Foundation
import Supabase

class AuthService: ObservableObject {
    static let shared = AuthService()
    
    private let client: SupabaseClient?
    
    @Published var isAuthenticated: Bool = false
    
    private init() {
        let urlString = Bundle.main.infoDictionary?["SUPABASE_URL"] as? String ?? ""
        let anonKey = Bundle.main.infoDictionary?["SUPABASE_ANON_KEY"] as? String ?? ""
        print("[DEBUG] Raw urlString from Info.plist:", urlString)
        print("[DEBUG] Raw anonKey from Info.plist:", anonKey)
        let cleanedURLString = urlString.hasPrefix("https://") ? urlString : "https://" + urlString
        if let url = URL(string: cleanedURLString), !anonKey.isEmpty {
            client = SupabaseClient(supabaseURL: url, supabaseKey: anonKey)
        } else {
            client = nil
            print("[ERROR] Invalid Supabase URL or anon key.")
        }
    }

    @MainActor
    func signUp(email: String, password: String) async throws {
        guard let client else { return }
        let response = try await client.auth.signUp(email: email, password: password)
        if response.user != nil {
            isAuthenticated = true
        }
    }

    @MainActor
    func signIn(email: String, password: String) async throws {
        guard let client else { return }
        let response = try await client.auth.signIn(email: email, password: password)
        if response.user != nil {
            isAuthenticated = true
        }
    }

    @MainActor
    func signOut() async throws {
        guard let client else { return }
        try await client.auth.signOut()
        isAuthenticated = false
    }
} 
