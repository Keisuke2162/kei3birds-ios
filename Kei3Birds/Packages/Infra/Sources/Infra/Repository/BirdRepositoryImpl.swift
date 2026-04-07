import Foundation
import Domain

public final class BirdRepositoryImpl: BirdRepository {
    private let apiClient: APIClient
    private let tokenProvider: @Sendable () async -> String?

    public init(apiClient: APIClient, tokenProvider: @escaping @Sendable () async -> String?) {
        self.apiClient = apiClient
        self.tokenProvider = tokenProvider
    }

    public func fetchAll(search: String?) async throws -> [Bird] {
        let dtos: [BirdDTO] = try await apiClient.request(BirdEndpoint.fetchAll(search: search))
        return dtos.map { $0.toDomain() }
    }

    public func fetch(id: Int) async throws -> Bird {
        let dto: BirdDTO = try await apiClient.request(BirdEndpoint.fetch(id: id))
        return dto.toDomain()
    }
}
