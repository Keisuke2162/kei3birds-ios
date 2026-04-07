import Foundation
import UIKit
import Photos

enum CardTemplate: String, CaseIterable, Identifiable {
    case natural = "ナチュラル"
    case modern = "モダン"
    case dark = "ダーク"

    var id: String { rawValue }
}

@Observable
@MainActor
final class PhotoCardViewModel {
    var selectedTemplate: CardTemplate = .natural
    var isSaving = false
    var savedMessage: String?

    let photoUrl: String
    let birdName: String
    let scientificName: String?
    let takenAt: String
    let locationName: String?
    let username: String

    init(photoUrl: String, birdName: String, scientificName: String?, takenAt: String, locationName: String?, username: String) {
        self.photoUrl = photoUrl
        self.birdName = birdName
        self.scientificName = scientificName
        self.takenAt = takenAt
        self.locationName = locationName
        self.username = username
    }

    func saveToPhotoLibrary(renderedImage: UIImage) {
        isSaving = true
        PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
            guard status == .authorized else {
                Task { @MainActor in
                    self.isSaving = false
                    self.savedMessage = "写真ライブラリへのアクセスが許可されていません"
                }
                return
            }
            UIImageWriteToSavedPhotosAlbum(renderedImage, nil, nil, nil)
            Task { @MainActor in
                self.isSaving = false
                self.savedMessage = "カメラロールに保存しました"
            }
        }
    }
}
