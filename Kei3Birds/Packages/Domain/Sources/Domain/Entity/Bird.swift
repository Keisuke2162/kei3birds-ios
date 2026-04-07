import Foundation

public struct Bird: Sendable, Identifiable, Hashable {
    public let id: Int
    public let nameJa: String
    public let nameEn: String
    public let scientificName: String
    public let family: String
    public let orderName: String

    public init(id: Int, nameJa: String, nameEn: String, scientificName: String, family: String, orderName: String) {
        self.id = id
        self.nameJa = nameJa
        self.nameEn = nameEn
        self.scientificName = scientificName
        self.family = family
        self.orderName = orderName
    }
}
