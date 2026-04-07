import Foundation
import Domain

struct GBIFMapPointDTO: Codable, Sendable {
    let species_id: Int
    let name_ja: String
    let lat: Double
    let lng: Double
    let observed_at: String

    func toDomain() -> GBIFMapPoint {
        GBIFMapPoint(speciesId: species_id, nameJa: name_ja, lat: lat, lng: lng, observedAt: observed_at)
    }
}

struct MyMapPointDTO: Codable, Sendable {
    let id: String
    let species_id: Int?
    let name_ja: String?
    let photo_url: String
    let lat: Double
    let lng: Double
    let taken_at: String
    let location_name: String?

    func toDomain() -> MyMapPoint {
        MyMapPoint(id: id, speciesId: species_id, nameJa: name_ja, photoUrl: photo_url, lat: lat, lng: lng, takenAt: taken_at, locationName: location_name)
    }
}

struct UploadResponseDTO: Codable, Sendable {
    let url: String
}

struct IdentifyResponseDTO: Codable, Sendable {
    let identified: Bool
    let candidates: [AICandidateDTO]

    func toDomain() -> IdentifyResult {
        IdentifyResult(identified: identified, candidates: candidates.map { $0.toDomain() })
    }
}
