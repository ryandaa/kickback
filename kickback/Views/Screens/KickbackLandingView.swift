import SwiftUI

struct KickbackLandingView: View {
    @State private var showCreation = false

    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            Text("start that kickback")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Button(action: {
                showCreation = true
            }) {
                Text("click here to create a kickback")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .padding(.horizontal)
            }
            Spacer()
        }
        .fullScreenCover(isPresented: $showCreation) {
            KickbackCreationView()
        }
    }
}

#Preview {
    KickbackLandingView()
}