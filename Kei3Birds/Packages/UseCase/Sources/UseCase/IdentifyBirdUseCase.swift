import Foundation
import Domain

public final class IdentifyBirdUseCase: Sendable {
    private let repository: UploadRepository

    public init(repository: UploadRepository) {
        self.repository = repository
    }

    public func execute(imageData: Data) async throws -> IdentifyResult {
        try await repository.identifyBird(imageData: imageData, fileExtension: "jpg")
    }
}
