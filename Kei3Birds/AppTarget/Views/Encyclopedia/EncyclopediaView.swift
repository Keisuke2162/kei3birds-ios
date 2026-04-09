import SwiftUI
import Domain

struct EncyclopediaView: View {
    @State var viewModel: EncyclopediaViewModel
    let container: DependencyContainer

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 2)

    var body: some View {
        NavigationStack {
            Group {
                if !viewModel.isLoading && viewModel.capturedBirds.isEmpty {
                    ContentUnavailableView(
                        "まだ図鑑に登録がありません",
                        systemImage: "book.closed",
                        description: Text("鳥を撮影すると図鑑に登録されます")
                    )
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(viewModel.filteredCapturedBirds) { bird in
                                NavigationLink {
                                    BirdDetailView(
                                        speciesId: bird.id,
                                        viewModel: BirdDetailViewModel(
                                            fetchBirdsUseCase: container.fetchBirdsUseCase,
                                            fetchObservationsUseCase: container.fetchObservationsUseCase
                                        ),
                                        username: ""
                                    )
                                } label: {
                                    EncyclopediaCardView(
                                        bird: bird,
                                        photoURL: viewModel.photoURL(for: bird.id)
                                    )
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
            .overlay {
                if viewModel.isLoading { LoadingView() }
            }
            .task { await viewModel.loadData() }
        }
    }
}

private struct EncyclopediaCardView: View {
    let bird: Bird
    let photoURL: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let urlString = photoURL, let url = URL(string: urlString) {
                CachedAsyncImage(url: url)
                    .frame(height: 150)
                    .frame(maxWidth: .infinity)
                    .clipShape(UnevenRoundedRectangle(topLeadingRadius: 10, topTrailingRadius: 10))
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(bird.nameJa)
                    .font(.subheadline.bold())
                    .foregroundStyle(.primary)
                Text(bird.scientificName)
                    .font(.caption2)
                    .italic()
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
        }
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(color: .black.opacity(0.08), radius: 4, y: 2)
    }
}
