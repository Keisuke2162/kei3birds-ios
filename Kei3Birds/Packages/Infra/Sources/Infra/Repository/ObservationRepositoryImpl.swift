import Foundation
import Domain

public final class ObservationRepositoryImpl: ObservationRepository {
    private let apiClient: APIClient
    private let tokenProvider: () async -> String?

    public init(apiClient: APIClient, tokenProvider: @escaping @Sendable () async -> String?) {
        self.apiClient = apiClient
        self.tokenProvider = tokenProvider
    }

    public func fetchAll(speciesId: Int?) async throws -> [Observation] {
        let token = await tokenProvider()
        let dtos: [ObservationDTO] = try await apiClient.request(
            ObservationEndpoint.fetchAll(speciesId: speciesId),
            accessToken: token
        )
        return dtos.map { $0.toDomain() }
    }

    public func fetch(id: String) async throws -> Observation {
        let token = await tokenProvider()
        let dto: ObservationDTO = try await apiClient.request(
            ObservationEndpoint.fetch(id: id),
            accessToken: token
        )
        return dto.toDomain()
    }

    public func create(_ input: CreateObservationInput) async throws -> Observation {
        let token = await tokenProvider()
        let requestDTO = CreateObservationRequestDTO(from: input)
        let body = try JSONEncoder().encode(requestDTO)
        let dto: ObservationDTO = try await apiClient.request(
            ObservationEndpoint.create(body: body),
            accessToken: token
        )
        return dto.toDomain()
    }

    public func delete(id: String) async throws {
        let token = await tokenProvider()
        try await apiClient.requestVoid(
            ObservationEndpoint.delete(id: id),
            accessToken: token
        )
    }
}
