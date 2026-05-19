import Foundation

enum FeedFetchResult {
    case notModified
    case updated(Data, etag: String?)
}

final class FeedClient {
    private let session: URLSession
    init(session: URLSession = .shared) { self.session = session }

    func fetch(_ url: URL, ifNoneMatch etag: String?) async throws -> FeedFetchResult {
        var req = URLRequest(url: url)
        if let etag { req.setValue(etag, forHTTPHeaderField: "If-None-Match") }
        let (data, response) = try await session.data(for: req)
        guard let http = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        if http.statusCode == 304 { return .notModified }
        guard 200..<300 ~= http.statusCode else {
            throw URLError(.init(rawValue: http.statusCode))
        }
        let newETag = http.value(forHTTPHeaderField: "ETag")
        return .updated(data, etag: newETag)
    }
}
