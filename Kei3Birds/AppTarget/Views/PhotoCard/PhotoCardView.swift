import SwiftUI

struct PhotoCardView: View {
    @State var viewModel: PhotoCardViewModel
    @State private var renderedImage: UIImage?
    @State private var showShareSheet = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("テンプレート").font(.headline).frame(maxWidth: .infinity, alignment: .leading)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(CardTemplate.allCases) { template in
                            Button {
                                viewModel.selectedTemplate = template
                            } label: {
                                Text(template.rawValue)
                                    .padding(.horizontal, 20).padding(.vertical, 10)
                                    .background(viewModel.selectedTemplate == template ? Color.accentColor : Color(.secondarySystemBackground))
                                    .foregroundStyle(viewModel.selectedTemplate == template ? .white : .primary)
                                    .clipShape(Capsule())
                            }
                        }
                    }
                }

                cardPreview.padding()

                HStack(spacing: 16) {
                    Button { renderAndSave() } label: {
                        Label("保存", systemImage: "square.and.arrow.down").frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent).controlSize(.large)
                    Button { renderAndShare() } label: {
                        Label("シェア", systemImage: "square.and.arrow.up").frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered).controlSize(.large)
                }

                if let message = viewModel.savedMessage {
                    Text(message).foregroundStyle(.green).font(.caption)
                }
            }
            .padding()
        }
        .navigationTitle("フォトカード")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showShareSheet) {
            if let image = renderedImage {
                ShareSheet(items: [image])
            }
        }
    }

    @ViewBuilder
    private var cardPreview: some View {
        let bgColor: Color = switch viewModel.selectedTemplate {
        case .natural: .white
        case .modern: Color(.systemGray6)
        case .dark: .black
        }
        let textColor: Color = viewModel.selectedTemplate == .dark ? .white : .primary

        VStack(spacing: 0) {
            AsyncImage(url: URL(string: viewModel.photoUrl)) { image in
                image.resizable().scaledToFill()
            } placeholder: { Color.gray.opacity(0.3) }
            .frame(height: 280).clipped()

            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.birdName).font(.title2.bold()).foregroundStyle(textColor)
                if let sci = viewModel.scientificName {
                    Text(sci).font(.caption).italic().foregroundStyle(textColor.opacity(0.7))
                }
                HStack {
                    if let loc = viewModel.locationName { Label(loc, systemImage: "mappin") }
                    Spacer()
                    Text(viewModel.takenAt.prefix(10))
                }
                .font(.caption).foregroundStyle(textColor.opacity(0.6))
                Text("by \(viewModel.username)").font(.caption2).foregroundStyle(textColor.opacity(0.5))
            }
            .padding(12)
        }
        .background(bgColor)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(radius: 4)
    }

    @MainActor
    private func renderCard() -> UIImage? {
        let renderer = ImageRenderer(content: cardPreview.frame(width: 350))
        renderer.scale = UIScreen.main.scale
        return renderer.uiImage
    }

    private func renderAndSave() {
        guard let image = renderCard() else { return }
        renderedImage = image
        viewModel.saveToPhotoLibrary(renderedImage: image)
    }

    private func renderAndShare() {
        guard let image = renderCard() else { return }
        renderedImage = image
        showShareSheet = true
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
