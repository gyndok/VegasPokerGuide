import Foundation

struct FilterPredicate {
    enum LateRegStatus { case any, openNow, closingSoon, closed }

    var search: String = ""
    var dateStart: Date? = nil
    var dateEnd: Date? = nil
    var venues: Set<String> = []
    var minBuyIn: Int? = nil
    var maxBuyIn: Int? = nil
    var minGuarantee: Int? = nil
    var maxGuarantee: Int? = nil
    var gameCategories: Set<GameCategory> = []
    var reEntryTypes: Set<ReEntry.Kind> = []
    var lateRegStatus: LateRegStatus = .any
    var showDay2: Bool = false

    var activeCount: Int {
        var n = 0
        if !search.isEmpty { n += 1 }
        if dateStart != nil || dateEnd != nil { n += 1 }
        if !venues.isEmpty { n += 1 }
        if minBuyIn != nil || maxBuyIn != nil { n += 1 }
        if minGuarantee != nil || maxGuarantee != nil { n += 1 }
        if !gameCategories.isEmpty { n += 1 }
        if !reEntryTypes.isEmpty { n += 1 }
        if lateRegStatus != .any { n += 1 }
        if showDay2 { n += 1 }
        return n
    }

    func apply(to tournaments: [Tournament], now: Date = Date()) -> [Tournament] {
        let q = search.lowercased()
        return tournaments.filter { t in
            if !showDay2 && t.isDay2 { return false }
            if let s = dateStart, t.datePT < s { return false }
            if let e = dateEnd, t.datePT > e { return false }
            if !venues.isEmpty && !venues.contains(t.venue) { return false }
            if let min = minBuyIn, (t.buyInUSD ?? 0) < min { return false }
            if let max = maxBuyIn, (t.buyInUSD ?? Int.max) > max { return false }
            if let min = minGuarantee, (t.guaranteeUSD ?? 0) < min { return false }
            if let max = maxGuarantee, (t.guaranteeUSD ?? Int.max) > max { return false }
            if !gameCategories.isEmpty && !gameCategories.contains(t.gameCategory) { return false }
            if !reEntryTypes.isEmpty && !reEntryTypes.contains(t.reEntry.type) { return false }
            switch lateRegStatus {
            case .any: break
            case .openNow:
                guard let close = t.lateRegCloseAtPT else { return false }
                if close <= now { return false }
            case .closingSoon:
                guard let close = t.lateRegCloseAtPT, close > now else { return false }
                if close.timeIntervalSince(now) > 2 * 3600 { return false }
            case .closed:
                guard let close = t.lateRegCloseAtPT, close <= now else { return false }
            }
            if !q.isEmpty {
                let hay = (t.eventName + " " + t.venue + " " + t.game).lowercased()
                if !hay.contains(q) { return false }
            }
            return true
        }
    }
}
