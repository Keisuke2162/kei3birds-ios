import Foundation
import Domain
import UseCase

@Observable
@MainActor
final class BirdDetailViewModel {
    private let fetchBirdsUseCase: FetchBirdsUseCase
    private let fetchObservationsUseCase: FetchObservationsUseCase

    var bird: Bird?
    var observations: [BirdObservation] = []
    var isLoading = false
    var errorMessage: String?

    init(fetchBirdsUseCase: FetchBirdsUseCase, fetchObservationsUseCase: FetchObservationsUseCase) {
        self.fetchBirdsUseCase = fetchBirdsUseCase
        self.fetchObservationsUseCase = fetchObservationsUseCase
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
}
