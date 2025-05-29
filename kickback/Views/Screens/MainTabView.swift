import SwiftUI

struct MainTabView: View {
    @StateObject private var locationManager = LocationManager()
    
    var body: some View {
        TabView {
            MapScreen()
                .tabItem { 
                    Label("Map", systemImage: "map") 
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