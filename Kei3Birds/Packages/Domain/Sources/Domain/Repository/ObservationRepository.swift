public protocol ObservationRepository: Sendable {
    func fetchAll(speciesId: Int?) async throws -> [Observation]
    func fetch(id: String) async throws -> Observation
    func create(_ input: CreateObservationInput) async throws -> Observation
    func delete(id: String) async throws
}
