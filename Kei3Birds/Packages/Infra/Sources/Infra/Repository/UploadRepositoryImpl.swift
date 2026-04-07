import Foundation
import Domain

public final class UploadRepositoryImpl: UploadRepository {
    private let apiClient: APIClient
    private let tokenProvider: @Sendable () async -> String?

    public init(apiClient: APIClient, tokenProvider: @escaping @Sendable () async -> String?) {
        self.apiClient = apiClient
        self.tokenProvider = tokenProvider
    }

    public func uploadPhoto(imageData: Data, fileExtension: String) async throws -> String {
        let token = await tokenProvider()
        let dto: UploadResponseDTO = try await apiClient.upload(
            UploadEndpoint.photo,
            imageData: imageData,
            filename: "photo.\(fileExtension)",
            accessToken: token
        )
        return dto.url
    }

    public func identifyBird(imageData: Data, fileExtension: String) async throws -> IdentifyResult {
        let token = await tokenProvider()
        let dto: IdentifyResponseDTO = try await apiClient.upload(
            UploadEndpoint.identify,
            imageData: imageData,
            filename: "photo.\(fileExtension)",
            accessToken: token
        )
        return dto.toDomain()
    }
}
