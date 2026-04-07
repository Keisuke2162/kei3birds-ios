import SwiftUI
import GoogleSignIn

struct LoginView: View {
    let viewModel: AuthViewModel
    @State private var isLoading = false

    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            Image(systemName: "bird.fill")
                .font(.system(size: 80)).foregroundStyle(.green)
            Text("Kei3Birds").font(.largeTitle.bold())
            Text("日本の野鳥を記録しよう").foregroundStyle(.secondary)
            Spacer()

            Button { signInWithGoogle() } label: {
                HStack {
                    Image(systemName: "g.circle.fill")
                    Text("Googleでログイン")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent).controlSize(.large).tint(.blue)
            .disabled(isLoading)

            if isLoading { ProgressView() }
            if let error = viewModel.errorMessage {
                Text(error).foregroundStyle(.red).font(.caption)
            }
            Spacer()
        }
        .padding()
    }

    private func signInWithGoogle() {
        isLoading = true

        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.windows.first?.rootViewController else {
            isLoading = false
            return
        }

        GIDSignIn.sharedInstance.signIn(withPresenting: rootVC) { result, error in
            if error != nil {
                isLoading = false
                return
            }
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else {
                isLoading = false
                return
            }
            let accessToken = user.accessToken.tokenString
            Task {
                await viewModel.signInWithGoogle(idToken: idToken, accessToken: accessToken)
                isLoading = false
            }
        }
    }
}
