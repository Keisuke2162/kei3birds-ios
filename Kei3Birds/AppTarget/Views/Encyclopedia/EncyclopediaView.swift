import SwiftUI
import Domain

struct EncyclopediaView: View {
    @State var viewModel: EncyclopediaViewModel
    let container: DependencyContainer

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 2)

    var body: some View {
        NavigationStack {
            Group {
                if !viewModel.isLoading && viewModel.encyclopediaEntries.isEmpty {
                    ContentUnavailableView(
                        "まだ図鑑に登録がありません",
                        systemImage: "book.closed",
                        description: Text("鳥を撮影すると図鑑に登録されます")
                    )
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(viewModel.filteredEncyclopediaEntries) { entry in
                                if let speciesId = entry.speciesId {
                                    NavigationLink {
                                        BirdDetailView(
                                            speciesId: speciesId,
                                            viewModel: BirdDetailViewModel(
                                                fetchBirdsUseCase: container.fetchBirdsUseCase,
                                                fetchObservationsUseCase: container.fetchObservationsUseCase,
                                                deleteObservationUseCase: container.deleteObservationUseCase
                                            ),
                                            username: ""
                                        )
                                    } label: {
                                        EncyclopediaCardView(entry: entry)
                                    }
                                } else {
                                    EncyclopediaCardView(entry: entry)
                                }
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.top, 8)
                    }
                }
            }
            .navigationTitle("図鑑")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $viewModel.searchText, prompt: "名前で検索")
            .refreshable { await viewModel.loadData() }
            .overlay {
                if viewModel.isLoading { LoadingView() }
            }
            .task { await viewModel.loadDataIfNeeded() }
        }
    }
}

private struct EncyclopediaCardView: View {
    let entry: EncyclopediaEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let url = URL(string: entry.photoUrl) {
                CachedAsyncImage(url: url)
                    .frame(height: 150)
                    .frame(maxWidth: .infinity)
                    .clipShape(UnevenRoundedRectangle(topLeadingRadius: 10, topTrailingRadius: 10))
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(entry.nameJa)
                    .font(.subheadline.bold())
                    .foregroundStyle(.primary)
                if let scientificName = entry.scientificName {
                    Text(scientificName)
                        .font(.caption2)
                        .italic()
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
        }
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(color: .black.opacity(0.08), radius: 4, y: 2)
    }
}
