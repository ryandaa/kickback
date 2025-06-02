import SwiftUI

struct ProfileFeedView: View {
    @State private var profileImage: Image = Image(systemName: "person.crop.circle")
    @State private var showingImagePicker = false
    @State private var name: String = "filler_name"
    @State private var username: String = "filler_username"
    @State private var kickbackImages: [Image] = [
        Image("kickback1"), Image("kickback2"), Image("kickback3"), Image("kickback4")
    ] // Replace with real images later
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    Spacer().frame(height: 12)
                    // Profile Picture
                    ZStack(alignment: .bottomTrailing) {
                        profileImage
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 110, height: 110)
                            .clipShape(Circle())
                        Button(action: { showingImagePicker = true }) {
                            Image(systemName: "pencil.circle.fill")
                                .font(.system(size: 28))
                                .foregroundColor(.white)
                                .background(Circle().fill(Color(hex: "#7B8C6A")).frame(width: 36, height: 36))
                                .offset(x: 4, y: 4)
                        }
                    }
                    // Name & Username
                    Text(name)
                        .font(.title2)
                        .fontWeight(.semibold)
                    Text("@\(username)")
                        .font(.subheadline)
                        .foregroundColor(Color(hex: "#7B8C6A"))
                    // Kickbacks Grid
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Kickbacks")
                            .font(.headline)
                            .padding(.top, 8)
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            ForEach(0..<kickbackImages.count, id: \.self) { idx in
                                kickbackImages[idx]
                                    .resizable()
                                    .aspectRatio(1, contentMode: .fill)
                                    .frame(height: 140)
                                    .clipped()
                                    .cornerRadius(16)
                            }
                        }
                    }
                    .padding(.horizontal)
                    Spacer()
                }
                .padding(.top, 24)
            }
            .background(Color(hex: "#F5F7F2").ignoresSafeArea())
            .navigationBarTitle("Profile", displayMode: .inline)
            .sheet(isPresented: $showingImagePicker) {
                // Placeholder for image picker
                VStack {
                    Text("Image picker coming soon")
                    Button("Close") { showingImagePicker = false }
                }
            }
        }
    }
}

#Preview {
    ProfileFeedView()
} 