import Foundation
import Domain
import UseCase

struct EncyclopediaEntry: Identifiable {
    let nameJa: String
    let scientificName: String?
    let speciesId: Int?
    let aiSpeciesId: Int?
    let photoUrl: String

    /// グルーピング・識別キー: species_id → ai_species_id → name_ja の優先順
    var id: String {
        if let speciesId { return "species_\(speciesId)" }
        if let aiSpeciesId { return "ai_\(aiSpeciesId)" }
        return "name_\(nameJa)"
    }
}

@Observable
@MainActor
final class EncyclopediaViewModel {
    let fetchBirdsUseCase: FetchBirdsUseCase
    let fetchObservationsUseCase: FetchObservationsUseCase

    var allBirds: [Bird] = []
    var observations: [BirdObservation] = []
    var searchText = ""
    var isLoading = false
    private var hasLoaded = false
    var errorMessage: String?

    init(fetchBirdsUseCase: FetchBirdsUseCase, fetchObservationsUseCase: FetchObservationsUseCase) {
        self.fetchBirdsUseCase = fetchBirdsUseCase
        self.fetchObservationsUseCase = fetchObservationsUseCase
    }

    // MARK: - 図鑑タブ用（observationsベース）

    /// observations からユニークな鳥エントリを生成
    /// species_id があれば species_id で、なければ name_ja でグルーピング
    var encyclopediaEntries: [EncyclopediaEntry] {
        var seen = Set<String>()
        var entries: [EncyclopediaEntry] = []
        for obs in observations {
            guard let nameJa = obs.nameJa, !nameJa.isEmpty else { continue }
            let entry = EncyclopediaEntry(
                nameJa: nameJa,
                scientificName: obs.scientificName,
                speciesId: obs.speciesId,
                aiSpeciesId: obs.aiSpeciesId,
                photoUrl: obs.photoUrl
            )
            if seen.contains(entry.id) { continue }
            seen.insert(entry.id)
            entries.append(entry)
        }
        return entries
    }

    var filteredEncyclopediaEntries: [EncyclopediaEntry] {
        if searchText.isEmpty { return encyclopediaEntries }
        return encyclopediaEntries.filter {
            $0.nameJa.contains(searchText)
            || ($0.scientificName?.localizedCaseInsensitiveContains(searchText) ?? false)
        }
    }

    // MARK: - 図鑑進捗用（bird_speciesベース）

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

    // MARK: - データ読み込み

    func loadDataIfNeeded() async {
        guard !hasLoaded else { return }
        await loadData()
    }

    func loadData() async {
        isLoading = true
        errorMessage = nil
        do {
            async let birds = fetchBirdsUseCase.execute()
            async let obs = fetchObservationsUseCase.execute()
            allBirds = try await birds
            observations = try await obs
            hasLoaded = true
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
