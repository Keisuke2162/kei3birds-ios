import Foundation

public struct GBIFMapPoint: Sendable, Identifiable {
    public var id: String { "\(speciesId)-\(lat)-\(lng)-\(observedAt)" }
    public let speciesId: Int
    public let nameJa: String
    public let lat: Double
    public let lng: Double
    public let observedAt: String

    public init(speciesId: Int, nameJa: String, lat: Double, lng: Double, observedAt: String) {
        self.speciesId = speciesId
        self.nameJa = nameJa
        self.lat = lat
        self.lng = lng
        self.observedAt = observedAt
    }
}

public struct MyMapPoint: Sendable, Identifiable {
    public let id: String
    public let speciesId: Int?
    public let nameJa: String?
    public let photoUrl: String
    public let lat: Double
    public let lng: Double
    public let takenAt: String
    public let locationName: String?

    public init(id: String, speciesId: Int?, nameJa: String?, photoUrl: String, lat: Double, lng: Double, takenAt: String, locationName: String?) {
        self.id = id
        self.speciesId = speciesId
        self.nameJa = nameJa
        self.photoUrl = photoUrl
        self.lat = lat
        self.lng = lng
        self.takenAt = takenAt
        self.locationName = locationName
    }
}
