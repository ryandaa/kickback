import Foundation
import Supabase

// Model returned by .select(*)
struct Kickback: Decodable, Identifiable {
    let id: UUID
    let title: String?
    let description: String?
    let privacy: String?
    let created_at: String?
}

/* ───────── INSERT PAYLOAD ───────── */
private struct KickbackInsert: Encodable {
    let title: String?
    let description: String?
}

struct KickbackService {
    private let client = SupabaseManager.shared.client

    private func uid() throws -> UUID {
        guard let id = client.auth.currentUser?.id else {
            throw NSError(domain: "kickback", code: 401,
                          userInfo: [NSLocalizedDescriptionKey : "Not signed in"])
        }
        return id
    }

    func createKickback(title: String?,
                        description: String?,
                        invited: [UUID]) async throws -> Kickback {

        _ = try uid()                                // ensure session exists

        /* 1️⃣ insert into kickbacks */
        let payload = KickbackInsert(title: title, description: description)
        let kickback: Kickback = try await client
            .from("kickbacks")
            .insert(payload)                         // ← Encodable, no label
            .select("*")
            .single()
            .execute()
            .value

        /* 2️⃣ bulk invitations */
        if !invited.isEmpty {
            let rows = invited.map { ["kickback_id": kickback.id,
                                      "invitee_id":  $0] }
            try await client
                .from("kickback_invites")
                .insert(rows)                        // rows is [[String:Encodable]]
                .execute()
        }

        return kickback
    }
}
