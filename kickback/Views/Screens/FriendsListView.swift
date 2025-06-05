import SwiftUI

struct FriendsListView: View {
    // NEW: connect to live data
    @StateObject private var vm = FriendViewModel()

    @State private var searchText = ""
    @State private var showAddFriend = false
    @State private var selectedRequestTab: RequestTab = .incoming

    // Text‑field for adding by UUID
    @State private var manualId = ""

    // MARK: – Computed lists
    private var filteredFriends: [FriendProfile] {
        if searchText.isEmpty { return vm.friends }
        return vm.friends.filter {
            ($0.full_name ?? $0.username)
                .lowercased()
                .contains(searchText.lowercased())
        }
    }

    private var currentRequests: [FriendRequest] {
        selectedRequestTab == .incoming ? vm.incoming : vm.outgoing
    }
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 0) {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Search friends", text: $searchText)
                        .padding(8)
                }
                .padding(.horizontal)
                .background(Color(hex: "#E3E7DF"))
                .cornerRadius(12)
                .padding([.top, .horizontal])
                // Add spacing below search bar
                Spacer().frame(height: 12)
                // Pending Requests
                HStack {
                    Text("Pending Requests")
                        .font(.headline)
                    Spacer()
                    Button(action: { showAddFriend = true }) {
                        HStack(spacing: 4) {
                            Image(systemName: "plus")
                            Text("Add Friend")
                        }
                        .font(.subheadline)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 12)
                        .background(Color(hex: "#E3E7DF"))
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
                // Add spacing below Pending Requests
                Spacer().frame(height: 12)
                // Incoming/Outgoing Toggle
                HStack(spacing: 0) {
                    ForEach(RequestTab.allCases, id: \.self) { tab in
                        Button(action: { selectedRequestTab = tab }) {
                            Text(tab.rawValue)
                                .font(.subheadline)
                                .foregroundColor(selectedRequestTab == tab ? Color(hex: "#7B8C6A") : .gray)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(selectedRequestTab == tab ? Color(hex: "#F5F7F2") : Color.clear)
                                .cornerRadius(16)
                        }
                    }
                }
                .background(Color(hex: "#E3E7DF"))
                .cornerRadius(16)
                .padding(.horizontal)
                // Pending Requests List
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(currentRequests) { req in
                            FriendRequestRow(
                                request: req,
                                isIncoming: req.to_user_id == vm.friends.first?.id, // simple check
                                acceptAction: { Task { await vm.respond(id: req.id, accept: true) } },
                                declineAction:{ Task { await vm.respond(id: req.id, accept: false) } }
                            )
                        }
                    }
                    .padding(.horizontal)
                }

                // Friends List
                Text("Friends")
                    .font(.headline)
                    .padding([.top, .horizontal])

                List {
                    ForEach(filteredFriends) { friend in
                        FriendRow(profile: friend)
                    }
                }
                .listStyle(.plain)
            }
            .navigationBarTitle("Friends", displayMode: .inline)
            .sheet(isPresented: $showAddFriend) {
                VStack(spacing: 20) {
                    Text("Add friend by UUID")
                        .font(.headline)
                    TextField("00000000‑0000‑0000‑0000‑000000000000",
                              text: $manualId)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .padding()
                        .background(Color(hex: "#E3E7DF"))
                        .cornerRadius(8)
                        .padding(.horizontal)
                    Button("Send") {
                        if let id = UUID(uuidString: manualId) {
                            Task { await vm.addFriend(id: id) }
                            showAddFriend = false
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    Button("Close") { showAddFriend = false }
                }
                .padding()
            }
            .task { await vm.refresh() }          // load data
            .alert("Error", isPresented: .constant(vm.errorMessage != nil)) {
                Button("OK") { vm.errorMessage = nil }
            } message: {
                Text(vm.errorMessage ?? "")
            }
        }
    }
}

// MARK: - Supporting Types

enum RequestTab: String, CaseIterable {
    case incoming = "Incoming"
    case outgoing = "Outgoing"
}

struct FriendRow: View {
    let profile: FriendProfile

    var body: some View {
        HStack(spacing: 16) {

            // ── Avatar ----------------------------------------------------
            AsyncImage(url: URL(string: profile.avatar_url ?? "")) { phase in
                switch phase {
                case .success(let img):
                    img.resizable().scaledToFill()
                default:
                    Image(systemName: "person.crop.circle.fill")
                        .resizable().scaledToFit()
                        .foregroundColor(.gray.opacity(0.5))
                }
            }
            .frame(width: 48, height: 48)
            .clipShape(Circle())

            // ── Name ------------------------------------------------------
            VStack(alignment: .leading, spacing: 2) {
                Text(profile.full_name ?? profile.username)
                    .font(.subheadline).fontWeight(.medium)
                Text("@\(profile.username)")
                    .font(.caption).foregroundColor(Color(hex: "#7B8C6A"))
            }
            Spacer()
        }
        .padding(.vertical, 4)
    }
}


struct FriendRequestRow: View {
    let request: FriendRequest
    let isIncoming: Bool
    let acceptAction: () -> Void
    let declineAction: () -> Void

    private var displayName: String {
        if isIncoming {
            request.from_profile?.full_name ?? request.from_profile?.username ?? "Unknown"
        } else {
            request.to_profile?.full_name ?? request.to_profile?.username ?? "Unknown"
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color(hex: "#E3E7DF"))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: "person.crop.circle")
                        .resizable().scaledToFit()
                        .frame(width: 32, height: 32)
                        .foregroundColor(.gray)
                )
            Text(displayName)
                .font(.subheadline).lineLimit(1)

            if isIncoming {
                Button(action: acceptAction) {
                    Image(systemName: "checkmark")
                        .foregroundColor(Color(hex: "#7B8C6A"))
                }
            }

            Button(action: declineAction) {
                Image(systemName: isIncoming ? "xmark" : "trash")
                    .foregroundColor(.gray)
            }
        }
        .padding(8)
        .background(Color(hex: "#F5F7F2"))
        .cornerRadius(12)
    }
}
