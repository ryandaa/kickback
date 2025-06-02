import SwiftUI

struct SignInScreen: View {
    @ObservedObject var viewModel: AuthViewModel
    var onSignUpTap: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Text("Sign In")
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
                    await viewModel.signIn()
                }
            }) {
                if viewModel.isLoading {
                    ProgressView()
                } else {
                    Text("Sign In")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            Button("Don't have an account? Sign Up") {
                onSignUpTap()
            }
            .padding(.top, 8)
        }
        .padding()
    }
} 
 