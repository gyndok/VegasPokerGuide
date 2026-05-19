import Foundation

struct Venue: Codable, Identifiable, Hashable {
    var id: String { slug }
    let slug: String
    let displayName: String
    let seriesName: String
    let seriesDates: String
    let address: String
    let mapsURL: String
    let website: String
    let structurePDFURL: String
    let colorHex: String

    enum CodingKeys: String, CodingKey {
        case slug
        case displayName = "display_name"
        case seriesName = "series_name"
        case seriesDates = "series_dates"
        case address
        case mapsURL = "maps_url"
        case website
        case structurePDFURL = "structure_pdf_url"
        case colorHex = "color_hex"
    }
}
