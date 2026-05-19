import Foundation

enum ConflictDetector {
    /// Returns pairs of (id, id) for tournaments whose [start, lateRegClose] intervals overlap.
    static func findConflicts(in tournaments: [Tournament]) -> [(String, String)] {
        var conflicts: [(String, String)] = []
        let withTimes = tournaments.compactMap { t -> (Tournament, Date, Date)? in
            guard let s = t.startAtPT, let e = t.lateRegCloseAtPT else { return nil }
            return (t, s, e)
        }
        for i in 0..<withTimes.count {
            for j in (i + 1)..<withTimes.count {
                let (a, aStart, aEnd) = withTimes[i]
                let (b, bStart, bEnd) = withTimes[j]
                if aStart < bEnd && bStart < aEnd {
                    conflicts.append((a.id, b.id))
                }
            }
        }
        return conflicts
    }
}
