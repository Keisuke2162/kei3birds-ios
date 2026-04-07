import SwiftUI

struct BirdPinView: View {
    let color: Color

    var body: some View {
        Image(systemName: "mappin.circle.fill")
            .font(.title2)
            .foregroundStyle(color)
            .background(Circle().fill(.white).frame(width: 20, height: 20))
    }
}
