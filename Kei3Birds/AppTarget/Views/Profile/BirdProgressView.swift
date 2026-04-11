import SwiftUI
import Domain

struct BirdProgressView: View {
    @State var viewModel: EncyclopediaViewModel
    let container: DependencyContainer

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 3)

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("\(viewModel.capturedCount) / \(viewModel.allBirds.count)種")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.vertical, 8)

            ScrollView {
                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(viewModel.filteredBirds) { bird in
                        NavigationLink {
                            BirdDetailView(
                                speciesId: bird.id,
                                viewModel: BirdDetailViewModel(
                                    fetchBirdsUseCase: container.fetchBirdsUseCase,
                                    fetchObservationsUseCase: container.fetchObservationsUseCase,
                                    deleteObservationUseCase: container.deleteObservationUseCase
                                ),
                                username: ""
                            )
                        } label: {
                            BirdCardView(
                                name: bird.nameJa,
                                photoURL: viewModel.photoURL(for: bird.id),
                                isCaptured: viewModel.capturedSpeciesIds.contains(bird.id)
                            )
                        }
                    }
                }
                .padding(.horizontal, 8)
            }
        }
        .navigationTitle("図鑑進捗")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $viewModel.searchText, prompt: "名前で検索")
        .overlay {
            if viewModel.isLoading { LoadingView() }
        }
        .task { await viewModel.loadData() }
    }
}
