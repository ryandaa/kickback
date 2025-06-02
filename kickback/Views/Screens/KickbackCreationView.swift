import SwiftUI

struct KickbackCreationView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var invitedFriends: [Friend] = []
    @State private var kickbackName: String = ""
    @State private var kickbackDescription: String = ""
    @State private var showCamera = false
    @State private var capturedImages: [UIImage] = []
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Invite Friends Section
                    Text("Invite Friends")
                        .font(.headline)
                        .padding(.top, 8)
                    HStack(spacing: 12) {
                        ForEach(invitedFriends) { friend in
                            HStack(spacing: 8) {
                                Circle()
                                    .fill(Color(hex: "#F5F7F2"))
                                    .frame(width: 40, height: 40)
                                    .overlay(
                                        Image(systemName: friend.avatar)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 24, height: 24)
                                            .foregroundColor(.gray)
                                    )
                                Text(friend.name)
                                    .font(.subheadline)
                                    .foregroundColor(.black)
                                Button(action: {
                                    // Remove friend
                                    invitedFriends.removeAll { $0.id == friend.id }
                                }) {
                                    Image(systemName: "xmark")
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding(.vertical, 6)
                            .padding(.horizontal, 12)
                            .background(Color(hex: "#F5F7F2"))
                            .cornerRadius(12)
                        }
                        Spacer()
                    }
                    Button(action: {
                        // Add more friends (mock)
                        invitedFriends.append(Friend(name: "New Friend", avatar: "person.fill"))
                    }) {
                        HStack {
                            Text("+ Add More")
                                .foregroundColor(Color(hex: "#7B8C6A"))
                            Spacer()
                        }
                        .padding()
                        .background(Color(hex: "#E3E7DF"))
                        .cornerRadius(12)
                    }
                    // Kickback Details
                    Text("Kickback Details")
                        .font(.headline)
                        .padding(.top, 8)
                    TextField("Kickback Name", text: $kickbackName)
                        .padding()
                        .background(Color(hex: "#E3E7DF"))
                        .cornerRadius(12)
                    ZStack(alignment: .topLeading) {
                        TextEditor(text: $kickbackDescription)
                            .frame(height: 80)
                            .padding(8)
                            .background(Color(hex: "#E3E7DF"))
                            .cornerRadius(16)
                        if kickbackDescription.isEmpty {
                            Text("Write a message...")
                                .foregroundColor(Color(hex: "#A3B18A").opacity(0.6))
                                .padding(16)
                                .allowsHitTesting(false)
                        }
                    }
                    // Friend Invited Section
                    HStack {
                        Text("\(invitedFriends.count) friend\(invitedFriends.count == 1 ? "" : "s") invited")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Spacer()
                        if let first = invitedFriends.first {
                            Circle()
                                .fill(Color(hex: "#F5F7F2"))
                                .frame(width: 48, height: 48)
                                .overlay(
                                    Image(systemName: first.avatar)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 32, height: 32)
                                        .foregroundColor(.gray)
                                )
                        }
                    }
                    // Next Button
                    Button(action: {
                        showCamera = true
                    }) {
                        HStack {
                            Text("Next")
                            Image(systemName: "arrow.right")
                        }
                        .font(.headline)
                        .foregroundColor(Color(hex: "#7B8C6A"))
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity)
                        .background(Color(hex: "#F5F7F2"))
                        .cornerRadius(16)
                    }
                    .padding(.top, 8)
                }
                .padding()
            }
            .navigationBarTitle("New Kickback", displayMode: .inline)
            .navigationBarItems(leading: Button(action: {
                dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .foregroundColor(.black)
            })
            .fullScreenCover(isPresented: $showCamera) {
                CameraCaptureView(capturedImages: $capturedImages)
            }
        }
    }
}

enum Privacy: String, CaseIterable {
    case privateOption = "Private"
    case friendsOnly = "Friends Only"
    case publicOption = "Public"
} 