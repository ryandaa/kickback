import Foundation
import Supabase

final class SupabaseManager {
    static let shared = SupabaseManager()

    let client: SupabaseClient

    private init() {
        // Declare both constants **outside** the `#if` so they’re visible later.
        let url: URL
        let key: String

        guard
            let urlString = ProcessInfo.processInfo.environment["SUPABASE_URL"],
            let key       = ProcessInfo.processInfo.environment["SUPABASE_ANON_KEY"],
            let url       = URL(string: urlString)
        else {
            fatalError("Missing SUPABASE_URL or SUPABASE_ANON_KEY in scheme ▸ Run ▸ Arguments ▸ Environment Variables")
        }


        client = SupabaseClient(supabaseURL: url, supabaseKey: key)
    }
}
