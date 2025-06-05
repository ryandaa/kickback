//
//  KickbackDetailView.swift
//

import SwiftUI

// MARK: - View -------------------------------------------------------------

struct KickbackDetailView: View {

    // ───── View-model injection ───────────────────────────────────────────
    // Pass the *row* and host flag so the VM can poll & mutate.
    @StateObject private var vm: KickbackDetailViewModel

    /// Current user – used to decide whether they can swipe Accept/Decline.
    private let myUserID = SupabaseManager.shared.client.auth.currentUser?.id

    // Designated init used by caller (e.g. Feed → NavigationLink)
    init(kickback: Kickback, isHost: Bool) {
        _vm = StateObject(wrappedValue: .init(kickback: kickback, isHost: isHost))
    }

    // ───── UI body ────────────────────────────────────────────────────────
    var body: some View {
        VStack {
            // Invite list ---------------------------------------------------
            List {
                ForEach(vm.invites) { invite in
                    inviteRow(invite)
                }
            }
            .listStyle(.plain)
            .animation(.default, value: vm.invites)

            // Host-only “Start” button -------------------------------------
            if vm.isHost, hostCanStart {
                Button {
                    vm.startKickback()
                } label: {
                    if vm.isStarting {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .frame(maxWidth: .infinity)
                    } else {
                        HStack {
                            Image(systemName: "play.fill")
                            Text("Start Kickback")
                        }
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.borderedProminent)
                .padding()
            }
        }
        .navigationTitle("Waiting Room")
        // Error alert ------------------------------------------------------
        .alert("Error",
               isPresented: Binding(
                    get: { vm.errorMessage != nil },
                    set: { if !$0 { vm.errorMessage = nil } }
               ),
               actions: { },
               message: { Text(vm.errorMessage ?? "") }
        )
        // Full-screen transition when the room starts ---------------------
        .fullScreenCover(isPresented: .constant(vm.hasStarted && iAmAccepted)) {
            CameraCaptureView(
                kickbackID: vm.kickback.id,
                currentUserID: myUserID ?? UUID(),          // fall-back if nil
                isHost: vm.isHost
            )
            .environmentObject(ActiveKickbackManager.shared)
        }
    }
}

// MARK: - Private helpers --------------------------------------------------

private extension KickbackDetailView {

    /// Row builder with avatar, name, status & swipe actions
    @ViewBuilder
    func inviteRow(_ invite: KickbackInvite) -> some View {

        let profile   = invite.profiles
        let fullName  = profile?.full_name ?? profile?.username ?? "User"

        HStack(spacing: 12) {

            // Avatar --------------------------------------------------------
            AsyncImage(url: URL(string: profile?.avatar_url ?? "")) { phase in
                switch phase {
                case .success(let img): img.resizable().scaledToFill()
                default:
                    Image(systemName: "person.crop.circle.fill")
                        .resizable().scaledToFit()
                        .foregroundColor(.gray.opacity(0.5))
                }
            }
            .frame(width: 36, height: 36)
            .clipShape(Circle())

            // Name + status -------------------------------------------------
            VStack(alignment: .leading) {
                Text(fullName).font(.subheadline)
                Text(invite.status.capitalized)
                    .font(.caption)
                    .foregroundColor(color(for: invite.status))
            }

            Spacer()
        }
        // Swipe Accept / Decline (only for *my* invite) --------------------
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            if invite.invitee_id == myUserID {
                Button("Accept")  { Task { await vm.accept(invite: invite.id) } }.tint(.green)
                Button("Decline") { Task { await vm.decline(invite: invite.id) } }.tint(.red)
            }
        }
    }

    /// Green / Red / Default for status text
    func color(for status: String) -> Color {
        switch status {
        case "accepted": return .green
        case "declined": return .red
        default:         return .secondary
        }
    }

    // MARK: Derived booleans ----------------------------------------------

    /// Host can press Start only when *someone else* has accepted.
    var hostCanStart: Bool {
        let othersAccepted = vm.invites.contains {
            $0.status == "accepted" && $0.invitee_id != myUserID
        }
        return othersAccepted && !vm.hasStarted
    }

    /// Am *I* an accepted participant?
    var iAmAccepted: Bool {
        vm.invites.first(where: { $0.invitee_id == myUserID })?.status == "accepted"
    }
}


extension KickbackDetailView {
    /// Back-compat convenience init that takes only the UUID.
    init(kickbackID: UUID, isHost: Bool) {
        // create an empty row; you can fetch real data inside the VM later
        let stub = Kickback(
            id:               kickbackID,
            title:            nil,
            description:      nil,
            privacy:          nil,
            created_at:       nil,
            taken_photos_count: nil,
            max_photos:         nil,
            is_started:       false,
            is_finalized:     false,
        )
        self.init(kickback: stub, isHost: isHost)
    }
}
