import Foundation

enum ReEntryFormatter {
    static func format(_ r: ReEntry) -> String {
        switch r.type {
        case .unlimited: return "Unlimited re-entries"
        case .singleEntry: return "Single entry"
        case .limited:
            let n = r.count ?? 1
            return n == 1 ? "1 re-entry" : "\(n) re-entries"
        case .perFlight:
            let n = r.count ?? 1
            if r.raw.lowercased().contains("e/fl") {
                return "\(n) entry per flight"
            }
            return n == 1 ? "1 re-entry per flight" : "\(n) re-entries per flight"
        case .unknown:
            return r.raw.isEmpty ? "—" : r.raw
        }
    }
}
