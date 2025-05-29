import CoreLocation

struct Friend: Identifiable {
  let id: UUID
  let name: String
  let coordinate: CLLocationCoordinate2D
  let avatarURL: URL?
}