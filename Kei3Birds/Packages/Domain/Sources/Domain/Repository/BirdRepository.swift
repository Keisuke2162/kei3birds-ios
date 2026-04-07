public protocol BirdRepository: Sendable {
    func fetchAll(search: String?) async throws -> [Bird]
    func fetch(id: Int) async throws -> Bird
}
