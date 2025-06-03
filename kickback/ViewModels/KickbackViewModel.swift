import Foundation
import SwiftUI
import CoreLocation

@MainActor
final class KickbackViewModel: ObservableObject {
    @Published var title = ""
    @Published var description = ""
    @Published var selectedFriends: [FriendProfile] = []
    @Published var error: String?
    @Published var createdKickback: Kickback?

    private let svc = KickbackService()

    func create() async {
        do {
            let ids = selectedFriends.map(\.id)
            createdKickback = try await svc.createKickback(
                                title: title,
                                description: description,
                                invited: ids)
        } catch {
            self.error = error.localizedDescription   // ← prefix with self.
        }
    }
}
