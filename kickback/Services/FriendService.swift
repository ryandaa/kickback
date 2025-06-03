import Foundation
import Supabase

// MARK: Decodable models coming from PostgREST
struct FriendProfile: Decodable, Identifiable {
    let id: UUID
    let username: String
    let full_name: String?
    let avatar_url: String?
}

struct FriendRequest: Decodable, Identifiable {
    let id: UUID
    let from_user_id: UUID
    let to_user_id: UUID
    let status: String        // "pending", "accepted", ...
    let responded_at: String?
    let from_profile: FriendProfile?
    let to_profile: FriendProfile?
}

// Local errors
enum FriendError: LocalizedError {
    case selfAdd, alreadyExists
    var errorDescription: String? {
        switch self {
        case .selfAdd:        "You can’t add yourself."
        case .alreadyExists:  "Request already exists."
        }
    }
}

struct FriendService {

    private let client = SupabaseManager.shared.client
    private var uid: UUID { client.auth.currentUser!.id }

    // send request
    func sendRequest(to other: UUID) async throws {
        guard other != uid else { throw FriendError.selfAdd }

        // 1️⃣  DUPLICATE CHECK  (remove  “as:” label)
        let dupes: [FriendRequest] = try await client
            .from("friend_requests")
            .select("id")                                  // ← no  as:
            .or("and(from_user_id.eq.\(uid),to_user_id.eq.\(other)),and(from_user_id.eq.\(other),to_user_id.eq.\(uid))")
            .execute()
            .value                                         // type is inferred from the let‑binding


        if !dupes.isEmpty { throw FriendError.alreadyExists }

        // 2️⃣  INSERT  (drop  values:)
        try await client
            .from("friend_requests")
            .insert(["from_user_id": uid,
                     "to_user_id":   other])               // ← no  values:
            .execute()
    }

    // accept / decline
    func respond(requestId: UUID, accept: Bool) async throws {
        try await client
            .from("friend_requests")
            .update(["status": accept ? "accepted" : "declined",
                     "responded_at": ISO8601DateFormatter().string(from: .now)])
            .eq("id", value: requestId)
            .execute()
    }

    // accepted friends
    func fetchFriends() async throws -> [FriendProfile] {
        let rels: [FriendRequest] = try await client
            .from("friend_requests")
            .select("from_user_id,to_user_id")
            .eq("status", value: "accepted")
            .or("from_user_id.eq.\(uid),to_user_id.eq.\(uid)")
            .execute()
            .value

        let ids = Set(rels.map { $0.from_user_id == uid ? $0.to_user_id : $0.from_user_id })
        guard !ids.isEmpty else { return [] }

        return try await client
            .from("profiles")
            .select("*")
            .in("id", value: Array(ids))
            .execute()
            .value
    }

    // requests addressed to me
    func fetchIncoming() async throws -> [FriendRequest] {
        try await client
            .from("friend_requests")
            .select("*,from_profile:profiles!from_user_id(*)")
            .eq("to_user_id", value: uid)
            .eq("status", value: "pending")
            .execute()
            .value
    }

    // requests I have sent and are still pending
    func fetchOutgoing() async throws -> [FriendRequest] {
        try await client
            .from("friend_requests")
            .select("*,to_profile:profiles!to_user_id(*)")
            .eq("from_user_id", value: uid)
            .eq("status", value: "pending")
            .execute()
            .value
    }
}
