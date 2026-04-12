import Foundation
import Domain
import UseCase

@Observable
@MainActor
final class BirdDetailViewModel {
    private let fetchBirdsUseCase: FetchBirdsUseCase
    private let fetchObservationsUseCase: FetchObservationsUseCase
    private let deleteObservationUseCase: DeleteObservationUseCase

    var bird: Bird?
    var observations: [BirdObservation] = []
    var isLoading = false
    var errorMessage: String?
    var isDeleting = false
    var didDeleteAll = false

    init(fetchBirdsUseCase: FetchBirdsUseCase, fetchObservationsUseCase: FetchObservationsUseCase, deleteObservationUseCase: DeleteObservationUseCase) {
        self.fetchBirdsUseCase = fetchBirdsUseCase
        self.fetchObservationsUseCase = fetchObservationsUseCase
        self.deleteObservationUseCase = deleteObservationUseCase
    }

    func loadData(speciesId: Int) async {
        isLoading = true
        errorMessage = nil
        do {
            async let birdResult = fetchBirdsUseCase.execute(id: speciesId)
            async let obsResult = fetchObservationsUseCase.execute(speciesId: speciesId)
            bird = try await birdResult
            observations = try await obsResult
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func loadObservationsOnly(nameJa: String) async {
        isLoading = true
        errorMessage = nil
        do {
            let allObs = try await fetchObservationsUseCase.execute()
            observations = allObs.filter { $0.nameJa == nameJa }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func deleteObservation(_ observation: BirdObservation) async {
        isDeleting = true
        do {
            try await deleteObservationUseCase.execute(id: observation.id)
            observations.removeAll { $0.id == observation.id }
            if observations.isEmpty {
                didDeleteAll = true
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isDeleting = false
    }
}
