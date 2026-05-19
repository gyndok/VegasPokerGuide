import Foundation

struct ReEntry: Codable, Hashable {
    enum Kind: String, Codable {
        case unlimited, limited, perFlight = "per_flight", singleEntry = "single_entry", unknown
    }
    let type: Kind
    let count: Int?
    let raw: String
}
