import Foundation
import Domain

public final class DeleteObservationUseCase: Sendable {
    private let repository: ObservationRepository

    public init(repository: ObservationRepository) {
        self.repository = repository
    }

    public func execute(id: String) async throws {
        try await repository.delete(id: id)
    }
}
