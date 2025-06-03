import SwiftUI

struct FeedScreen: View {
    var body: some View {
        VStack(spacing: 0) {
            // Top bar
            VStack(spacing: 4) {
                Spacer().frame(height: 8)
                Text("Feed")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.top, 8)
                Rectangle()
                    .frame(width: 40, height: 2)
                    .foregroundColor(Color(.label).opacity(0.15))
                    .cornerRadius(1)
            }
            .frame(maxWidth: .infinity)
            .background(Color(.systemBackground))
            Spacer()
            // Placeholder for future feed content
        }
        .background(Color(.systemBackground).ignoresSafeArea())
    }
}

#Preview {
    FeedScreen()
}