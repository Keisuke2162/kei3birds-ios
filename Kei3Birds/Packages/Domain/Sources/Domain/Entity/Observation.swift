import Foundation

public struct BirdObservation: Sendable, Identifiable, Hashable {
    public static func == (lhs: BirdObservation, rhs: BirdObservation) -> Bool { lhs.id == rhs.id }
    public func hash(into hasher: inout Hasher) { hasher.combine(id) }
    public let id: String
    public let userId: String?
    public let speciesId: Int?
    public let aiSpeciesId: Int?
    public let nameJa: String?
    public let scientificName: String?
    public let photoUrl: String
    public let takenAt: String
    public let lat: Double?
    public let lng: Double?
    public let locationName: String?
    public let aiCandidates: [AICandidate]?
    public let notes: String?

    public init(id: String, userId: String?, speciesId: Int?, aiSpeciesId: Int?, nameJa: String?, scientificName: String?, photoUrl: String, takenAt: String, lat: Double?, lng: Double?, locationName: String?, aiCandidates: [AICandidate]?, notes: String?) {
        self.id = id
        self.userId = userId
        self.speciesId = speciesId
        self.aiSpeciesId = aiSpeciesId
        self.nameJa = nameJa
        self.scientificName = scientificName
        self.photoUrl = photoUrl
        self.takenAt = takenAt
        self.lat = lat
        self.lng = lng
        self.locationName = locationName
        self.aiCandidates = aiCandidates
        self.notes = notes
    }
}

public struct CreateObservationInput: Sendable {
    public let speciesId: Int?
    public let aiSpeciesId: Int?
    public let nameJa: String?
    public let scientificName: String?
    public let photoUrl: String
    public let takenAt: String
    public let lat: Double
    public let lng: Double
    public let locationName: String
    public let notes: String?

    public init(speciesId: Int?, aiSpeciesId: Int?, nameJa: String?, scientificName: String?, photoUrl: String, takenAt: String, lat: Double, lng: Double, locationName: String, notes: String?) {
        self.speciesId = speciesId
        self.aiSpeciesId = aiSpeciesId
        self.nameJa = nameJa
        self.scientificName = scientificName
        self.photoUrl = photoUrl
        self.takenAt = takenAt
        self.lat = lat
        self.lng = lng
        self.locationName = locationName
        self.notes = notes
    }
}

public struct AICandidate: Sendable, Identifiable {
    public var id: String { "\(nameJa)-\(confidence)" }
    public let speciesId: Int?
    public let aiSpeciesId: Int?
    public let nameJa: String
    public let scientificName: String
    public let confidence: Double

    public init(speciesId: Int?, aiSpeciesId: Int?, nameJa: String, scientificName: String, confidence: Double) {
        self.speciesId = speciesId
        self.aiSpeciesId = aiSpeciesId
        self.nameJa = nameJa
        self.scientificName = scientificName
        self.confidence = confidence
    }
}

public struct IdentifyResult: Sendable {
    public let identified: Bool
    public let candidates: [AICandidate]

    public init(identified: Bool, candidates: [AICandidate]) {
        self.identified = identified
        self.candidates = candidates
    }
}
