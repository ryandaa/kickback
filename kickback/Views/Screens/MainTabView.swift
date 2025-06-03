import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            FeedScreen()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            
            FriendsListView()
                .tabItem {
                    Label("Friends", systemImage: "person.2")
                }
            
            KickbackCreationView()
                .tabItem {
                    Label("Create", systemImage: "plus.circle")
                }
            
            Text("Alerts Coming Soon")
                .tabItem {
                    Label("Alerts", systemImage: "bell")
                }
            
            ProfileFeedView()
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle.fill")
                }
        }
    }
}

#Preview {
    MainTabView()
}