import SwiftUI

struct AlertsScreen: View {
    @EnvironmentObject private var kickbackMgr: ActiveKickbackManager
    
    @StateObject private var vm = AlertsViewModel()
    @State private var selectedTab: Tab = .invites

    enum Tab: String, CaseIterable { case invites = "Kickbacks", requests = "Friends" }

    var body: some View {
        NavigationStack {
            VStack {
                // toggle bar ------------------------------------------------
                HStack(spacing: 0) {
                    ForEach(Tab.allCases, id: \.self) { tab in
                        Button(tab.rawValue) { selectedTab = tab }
                            .font(.subheadline.weight(.semibold))
                            .frame(maxWidth: .infinity, minHeight: 36)
                            .background(selectedTab == tab ? Color(hex:"#F5F7F2") : .clear)
                            .foregroundColor(selectedTab == tab ? Color(hex:"#7B8C6A") : .gray)
                    }
                }
                .background(Color(hex:"#E3E7DF"))
                .cornerRadius(16)
                .padding()

                // list ------------------------------------------------------
                List {
                    if selectedTab == .invites {
                        Section(header: Text("Kickback Invites")) {
                            if vm.kickInvites.isEmpty { Text("No pending invites") }
                            ForEach(vm.kickInvites) { inv in
                                KickInviteRow(invite: inv,
                                    accept: { Task {
                                                await vm.respondInvite(id: inv.id, accept: true)
                                                await MainActor.run {
                                                    kickbackMgr.activeKickbackID = inv.kickback_id
                                                    kickbackMgr.isHost = false
                                                }
                                             }},
                                    decline:{ Task { await vm.respondInvite(id: inv.id, accept: false) }}
                                )
                            }
                        }
                    } else {
                        Section(header: Text("Friend Requests")) {
                            if vm.friendReqs.isEmpty { Text("No pending requests") }
                            ForEach(vm.friendReqs) { req in
                                FriendRequestRow(request: req,
                                                 isIncoming: true,
                                                 acceptAction: { Task { await vm.respondFriend(id: req.id, accept: true) }},
                                                 declineAction:{ Task { await vm.respondFriend(id: req.id, accept: false) }})
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
            .navigationTitle("Alerts")
            .task { await vm.refresh() }
            .alert("Error", isPresented: .constant(vm.error != nil)) {
                Button("OK") { vm.error = nil }
            } message: { Text(vm.error ?? "") }
        }
    }
}

// MARK: – small row for kickback invites
private struct KickInviteRow: View {
    let invite: KickbackInvite
    let accept: () -> Void
    let decline: () -> Void

    var body: some View {
        HStack {
            VStack(alignment:.leading, spacing: 4) {
                Text(invite.kickback_id.uuidString.prefix(8))        // placeholder
                    .font(.subheadline.weight(.medium))
                Text("wants you to join")
                    .font(.caption).foregroundColor(.secondary)
            }
            Spacer()
            Button(action: accept)  { Image(systemName:"checkmark").foregroundColor(Color(hex:"#7B8C6A")) }
            Button(action: decline) { Image(systemName:"xmark").foregroundColor(.gray) }
        }
        .padding(.vertical,4)
    }
}
