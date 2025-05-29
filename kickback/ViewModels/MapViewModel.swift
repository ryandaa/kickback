import SwiftUI
import MapKit
import Combine

final class MapViewModel: ObservableObject {
  @Published var region: MKCoordinateRegion
  @Published var friends: [Friend] = []

  init() {
    // start centered on user (fill with your default)
    self.region = MKCoordinateRegion(
      center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
      span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    // For now load some dummy friends:
    self.loadDummyFriends()
  }

  func loadDummyFriends() {
    friends = [
      Friend(
        id: .init(),
        name: "Alex",
        coordinate: CLLocationCoordinate2D(latitude: 37.7750, longitude: -122.4183),
        avatarURL: nil
      ),
      Friend(
        id: .init(),
        name: "Jordan",
        coordinate: CLLocationCoordinate2D(latitude: 37.7732, longitude: -122.4197),
        avatarURL: nil
      )
    ]
  }

  // Later: hook this up to your backend to stream live locations
}