import SwiftUI

struct UsernameSetupView: View {
    let viewModel: AuthViewModel
    @State private var username = ""
    @State private var isLoading = false

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "person.badge.plus")
                .font(.system(size: 60)).foregroundStyle(.green)
            Text("ユーザー名を設定").font(.title2.bold())
            Text("フォトカードに表示されます").foregroundStyle(.secondary)

            TextField("ユーザー名", text: $username)
                .textFieldStyle(.roundedBorder)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .padding(.horizontal, 40)

            Button {
                isLoading = true
                Task {
                    await viewModel.setUsername(username.trimmingCharacters(in: .whitespaces))
                    isLoading = false
                }
            } label: {
                Text("登録する").frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent).controlSize(.large)
            .padding(.horizontal, 40)
            .disabled(username.trimmingCharacters(in: .whitespaces).isEmpty || isLoading)

            if isLoading { ProgressView() }
            if let error = viewModel.errorMessage {
                Text(error).foregroundStyle(.red).font(.caption)
            }
            Spacer()
        }
    }
}
