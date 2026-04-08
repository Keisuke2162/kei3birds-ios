import SwiftUI

struct BirdCardView: View {
    let name: String
    let photoURL: String?
    let isCaptured: Bool

    var body: some View {
        VStack(spacing: 4) {
            if isCaptured, let urlString = photoURL, let url = URL(string: urlString) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFill()
                    case .failure:
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.red.opacity(0.2))
                            .overlay {
                                Image(systemName: "exclamationmark.triangle")
                                    .foregroundStyle(.red)
                            }
                    case .empty:
                        ProgressView()
                    @unknown default:
                        Color.gray.opacity(0.3)
                    }
                }
                .frame(width: 110, height: 110)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.systemGray5))
                    .frame(width: 110, height: 110)
                    .overlay {
                        Image(systemName: "bird").font(.title).foregroundStyle(.gray)
                    }
            }
            Text(name).font(.caption2).lineLimit(1)
                .foregroundStyle(isCaptured ? .primary : .secondary)
        }
    }
}
