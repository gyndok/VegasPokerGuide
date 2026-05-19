import Foundation

struct TournamentsFeed: Codable {
    let generatedAt: Date?
    let sourceSheetUpdatedAt: Date?
    let tournaments: [Tournament]

    enum CodingKeys: String, CodingKey {
        case generatedAt = "generated_at"
        case sourceSheetUpdatedAt = "source_sheet_updated_at"
        case tournaments
    }
}

struct VenuesFeed: Codable {
    let venues: [Venue]
}
