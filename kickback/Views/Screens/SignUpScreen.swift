import SwiftUI

struct SignUpScreen: View {
    @ObservedObject var viewModel: AuthViewModel
    var onSignInTap: () -> Void

    var body: some View {
        ZStack {
            StripeBackground()
                .ignoresSafeArea()
            VStack(spacing: 24) {
                Text("kickback")
                    .font(.largeTitle)
                    .bold()
                TextField("full name", text: $viewModel.realName)
                    .textContentType(.name)
                    .autocapitalization(.words)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)
                TextField("username", text: $viewModel.username)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)
                TextField("email", text: $viewModel.email)
                    .textContentType(.emailAddress)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)
                SecureField("password", text: $viewModel.password)
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
                        Text("sign up")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                Button("already have an account? come back and sign in.") {
                    onSignInTap()
                }
                .padding(.top, 8)
                Button("skip sign in (dev only)") {
                    viewModel.isAuthenticated = true
                }
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.top, 8)
            }
            .padding()
        }
    }
} 
