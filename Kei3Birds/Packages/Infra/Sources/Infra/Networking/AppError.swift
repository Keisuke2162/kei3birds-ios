import Foundation

public enum AppError: LocalizedError, Sendable {
    case invalidURL
    case serverError(statusCode: Int)
    case decodingFailed(String)
    case networkError(String)
    case unauthorized
    case underlying(String)

    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "無効なURLです"
        case .serverError(let statusCode):
            return "サーバーエラー（\(statusCode)）"
        case .decodingFailed(let detail):
            return "デコード失敗: \(detail)"
        case .networkError(let detail):
            return "ネットワークエラー: \(detail)"
        case .unauthorized:
            return "認証エラー: ログインし直してください"
        case .underlying(let detail):
            return detail
        }
    }
}
