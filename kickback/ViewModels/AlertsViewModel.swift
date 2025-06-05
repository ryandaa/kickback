import Foundation
import SwiftUI

@MainActor
final class AlertsViewModel: ObservableObject {

    @Published private(set) var friendReqs:   [FriendRequest]  = []
    @Published private(set) var kickInvites:  [KickbackInvite] = []
    @Published var error: String?

    private let friendSvc  = FriendService()
    private let kickSvc    = KickbackService()

    // MARK: – public
    func refresh() async {
        do {
            async let f = friendSvc.fetchIncoming()            // pending → me
            async let k = kickSvc.fetchPendingInvites()        // new helper below
            friendReqs  = try await f
            kickInvites = try await k
        } catch { self.error = errMsg(error) }
    }

    func respondFriend(id: UUID, accept: Bool) async {
        do { try await friendSvc.respond(requestId: id, accept: accept); await refresh() }
        catch { self.error = errMsg(error) }
    }

    func respondInvite(id: UUID, accept: Bool) async {
        do { try await kickSvc.updateInvite(id: id, status: accept ? "accepted" : "declined"); await refresh() }
        catch { self.error = errMsg(error) }
    }

    // MARK: – helpers
    private func errMsg(_ e: Error) -> String {
        (e as? LocalizedError)?.errorDescription ?? e.localizedDescription
    }
}
