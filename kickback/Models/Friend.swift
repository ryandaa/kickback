import Foundation

struct Friend: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let avatar: String // system image name or asset name
} 