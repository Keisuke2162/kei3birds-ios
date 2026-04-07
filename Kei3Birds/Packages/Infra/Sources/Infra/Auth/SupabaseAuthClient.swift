import Foundation
import Domain
import Supabase
import Auth

public final class SupabaseAuthClient: AuthRepository {
    private let client: SupabaseClient

    public init(supabaseURL: URL, supabaseKey: String) {
        self.client = SupabaseClient(supabaseURL: supabaseURL, supabaseKey: supabaseKey)
    }

    public func restoreSession() async throws -> AppUser? {
        let session = try await client.auth.session
        return await fetchUserProfile(userId: session.user.id.uuidString)
    }

    public func signInWithGoogle(idToken: String, accessToken: String) async throws -> AppUser? {
        let session = try await client.auth.signInWithIdToken(
            credentials: .init(provider: .google, idToken: idToken, accessToken: accessToken)
        )
        return await fetchUserProfile(userId: session.user.id.uuidString)
    }

    public func setUsername(_ username: String, userId: String) async throws -> AppUser {
        try await client.from("users")
            .insert(["id": userId, "username": username])
            .execute()
        return AppUser(id: userId, username: username)
    }

    public func signOut() async throws {
        try await client.auth.signOut()
    }

    public func getAccessToken() async -> String? {
        try? await client.auth.session.accessToken
    }

    private func fetchUserProfile(userId: String) async -> AppUser? {
        struct UserRow: Decodable {
            let id: String
            let username: String
        }
        guard let rows: [UserRow] = try? await client.from("users")
            .select()
            .eq("id", value: userId)
            .execute()
            .value,
              let row = rows.first else {
            return nil
        }
        return AppUser(id: row.id, username: row.username)
    }
}
