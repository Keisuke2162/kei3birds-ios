import Foundation

public final class APIClient: Sendable {
    private let session: URLSession
    private let decoder: JSONDecoder

    public init(session: URLSession = .shared) {
        self.session = session
        self.decoder = JSONDecoder()
    }

    public func request<T: Decodable & Sendable>(_ endpoint: APIEndpoint, accessToken: String? = nil) async throws -> T {
        guard let request = endpoint.urlRequest(accessToken: accessToken) else {
            throw AppError.invalidURL
        }

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw AppError.networkError("Invalid response")
        }

        if httpResponse.statusCode == 401 {
            throw AppError.unauthorized
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw AppError.serverError(statusCode: httpResponse.statusCode)
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch let error as DecodingError {
            throw AppError.decodingFailed(error.localizedDescription)
        }
    }

    public func requestVoid(_ endpoint: APIEndpoint, accessToken: String? = nil) async throws {
        guard let request = endpoint.urlRequest(accessToken: accessToken) else {
            throw AppError.invalidURL
        }

        let (_, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw AppError.networkError("Invalid response")
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw AppError.serverError(statusCode: httpResponse.statusCode)
        }
    }

    public func upload<T: Decodable & Sendable>(_ endpoint: APIEndpoint, imageData: Data, filename: String, accessToken: String? = nil) async throws -> T {
        guard var request = endpoint.urlRequest(accessToken: accessToken) else {
            throw AppError.invalidURL
        }

        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            let code = (response as? HTTPURLResponse)?.statusCode ?? -1
            throw AppError.serverError(statusCode: code)
        }

        return try decoder.decode(T.self, from: data)
    }
}
