import SwiftUI

struct SignUpScreen: View {
    @ObservedObject var viewModel: AuthViewModel
    var onSignInTap: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Text("Sign Up")
                .font(.largeTitle)
                .bold()
            TextField("Email", text: $viewModel.email)
                .textContentType(.emailAddress)
                .autocapitalization(.none)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)
            SecureField("Password", text: $viewModel.password)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)
            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
            }
            Button(action: {
                Task {
                    await viewModel.signUp()
                }
            }) {
                if viewModel.isLoading {
                    ProgressView()
                } else {
                    Text("Sign Up")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            Button("Already have an account? Sign In") {
                onSignInTap()
            }
            .padding(.top, 8)
        }
        .padding()
    }
} 
