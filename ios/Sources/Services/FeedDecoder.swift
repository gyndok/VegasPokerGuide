import Foundation

enum FeedDecoder {
    static func make() -> JSONDecoder {
        let decoder = JSONDecoder()
        let isoFull = ISO8601DateFormatter()
        isoFull.formatOptions = [.withInternetDateTime]
        let isoFractional = ISO8601DateFormatter()
        isoFractional.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let dateOnly = DateFormatter()
        dateOnly.calendar = Calendar(identifier: .gregorian)
        dateOnly.timeZone = TimeZone(identifier: "America/Los_Angeles")
        dateOnly.dateFormat = "yyyy-MM-dd"

        decoder.dateDecodingStrategy = .custom { d in
            let container = try d.singleValueContainer()
            let s = try container.decode(String.self)
            if let date = dateOnly.date(from: s) { return date }
            if let date = isoFull.date(from: s) { return date }
            if let date = isoFractional.date(from: s) { return date }
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Unrecognized date format: \(s)"
            )
        }
        return decoder
    }
}
