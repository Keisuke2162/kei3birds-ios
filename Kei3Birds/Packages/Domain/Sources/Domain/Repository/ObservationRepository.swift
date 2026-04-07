public protocol ObservationRepository: Sendable {
    func fetchAll(speciesId: Int?) async throws -> [BirdObservation]
    func fetch(id: String) async throws -> BirdObservation
    func create(_ input: CreateObservationInput) async throws -> BirdObservation
    func delete(id: String) async throws
}
