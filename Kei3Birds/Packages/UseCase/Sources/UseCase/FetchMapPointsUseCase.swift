import Domain

public final class FetchMapPointsUseCase: Sendable {
    private let repository: MapRepository

    public init(repository: MapRepository) {
        self.repository = repository
    }

    public func executeGBIF(lat: Double, lng: Double, radiusKm: Int = 50, speciesId: Int? = nil, season: String? = nil) async throws -> [GBIFMapPoint] {
        try await repository.fetchGBIFPoints(lat: lat, lng: lng, radiusKm: radiusKm, speciesId: speciesId, season: season)
    }

    public func executeMy() async throws -> [MyMapPoint] {
        try await repository.fetchMyPoints()
    }
}
