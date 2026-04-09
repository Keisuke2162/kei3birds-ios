import Foundation
import UIKit
import Domain
import UseCase

enum IdentifyState {
    case idle
    case loading
    case result
    case confirm
    case error(String)
}

@Observable
@MainActor
final class IdentifyViewModel {
    private let identifyBirdUseCase: IdentifyBirdUseCase
    private let createObservationUseCase: CreateObservationUseCase

    var state: IdentifyState = .idle
    var selectedImage: UIImage?
    var identifyResult: IdentifyResult?
    var selectedCandidate: AICandidate?
    var notes = ""
    var isRegistering = false

    init(identifyBirdUseCase: IdentifyBirdUseCase, createObservationUseCase: CreateObservationUseCase) {
        self.identifyBirdUseCase = identifyBirdUseCase
        self.createObservationUseCase = createObservationUseCase
    }

    func identifyBird(image: UIImage) async {
        selectedImage = image
        state = .loading

        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            state = .error("画像の変換に失敗しました")
            return
        }

        do {
            identifyResult = try await identifyBirdUseCase.execute(imageData: imageData)
            state = .result
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    func selectCandidate(_ candidate: AICandidate) {
        selectedCandidate = candidate
        state = .confirm
    }

    func registerObservation() async {
        guard let candidate = selectedCandidate,
              let image = selectedImage,
              let imageData = image.jpegData(compressionQuality: 0.8) else { return }

        isRegistering = true
        defer { isRegistering = false }

        do {
            let exif = EXIFHelper.extractMetadata(from: image)
            let input = CreateObservationInput(
                speciesId: candidate.speciesId,
                aiSpeciesId: candidate.aiSpeciesId,
                nameJa: candidate.nameJa,
                scientificName: candidate.scientificName,
                photoUrl: "",
                takenAt: exif.takenAt ?? ISO8601DateFormatter().string(from: Date()),
                lat: exif.latitude ?? 0,
                lng: exif.longitude ?? 0,
                locationName: exif.locationName ?? "",
                notes: notes.isEmpty ? nil : notes
            )
            _ = try await createObservationUseCase.execute(imageData: imageData, input: input)
            reset()
        } catch {
            state = .error("登録に失敗しました: \(error.localizedDescription)")
        }
    }

    func reset() {
        state = .idle
        selectedImage = nil
        identifyResult = nil
        selectedCandidate = nil
        notes = ""
    }
}
