import Foundation

public enum ObservationEndpoint: APIEndpoint {
    case fetchAll(speciesId: Int?)
    case fetch(id: String)
    case create(body: Data)
    case delete(id: String)

    public var baseURL: URL { apiBaseURL }

    public var path: String {
        switch self {
        case .fetchAll: return "/observations"
        case .fetch(let id): return "/observations/\(id)"
        case .create: return "/observations"
        case .delete(let id): return "/observations/\(id)"
        }
    }

    public var method: HTTPMethod {
        switch self {
        case .fetchAll, .fetch: return .get
        case .create: return .post
        case .delete: return .delete
        }
    }

    public var headers: [String: String] {
        switch self {
        case .create: return ["Content-Type": "application/json"]
        default: return [:]
        }
    }

    public var body: Data? {
        switch self {
        case .create(let body): return body
        default: return nil
        }
    }

    public var queryItems: [URLQueryItem]? {
        switch self {
        case .fetchAll(let speciesId):
            guard let speciesId else { return nil }
            return [URLQueryItem(name: "species_id", value: "\(speciesId)")]
        default: return nil
        }
    }
}
