import Foundation

struct Tournament: Codable, Identifiable, Hashable {
    let id: String
    let venue: String           // slug
    let datePT: Date            // calendar date in Pacific (decoded as YYYY-MM-DD)
    let startAtPT: Date?
    let lateRegCloseAtPT: Date?
    let game: String
    let gameCategory: GameCategory
    let eventName: String
    let buyInUSD: Int?
    let guaranteeUSD: Int?
    let reEntry: ReEntry
    let isDay2: Bool
    let flightGroup: String
    let structurePDFURL: String?    // per-event PDF; nil falls back to venue URL
    let notes: String?

    enum CodingKeys: String, CodingKey {
        case id, venue
        case datePT = "date_pt"
        case startAtPT = "start_at_pt"
        case lateRegCloseAtPT = "late_reg_close_at_pt"
        case game
        case gameCategory = "game_category"
        case eventName = "event_name"
        case buyInUSD = "buy_in_usd"
        case guaranteeUSD = "guarantee_usd"
        case reEntry = "re_entry"
        case isDay2 = "is_day2"
        case flightGroup = "flight_group"
        case structurePDFURL = "structure_pdf_url"
        case notes
    }
}
