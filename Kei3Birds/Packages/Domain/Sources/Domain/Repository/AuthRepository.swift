public protocol AuthRepository: Sendable {
    func restoreSession() async throws -> AppUser?
    func signInWithGoogle(idToken: String, accessToken: String) async throws -> AppUser?
    func setUsername(_ username: String, userId: String) async throws -> AppUser
    func signOut() async throws
    func getAccessToken() async -> String?
}
