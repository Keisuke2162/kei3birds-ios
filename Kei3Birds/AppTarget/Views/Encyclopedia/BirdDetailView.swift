import SwiftUI
import CoreLocation
import Domain

struct BirdDetailView: View {
    let speciesId: Int?
    let nameJa: String
    @State var viewModel: BirdDetailViewModel
    let username: String
    @State private var selectedObservation: BirdObservation?
    @Environment(\.dismiss) private var dismiss

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 3)

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // bird_species の情報（species_id がある場合のみ）
                if let bird = viewModel.bird {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(bird.nameJa).font(.largeTitle.bold())
                        Text(bird.scientificName)
                            .font(.subheadline).italic()
                            .foregroundStyle(.secondary)
                        HStack(spacing: 16) {
                            Label(bird.orderName, systemImage: "leaf")
                            Label(bird.family, systemImage: "bird")
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal)
                } else if speciesId == nil {
                    // ai_species のみの鳥（bird_species 情報なし）
                    VStack(alignment: .leading, spacing: 8) {
                        Text(nameJa).font(.largeTitle.bold())
                    }
                    .padding(.horizontal)
                }

                Divider()

                if viewModel.observations.isEmpty {
                    Text("まだ撮影記録がありません")
                        .foregroundStyle(.secondary).padding()
                } else {
                    Text("撮影記録（\(viewModel.observations.count)件）")
                        .font(.headline).padding(.horizontal)

                    LazyVGrid(columns: columns, spacing: 4) {
                        ForEach(viewModel.observations) { obs in
                            AsyncImage(url: URL(string: obs.photoUrl)) { image in
                                image.resizable().scaledToFill()
                            } placeholder: {
                                Color.gray.opacity(0.3)
                            }
                            .frame(height: 120)
                            .clipped()
                            .onTapGesture { selectedObservation = obs }
                        }
                    }
                    .padding(.horizontal, 4)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .overlay { if viewModel.isLoading { LoadingView() } }
        .task {
            if let speciesId {
                await viewModel.loadData(speciesId: speciesId)
            } else {
                await viewModel.loadObservationsOnly(nameJa: nameJa)
            }
        }
        .onChange(of: viewModel.didDeleteAll) { _, didDeleteAll in
            if didDeleteAll { dismiss() }
        }
        .sheet(item: $selectedObservation) { obs in
            ObservationDetailSheet(
                observation: obs,
                birdName: nameJa,
                username: username,
                onDelete: {
                    selectedObservation = nil
                    Task { await viewModel.deleteObservation(obs) }
                }
            )
            .presentationDetents([.large])
        }
    }
}

private struct ObservationDetailSheet: View {
    let observation: BirdObservation
    let birdName: String
    let username: String
    let onDelete: () -> Void
    @State private var locationName: String?
    @State private var showDeleteConfirmation = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    AsyncImage(url: URL(string: observation.photoUrl)) { image in
                        image.resizable().scaledToFit()
                    } placeholder: { ProgressView() }
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    Text("撮影日: \(observation.takenAt)")
                    if let loc = locationName, !loc.isEmpty { Text("場所: \(loc)") }
                    if let notes = observation.notes, !notes.isEmpty { Text("メモ: \(notes)") }

                    NavigationLink("フォトカードを作る") {
                        PhotoCardView(
                            viewModel: PhotoCardViewModel(
                                photoUrl: observation.photoUrl,
                                birdName: birdName,
                                scientificName: nil,
                                takenAt: observation.takenAt,
                                locationName: observation.locationName,
                                username: username
                            )
                        )
                    }
                    .buttonStyle(.borderedProminent)

                    Button(role: .destructive) {
                        showDeleteConfirmation = true
                    } label: {
                        Label("この写真を削除", systemImage: "trash")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .padding(.top, 8)
                }
                .padding()
            }
            .navigationTitle(birdName)
            .navigationBarTitleDisplayMode(.inline)
            .task {
                // DB に保存済みの locationName があればそれを使う
                if let loc = observation.locationName, !loc.isEmpty {
                    locationName = loc
                } else if let lat = observation.lat, let lng = observation.lng, lat != 0, lng != 0 {
                    // 座標から逆ジオコーディング
                    let location = CLLocation(latitude: lat, longitude: lng)
                    let geocoder = CLGeocoder()
                    if let placemarks = try? await geocoder.reverseGeocodeLocation(location),
                       let placemark = placemarks.first {
                        let components = [placemark.administrativeArea, placemark.locality, placemark.subLocality]
                        let name = components.compactMap { $0 }.joined()
                        if !name.isEmpty {
                            locationName = name
                        }
                    }
                }
            }
            .confirmationDialog("この写真を削除しますか？", isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
                Button("削除", role: .destructive) {
                    onDelete()
                }
                Button("キャンセル", role: .cancel) {}
            } message: {
                Text("この操作は取り消せません。写真がなくなると図鑑からも削除されます。")
            }
        }
    }
}
