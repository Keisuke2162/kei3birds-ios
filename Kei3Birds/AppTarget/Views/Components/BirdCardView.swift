import SwiftUI

struct BirdCardView: View {
    let name: String
    let photoURL: String?
    let isCaptured: Bool

    var body: some View {
        VStack(spacing: 4) {
            if isCaptured, let urlString = photoURL, let url = URL(string: urlString) {
                CachedAsyncImage(url: url)
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
