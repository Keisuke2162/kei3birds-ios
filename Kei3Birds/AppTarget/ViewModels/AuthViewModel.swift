import Foundation
import Domain
import UseCase

@Observable
@MainActor
final class AuthViewModel {
    private let authUseCase: AuthUseCase

    var currentUser: AppUser?
    var isAuthenticated = false
    var isLoading = true
    var needsUsername = false
    var userId: String?
    var errorMessage: String?

    init(authUseCase: AuthUseCase) {
        self.authUseCase = authUseCase
    }

    func restoreSession() async {
        defer { isLoading = false }
        do {
            let user = try await authUseCase.restoreSession()
            userId = await authUseCase.getUserId()
            isAuthenticated = true
            if let user {
                currentUser = user
            } else {
                needsUsername = true
            }
        } catch {
            isAuthenticated = false
        }
    }

    func signInWithGoogle(idToken: String, accessToken: String) async {
        errorMessage = nil
        do {
            let user = try await authUseCase.signInWithGoogle(idToken: idToken, accessToken: accessToken)
            isAuthenticated = true
            // セッションからuserIdを取得（setUsernameで必要）
            userId = await authUseCase.getUserId()
            if let user {
                currentUser = user
            } else {
                needsUsername = true
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func setUsername(_ username: String) async {
        guard let userId else { return }
        errorMessage = nil
        do {
            let user = try await authUseCase.setUsername(username, userId: userId)
            currentUser = user
            needsUsername = false
        } catch {
            errorMessage = "登録に失敗しました: \(error.localizedDescription)"
        }
    }

    func signOut() async {
        try? await authUseCase.signOut()
        currentUser = nil
        isAuthenticated = false
        needsUsername = false
        userId = nil
    }
}
