import SwiftUI

@MainActor
final class KickbackDetailViewModel: ObservableObject {

    // UI state ---------------------------------------------------------------
    @Published var invites: [KickbackInvite] = []
    @Published var kickbackStarted          = false
    @Published var error: String?

    // book-keeping -----------------------------------------------------------
    private let svc        = KickbackService()
    private let kickbackID: UUID
    let    isHost: Bool

    // MARK: init
    init(kickbackID: UUID, isHost: Bool) {
        self.kickbackID = kickbackID
        self.isHost     = isHost
        Task { await pollLoop() }        // start polling immediately
    }

    // MARK: public
    func accept(invite id: UUID)  async { await changeInvite(id, to:"accepted") }
    func decline(invite id: UUID) async { await changeInvite(id, to:"declined") }

    func startOrForce() async {
        do {
            try await svc.startKickback(id: kickbackID)
            ActiveKickbackManager.shared.begin(id: kickbackID, host: isHost)
            self.kickbackStarted = true
        }
        catch {
            self.error = error.localizedDescription
        }
    }

    // MARK: – polling loop ---------------------------------------------------
    private func pollLoop() async {
        while !Task.isCancelled, !kickbackStarted {
            do {
                async let list = svc.invites(for: kickbackID)
                async let flag = svc.isStarted(kickbackID)
                invites         = try await list
                kickbackStarted = try await flag
            } catch {
                self.error = error.localizedDescription
            }
            try? await Task.sleep(for: .seconds(3))   // every 3 s
        }
    }

    // MARK: helper
    private func changeInvite(_ id: UUID, to status: String) async {
        do   { try await svc.updateInvite(id: id, status: status) }
        catch { self.error = error.localizedDescription }
    }
}
