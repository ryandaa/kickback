import Foundation
import Supabase

// MARK: – Kickback row model ------------------------------------------------
struct Kickback: Decodable, Identifiable {
    let id: UUID
    let title: String?
    let description: String?
    let privacy: String?
    let created_at: String?
    let taken_photos_count: Int?
    var max_photos: Int?
    var is_started: Bool         // host tapped “Start”
    var is_finalized: Bool       // host tapped “Done”
}

/* ───────── INSERT PAYLOADS ───────── */
private struct KickbackInsert: Encodable {
    let title: String?
    let description: String?
}

private struct PhotoInsert: Encodable {
    let kickback_id:    UUID
    let uploader_id:    UUID
    let photo_url:      String
    let sequence_number:Int
}

// MARK: – Service -----------------------------------------------------------
struct KickbackService {
    private let client = SupabaseManager.shared.client

    // helper
    private func uid() throws -> UUID {
        guard let id = client.auth.currentUser?.id else {
            throw NSError(domain: "kickback", code: 401,
                          userInfo:[NSLocalizedDescriptionKey:"Not signed in"])
        }
        return id
    }

    // ───────── create & invites ───────────────────────────────
    func createKickback(title: String?,
                        description: String?,
                        invited: [UUID]) async throws -> Kickback {

        _ = try uid()

        // 1. kickbacks row
        let payload = KickbackInsert(title: title, description: description)
        let kickback: Kickback = try await client
            .from("kickbacks")
            .insert(payload)
            .select("*")
            .single()
            .execute()
            .value

        // 2. invites
        if !invited.isEmpty {
            let rows = invited.map { ["kickback_id": kickback.id,
                                      "invitee_id":  $0] }
            try await client
                .from("kickback_invites")
                .insert(rows)
                .execute()
        }
        return kickback
    }

    func updateInvite(id: UUID, status: String) async throws {
        try await client
            .from("kickback_invites")
            .update(["status": status])
            .eq("id", value: id)
            .single()
            .execute()
    }

    func invites(for kickbackID: UUID) async throws -> [KickbackInvite] {
        try await client
            .from("kickback_invites")
            .select("*, profiles:invitee_id ( id,username,avatar_url,full_name )")
            .eq("kickback_id", value: kickbackID)
            .order("responded_at", ascending:true)
            .execute()
            .value
    }

    // ───────── start / status ──────────────────────────────────
    func startKickback(id: UUID) async throws {
        try await client
            .from("kickbacks")
            .update(["is_started": true])
            .eq("id", value: id)
            .single()
            .execute()
    }

    // ── is the kickback started? ───────────────────────────────
    func isStarted(_ id: UUID) async throws -> Bool {
        struct Row: Decodable { let is_started: Bool }

        let row: Row = try await client
            .from("kickbacks")
            .select("is_started")
            .eq("id", value: id)
            .single()
            .execute()
            .value                                     //  ← now typed
        return row.is_started
    }

    // ───────── photos -------------------------------------------------------
    func insertPhoto(kickbackID: UUID, url: String, seq: Int) async throws {
        let row = PhotoInsert(kickback_id:    kickbackID,
                              uploader_id:    try uid(),
                              photo_url:      url,
                              sequence_number:seq)

        try await client
            .from("kickback_photos")
            .insert(row)
            .execute()
    }

    func photoCount(_ id: UUID) async throws -> Int {
        try await client
            .from("kickback_photos")
            .select("id", count: .exact)
            .eq("kickback_id", value: id)
            .execute()
            .count ?? 0                                //  ← unwrap with fallback
    }

    // ───────── my pending invites (Alerts tab) ────────────────
    func fetchPendingInvites() async throws -> [KickbackInvite] {
        let me = try uid()
        return try await client
            .from("kickback_invites")
            .select("*, kickbacks!inner(title)")
            .eq("invitee_id", value: me)
            .eq("status", value: "pending")
            .execute()
            .value
    }
    
    
    // MARK: – FINALIZE  ----------------------------------------------------------
    func finalizeKickback(_ id: UUID) async throws {
        try await client
            .from("kickbacks")
            .update(["is_finalized": true])
            .eq("id", value: id)
            .single()
            .execute()
    }

    // MARK: – FINALIZED LIST ----------------------------------------------------
    func myKickbacks() async throws -> [Kickback] {
        let me = try uid()

        /* 1️⃣ Accepted invites → collect the IDs */
        struct IDRow: Decodable { let kickback_id: UUID }

        let rows: [IDRow] = try await client
            .from("kickback_invites")
            .select("kickback_id")
            .eq("invitee_id", value: me)
            .eq("status",     value: "accepted")
            .execute()
            .value
        let acceptedIDs = rows.map(\.kickback_id)

        /* 2️⃣ Fetch kickbacks where… host OR accepted */
        let idList = acceptedIDs.map(\.uuidString).joined(separator: ",")

        return try await client
            .from("kickbacks")
            .select("*")
            .or("group_id.eq.\(me),id.in.(\(idList))")
            .eq("is_finalized", value: true)
            .order("created_at", ascending: false)   // ascending:false == descending
            .execute()
            .value                                   // ← final [Kickback]
    }


    // first photo for thumbnail
    func firstPhotoURL(of kickbackID: UUID) async throws -> String? {
        struct Row: Decodable { let photo_url: String }
        let rows: [Row] = try await client
            .from("kickback_photos")
            .select("photo_url")
            .eq("kickback_id", value: kickbackID)
            .order("sequence_number")
            .limit(1)
            .execute()
            .value
        return rows.first?.photo_url
    }
}
