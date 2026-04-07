import Foundation
import Domain

public final class CreateObservationUseCase: Sendable {
    private let observationRepository: ObservationRepository
    private let uploadRepository: UploadRepository

    public init(observationRepository: ObservationRepository, uploadRepository: UploadRepository) {
        self.observationRepository = observationRepository
        self.uploadRepository = uploadRepository
    }

    public func execute(imageData: Data, input: CreateObservationInput) async throws -> BirdObservation {
        let photoUrl = try await uploadRepository.uploadPhoto(imageData: imageData, fileExtension: "jpg")
        let finalInput = CreateObservationInput(
            speciesId: input.speciesId,
            photoUrl: photoUrl,
            takenAt: input.takenAt,
            lat: input.lat,
            lng: input.lng,
            locationName: input.locationName,
            notes: input.notes
        )
        return try await observationRepository.create(finalInput)
    }
}
