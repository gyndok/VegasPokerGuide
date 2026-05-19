import SwiftUI

struct DayHeader: View {
    let date: Date
    private static let fmt: DateFormatter = {
        let f = DateFormatter()
        f.timeZone = TimeZone(identifier: "America/Los_Angeles")
        f.dateFormat = "EEE d MMM"
        return f
    }()
    var body: some View {
        let isToday = Calendar.current.isDateInToday(date)
        let isTomorrow = Calendar.current.isDateInTomorrow(date)
        HStack {
            Text(Self.fmt.string(from: date))
                .font(.headline)
            if isToday { Text("· Today").foregroundStyle(.secondary).font(.subheadline) }
            else if isTomorrow { Text("· Tomorrow").foregroundStyle(.secondary).font(.subheadline) }
            Spacer()
        }
        .padding(.vertical, 6)
    }
}
