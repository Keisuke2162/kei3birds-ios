import Foundation

public protocol UploadRepository: Sendable {
    func uploadPhoto(imageData: Data, fileExtension: String) async throws -> String
    func identifyBird(imageData: Data, fileExtension: String) async throws -> IdentifyResult
}
