import Foundation

public enum MapEndpoint: APIEndpoint {
    case gbif(lat: Double, lng: Double, radiusKm: Int, speciesId: Int?, season: String?)
    case my

    public var baseURL: URL { apiBaseURL }

    public var path: String {
        switch self {
        case .gbif: return "/map/gbif"
        case .my: return "/map/my"
        }
    }

    public var method: HTTPMethod { .get }

    public var queryItems: [URLQueryItem]? {
        switch self {
        case .gbif(let lat, let lng, let radiusKm, let speciesId, let season):
            var items: [URLQueryItem] = [
                URLQueryItem(name: "lat", value: "\(lat)"),
                URLQueryItem(name: "lng", value: "\(lng)"),
                URLQueryItem(name: "radius_km", value: "\(radiusKm)")
            ]
            if let speciesId { items.append(URLQueryItem(name: "species_id", value: "\(speciesId)")) }
            if let season { items.append(URLQueryItem(name: "season", value: season)) }
            return items
        case .my:
            return nil
        }
    }
}
