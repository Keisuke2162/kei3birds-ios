import Foundation
import Domain

struct BirdDTO: Codable, Sendable {
    let id: Int
    let name_ja: String
    let name_en: String
    let scientific_name: String
    let family: String
    let order_name: String

    func toDomain() -> Bird {
        Bird(id: id, nameJa: name_ja, nameEn: name_en, scientificName: scientific_name, family: family, orderName: order_name)
    }
}
