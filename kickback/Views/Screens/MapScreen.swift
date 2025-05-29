import SwiftUI
import MapKit
import CoreLocation

struct MapScreen: View {
    @StateObject private var locationManager = LocationManager()
    
    var body: some View {
        Map(
            coordinateRegion: $locationManager.region,
            showsUserLocation: true
        )
        .mapControls {
            MapUserLocationButton()
        }
        .onAppear {
            locationManager.requestPermission()
        }
    }
}

#Preview {
    MapScreen()
}