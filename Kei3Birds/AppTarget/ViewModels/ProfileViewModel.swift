import Foundation
import Domain
import UseCase

@Observable
@MainActor
final class ProfileViewModel {
    private let fetchBirdsUseCase: FetchBirdsUseCase
    private let fetchObservationsUseCase: FetchObservationsUseCase
    private let authUseCase: AuthUseCase

    var observations: [BirdObservation] = []
    var totalSpecies = 0
    var isLoading = false
    var username: String

    init(fetchBirdsUseCase: FetchBirdsUseCase, fetchObservationsUseCase: FetchObservationsUseCase, authUseCase: AuthUseCase, username: String) {
        self.fetchBirdsUseCase = fetchBirdsUseCase
        self.fetchObservationsUseCase = fetchObservationsUseCase
        self.authUseCase = authUseCase
        self.username = username
    }

    var capturedCount: Int {
        Set(observations.compactMap { $0.speciesId }).count
    }

    var completionRate: Double {
        guard totalSpecies > 0 else { return 0 }
        return Double(capturedCount) / Double(totalSpecies)
    }

    func loadData() async {
        isLoading = true
        do {
            async let obs = fetchObservationsUseCase.execute()
            async let birds = fetchBirdsUseCase.execute()
            observations = try await obs
            totalSpecies = try await birds.count
        } catch {}
        isLoading = false
    }

    func signOut() async {
        try? await authUseCase.signOut()
    }
}
