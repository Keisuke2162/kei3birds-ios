import Domain

public final class FetchBirdsUseCase: Sendable {
    private let repository: BirdRepository

    public init(repository: BirdRepository) {
        self.repository = repository
    }

    public func execute(search: String? = nil) async throws -> [Bird] {
        try await repository.fetchAll(search: search)
    }

    public func execute(id: Int) async throws -> Bird {
        try await repository.fetch(id: id)
    }
}
