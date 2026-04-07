import Foundation

public enum UploadEndpoint: APIEndpoint {
    case photo
    case identify

    public var baseURL: URL { apiBaseURL }

    public var path: String {
        switch self {
        case .photo: return "/upload/photo"
        case .identify: return "/upload/identify"
        }
    }

    public var method: HTTPMethod { .post }
}
