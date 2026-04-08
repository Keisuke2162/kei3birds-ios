import Foundation
import Domain

struct ObservationDTO: Codable, Sendable {
    let id: String
    let user_id: String?
    let species_id: Int?
    let photo_url: String
    let taken_at: String
    let lat: Double?
    let lng: Double?
    let location_name: String?
    let ai_candidates: [AICandidateDTO]?
    let notes: String?

    func toDomain() -> BirdObservation {
        BirdObservation(
            id: id,
            userId: user_id,
            speciesId: species_id,
            photoUrl: photo_url,
            takenAt: taken_at,
            lat: lat,
            lng: lng,
            locationName: location_name,
            aiCandidates: ai_candidates?.map { $0.toDomain() },
            notes: notes
        )
    }
}

struct AICandidateDTO: Codable, Sendable {
    let species_id: Int?
    let name_ja: String
    let scientific_name: String
    let confidence: Double

    func toDomain() -> AICandidate {
        AICandidate(speciesId: species_id, nameJa: name_ja, scientificName: scientific_name, confidence: confidence)
    }
}

struct CreateObservationRequestDTO: Codable, Sendable {
    let species_id: Int?
    let photo_url: String
    let taken_at: String
    let lat: Double
    let lng: Double
    let location_name: String
    let notes: String?

    init(from input: CreateObservationInput) {
        self.species_id = input.speciesId
        self.photo_url = input.photoUrl
        self.taken_at = input.takenAt
        self.lat = input.lat
        self.lng = input.lng
        self.location_name = input.locationName
        self.notes = input.notes
    }
}
