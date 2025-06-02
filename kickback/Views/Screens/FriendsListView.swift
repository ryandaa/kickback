import SwiftUI

struct FriendsListView: View {
    @State private var searchText = ""
    @State private var showAddFriend = false
    @State private var selectedRequestTab: RequestTab = .incoming
    @State private var pendingRequests: [FriendRequest] = [] // mock for now
    @State private var friends: [Friend] = [] // mock for now
    
    var filteredFriends: [Friend] {
        if searchText.isEmpty { return friends }
        return friends.filter { $0.name.lowercased().contains(searchText.lowercased()) }
    }
    
    var filteredRequests: [FriendRequest] {
        pendingRequests.filter { $0.type == selectedRequestTab }
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
                        ForEach(filteredRequests) { req in
                            FriendRequestRow(request: req)
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
                        FriendRow(friend: friend)
                    }
                }
                .listStyle(PlainListStyle())
            }
            .navigationBarTitle("Friends", displayMode: .inline)
            .sheet(isPresented: $showAddFriend) {
                // Placeholder for add friend flow
                VStack {
                    Text("Add Friend Feature Coming Soon")
                        .font(.headline)
                    Button("Close") { showAddFriend = false }
                        .padding()
                }
            }
        }
    }
}

// MARK: - Supporting Types

enum RequestTab: String, CaseIterable {
    case incoming = "Incoming"
    case outgoing = "Outgoing"
}

struct FriendRequest: Identifiable {
    let id = UUID()
    let name: String
    let type: RequestTab
    // let avatarURL: URL? // for future
}

struct FriendRow: View {
    let friend: Friend
    var body: some View {
        HStack(spacing: 16) {
            Circle()
                .fill(Color(hex: "#E3E7DF"))
                .frame(width: 48, height: 48)
                .overlay(
                    Image(systemName: friend.avatar)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.gray)
                )
            VStack(alignment: .leading, spacing: 2) {
                Text(friend.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text("@username") // Placeholder until real usernames are available
                    .font(.caption)
                    .foregroundColor(Color(hex: "#7B8C6A"))
            }
            Spacer()
            Button(action: {}) {
                Image(systemName: "plus")
                    .foregroundColor(Color(hex: "#7B8C6A"))
            }
        }
        .padding(.vertical, 4)
    }
}

struct FriendRequestRow: View {
    let request: FriendRequest
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color(hex: "#E3E7DF"))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: "person.crop.circle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 32, height: 32)
                        .foregroundColor(.gray)
                )
            Text(request.name)
                .font(.subheadline)
                .lineLimit(1)
            if request.type == .incoming {
                Image(systemName: "checkmark")
                    .foregroundColor(Color(hex: "#7B8C6A"))
            } else {
                Image(systemName: "xmark")
                    .foregroundColor(.gray)
            }
        }
        .padding(8)
        .background(Color(hex: "#F5F7F2"))
        .cornerRadius(12)
    }
}

#Preview {
    FriendsListView()
}