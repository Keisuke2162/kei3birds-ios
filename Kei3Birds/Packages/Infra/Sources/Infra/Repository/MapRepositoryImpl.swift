import Foundation
import Domain

public final class MapRepositoryImpl: MapRepository {
    private let apiClient: APIClient
    private let tokenProvider: @Sendable () async -> String?

    public init(apiClient: APIClient, tokenProvider: @escaping @Sendable () async -> String?) {
        self.apiClient = apiClient
        self.tokenProvider = tokenProvider
    }

    public func fetchGBIFPoints(lat: Double, lng: Double, radiusKm: Int, speciesId: Int?, season: String?) async throws -> [GBIFMapPoint] {
        let dtos: [GBIFMapPointDTO] = try await apiClient.request(
            MapEndpoint.gbif(lat: lat, lng: lng, radiusKm: radiusKm, speciesId: speciesId, season: season)
        )
        return dtos.map { $0.toDomain() }
    }

    public func fetchMyPoints() async throws -> [MyMapPoint] {
        let token = await tokenProvider()
        let dtos: [MyMapPointDTO] = try await apiClient.request(
            MapEndpoint.my,
            accessToken: token
        )
        return dtos.map { $0.toDomain() }
    }
}
