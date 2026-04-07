import Foundation

let apiBaseURL = URL(string: "https://kei3birds-api-production.up.railway.app")!

public enum BirdEndpoint: APIEndpoint {
    case fetchAll(search: String?)
    case fetch(id: Int)

    public var baseURL: URL { apiBaseURL }

    public var path: String {
        switch self {
        case .fetchAll: return "/birds"
        case .fetch(let id): return "/birds/\(id)"
        }
    }

    public var method: HTTPMethod { .get }

    public var queryItems: [URLQueryItem]? {
        switch self {
        case .fetchAll(let search):
            guard let search, !search.isEmpty else { return nil }
            return [URLQueryItem(name: "search", value: search)]
        case .fetch:
            return nil
        }
    }
}
