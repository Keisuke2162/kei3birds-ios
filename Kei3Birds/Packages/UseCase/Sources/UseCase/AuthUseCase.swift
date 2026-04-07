import Domain

public final class AuthUseCase: Sendable {
    private let repository: AuthRepository

    public init(repository: AuthRepository) {
        self.repository = repository
    }

    public func restoreSession() async throws -> AppUser? {
        try await repository.restoreSession()
    }

    public func signInWithGoogle(idToken: String, accessToken: String) async throws -> AppUser? {
        try await repository.signInWithGoogle(idToken: idToken, accessToken: accessToken)
    }

    public func setUsername(_ username: String, userId: String) async throws -> AppUser {
        try await repository.setUsername(username, userId: userId)
    }

    public func signOut() async throws {
        try await repository.signOut()
    }
}
