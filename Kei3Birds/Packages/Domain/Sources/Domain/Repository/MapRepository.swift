public protocol MapRepository: Sendable {
    func fetchGBIFPoints(lat: Double, lng: Double, radiusKm: Int, speciesId: Int?, season: String?) async throws -> [GBIFMapPoint]
    func fetchMyPoints() async throws -> [MyMapPoint]
}
