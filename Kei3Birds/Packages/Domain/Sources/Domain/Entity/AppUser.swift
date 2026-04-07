import Foundation

public struct AppUser: Sendable, Identifiable {
    public let id: String
    public let username: String

    public init(id: String, username: String) {
        self.id = id
        self.username = username
    }
}
