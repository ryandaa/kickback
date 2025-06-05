import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var kickbackMgr: ActiveKickbackManager
    @State private var selection = 0          // keep track of tab index

    private var myUserID: UUID? {
        SupabaseManager.shared.client.auth.currentUser?.id
    }
    
    var body: some View {
        TabView(selection: $selection) {

            FeedScreen()
                .tabItem { Label("Home", systemImage: "house") }
                .tag(0)

            FriendsListView()
                .tabItem { Label("Friends", systemImage: "person.2") }
                .tag(1)

            // 🔄 Dynamic content for Create tab
            Group {
                if let id = kickbackMgr.activeKickbackID {
                    KickbackDetailView(kickbackID: id, isHost: kickbackMgr.isHost)
                } else {
                    KickbackCreationView()
                }
            }
            .tabItem { Label("Create", systemImage: "plus.circle") }
            .tag(2)

            AlertsScreen()
                .tabItem { Label("Alerts", systemImage: "bell") }
                .tag(3)

            ProfileFeedView()
                .tabItem { Label("Profile", systemImage: "person.crop.circle.fill") }
                .tag(4)
        }
        // auto-switch to Create tab whenever a kick-back becomes active
        .onChange(of: kickbackMgr.activeKickbackID) { id in
            if id != nil { selection = 2 }
        }
    }
}
