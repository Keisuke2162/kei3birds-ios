import SwiftUI
import PhotosUI
import Domain

struct CameraView: View {
    @State var viewModel: IdentifyViewModel
    var onRegistrationComplete: (() -> Void)?
    @State private var showCamera = false
    @State private var showPhotoPicker = false
    @State private var selectedPhotoItem: PhotosPickerItem?

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                switch viewModel.state {
                case .idle:
                    idleView
                case .loading:
                    LoadingView(message: "AI判定中...")
                case .result:
                    resultView
                case .confirm:
                    confirmView
                case .error(let message):
                    errorView(message)
                }
            }
            .padding()
            .navigationTitle("撮影")
            .navigationBarTitleDisplayMode(.inline)
            .fullScreenCover(isPresented: $showCamera) {
                ImagePickerView(sourceType: .camera) { image in
                    Task { await viewModel.identifyBird(image: image) }
                }
            }
            .alert("登録完了", isPresented: $viewModel.showRegistrationSuccess) {
                Button("OK") {
                    onRegistrationComplete?()
                }
            } message: {
                Text("「\(viewModel.registeredBirdName)」を図鑑に登録しました")
            }
            .photosPicker(isPresented: $showPhotoPicker, selection: $selectedPhotoItem, matching: .images)
            .onChange(of: selectedPhotoItem) {
                guard let item = selectedPhotoItem else { return }
                Task {
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        await viewModel.identifyBird(image: image)
                    }
                }
            }
        }
    }

    private var idleView: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "camera.viewfinder")
                .font(.system(size: 80))
                .foregroundStyle(.secondary)
            Text("鳥の写真を撮影・選択して\nAIで種類を判定します")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            Button { showCamera = true } label: {
                Label("カメラで撮影", systemImage: "camera.fill").frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent).controlSize(.large)
            Button { showPhotoPicker = true } label: {
                Label("ライブラリから選択", systemImage: "photo.on.rectangle").frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered).controlSize(.large)
            Spacer()
        }
    }

    private var resultView: some View {
        VStack(spacing: 16) {
            if let image = viewModel.selectedImage {
                Image(uiImage: image).resizable().scaledToFit()
                    .frame(maxHeight: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            if let result = viewModel.identifyResult {
                if result.identified {
                    Text("判定結果").font(.headline)
                    ForEach(result.candidates) { candidate in
                        Button { viewModel.selectCandidate(candidate) } label: {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(candidate.nameJa).font(.headline)
                                    Text(candidate.scientificName).font(.caption).italic().foregroundStyle(.secondary)
                                }
                                Spacer()
                                Text("\(Int(candidate.confidence * 100))%")
                                    .font(.title3.bold())
                                    .foregroundStyle(candidate.confidence > 0.7 ? .green : .orange)
                            }
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        .tint(.primary)
                    }
                } else {
                    Text("判定できませんでした").font(.headline).foregroundStyle(.orange)
                    Text("手動で種類を選択してください").foregroundStyle(.secondary)
                }
            }
            Button("やり直す") { viewModel.reset() }.buttonStyle(.bordered)
        }
    }

    private var confirmView: some View {
        VStack(spacing: 16) {
            if let candidate = viewModel.selectedCandidate {
                Text("「\(candidate.nameJa)」で登録します").font(.headline)
            }
            if let image = viewModel.selectedImage {
                Image(uiImage: image).resizable().scaledToFit()
                    .frame(maxHeight: 160)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            TextField("メモ（任意）", text: $viewModel.notes, axis: .vertical)
                .textFieldStyle(.roundedBorder).lineLimit(3)
            if viewModel.isRegistering {
                ProgressView("登録中...")
            } else {
                Button { Task { await viewModel.registerObservation() } } label: {
                    Text("この鳥で記録する").frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent).controlSize(.large)
                Button("戻る") { viewModel.state = .result }.buttonStyle(.bordered)
            }
        }
    }

    private func errorView(_ message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle").font(.largeTitle).foregroundStyle(.orange)
            Text(message).foregroundStyle(.secondary)
            Button("やり直す") { viewModel.reset() }.buttonStyle(.borderedProminent)
        }
    }
}
