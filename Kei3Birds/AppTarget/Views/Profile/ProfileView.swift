import SwiftUI

struct ProfileView: View {
    @State var viewModel: ProfileViewModel
    let authViewModel: AuthViewModel

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 60)).foregroundStyle(.secondary)
                        VStack(alignment: .leading) {
                            Text(viewModel.username).font(.title2.bold())
                        }
                    }
                    .padding(.vertical, 8)
                }

                Section("図鑑達成率") {
                    VStack(alignment: .leading, spacing: 8) {
                        ProgressView(value: viewModel.completionRate).tint(.green)
                        Text("\(viewModel.capturedCount) / \(viewModel.totalSpecies)種 （\(Int(viewModel.completionRate * 100))%）")
                            .font(.caption).foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }

                Section("統計") {
                    LabeledContent("総撮影数", value: "\(viewModel.observations.count)枚")
                    LabeledContent("撮影済み種数", value: "\(viewModel.capturedCount)種")
                }

                Section {
                    Button("ログアウト", role: .destructive) {
                        Task { await authViewModel.signOut() }
                    }
                }
            }
            .navigationTitle("プロフィール")
            .navigationBarTitleDisplayMode(.inline)
            .overlay { if viewModel.isLoading { LoadingView() } }
            .task { await viewModel.loadData() }
        }
    }
}
