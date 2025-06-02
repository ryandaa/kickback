import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            KickbackLandingView()
                .tabItem {
                    Label("Create", systemImage: "plus.circle")
                }
            
            Text("Feed Coming Soon")
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            
            CameraView()
                .tabItem {
                    Label("Capture", systemImage: "camera")
                }
            
            Text("Alerts Coming Soon")
                .tabItem {
                    Label("Alerts", systemImage: "bell")
                }
        }
    }
}

#Preview {
    MainTabView()
}