import Foundation
import SwiftUI

@MainActor
final class FriendViewModel: ObservableObject {

    @Published private(set) var friends:   [FriendProfile]  = []
    @Published private(set) var incoming:  [FriendRequest]  = []
    @Published private(set) var outgoing:  [FriendRequest]  = []
    @Published var errorMessage: String?

    private let svc = FriendService()

    // MARK: – Public API for the view
    func refresh() async {
        do {
            async let f = svc.fetchFriends()
            async let i = svc.fetchIncoming()
            async let o = svc.fetchOutgoing()
            friends  = try await f
            incoming = try await i
            outgoing = try await o
        } catch { errorMessage = errMsg(error) }
    }

    func addFriend(id: UUID) async {
        do { try await svc.sendRequest(to: id); await refresh() }
        catch { errorMessage = errMsg(error) }
    }

    func respond(id: UUID, accept: Bool) async {
        do { try await svc.respond(requestId: id, accept: accept); await refresh() }
        catch { errorMessage = errMsg(error) }
    }

    private func errMsg(_ e: Error) -> String {
        (e as? LocalizedError)?.errorDescription ?? e.localizedDescription
    }
}
