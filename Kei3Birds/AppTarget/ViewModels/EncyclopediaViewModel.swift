import Foundation
import Domain
import UseCase

@Observable
@MainActor
final class EncyclopediaViewModel {
    private let fetchBirdsUseCase: FetchBirdsUseCase
    private let fetchObservationsUseCase: FetchObservationsUseCase

    var allBirds: [Bird] = []
    var observations: [BirdObservation] = []
    var searchText = ""
    var isLoading = false
    var errorMessage: String?

    init(fetchBirdsUseCase: FetchBirdsUseCase, fetchObservationsUseCase: FetchObservationsUseCase) {
        self.fetchBirdsUseCase = fetchBirdsUseCase
        self.fetchObservationsUseCase = fetchObservationsUseCase
    }

    var filteredBirds: [Bird] {
        if searchText.isEmpty { return allBirds }
        return allBirds.filter { $0.nameJa.contains(searchText) || $0.nameEn.localizedCaseInsensitiveContains(searchText) }
    }

    var capturedSpeciesIds: Set<Int> {
        Set(observations.compactMap { $0.speciesId })
    }

    var capturedCount: Int { capturedSpeciesIds.count }

    func photoURL(for speciesId: Int) -> String? {
        observations.first { $0.speciesId == speciesId }?.photoUrl
    }

    func loadData() async {
        isLoading = true
        errorMessage = nil
        do {
            async let birds = fetchBirdsUseCase.execute()
            async let obs = fetchObservationsUseCase.execute()
            allBirds = try await birds
            observations = try await obs
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
