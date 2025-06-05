import Foundation

// MARK: - Kickback waiting-room rows
struct KickbackInvite: Decodable, Identifiable, Equatable {
    let id: UUID
    let kickback_id: UUID
    let invitee_id: UUID
    let status: String          // "pending" | "accepted" | "declined"
    let responded_at: String?   // nullable in DB
    let profiles: Profile?
}

struct Profile: Decodable, Identifiable, Equatable {
    let id: UUID
    let username: String?
    let avatar_url: String?
    let full_name: String?
}
