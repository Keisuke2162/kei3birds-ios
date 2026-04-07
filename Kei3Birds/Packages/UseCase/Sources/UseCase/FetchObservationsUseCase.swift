import Domain

public final class FetchObservationsUseCase: Sendable {
    private let repository: ObservationRepository

    public init(repository: ObservationRepository) {
        self.repository = repository
    }

    public func execute(speciesId: Int? = nil) async throws -> [Observation] {
        try await repository.fetchAll(speciesId: speciesId)
    }

    public func execute(id: String) async throws -> Observation {
        try await repository.fetch(id: id)
    }
}
