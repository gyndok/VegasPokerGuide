import SwiftUI

/// Replaces the stock sticky section header with display-font date + foil hairline beneath.
struct AppDayHeader: View {
    let date: Date

    private static let dateFmt: DateFormatter = {
        let f = DateFormatter()
        f.timeZone = TimeZone(identifier: "America/Los_Angeles")
        f.dateFormat = "EEE d MMM"
        return f
    }()

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            HStack(alignment: .firstTextBaseline, spacing: AppSpacing.s) {
                Text(Self.dateFmt.string(from: date))
                    .font(AppFont.dayHeader)
                    .foregroundStyle(AppColor.Text.primary)
                if let suffix = relativeLabel(for: date) {
                    Text(suffix)
                        .font(AppFont.sectionLabel)
                        .tracking(1.2)
                        .foregroundStyle(AppColor.Foil.bright)
                }
                Spacer()
            }
            .padding(.top, AppSpacing.s)
            .padding(.bottom, AppSpacing.xs)
            AppHairline.divider(opacity: 0.6)
        }
    }

    private func relativeLabel(for date: Date) -> String? {
        if Calendar.current.isDateInToday(date) { return "TODAY" }
        if Calendar.current.isDateInTomorrow(date) { return "TOMORROW" }
        return nil
    }
}

#Preview("AppDayHeader") {
    let cal = Calendar.current
    let today = cal.startOfDay(for: Date())
    let tomorrow = cal.date(byAdding: .day, value: 1, to: today)!
    let later = cal.date(byAdding: .day, value: 4, to: today)!

    func headers() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            AppDayHeader(date: today)
            AppDayHeader(date: tomorrow)
            AppDayHeader(date: later)
        }
        .padding(.horizontal, 16)
    }
    return VStack(spacing: 24) {
        VStack { Text("Light").font(.caption); headers() }
            .padding(.vertical).background(AppColor.Paper.cream).environment(\.colorScheme, .light)
        VStack { Text("Dark").font(.caption); headers() }
            .padding(.vertical).background(AppColor.Rail.true).environment(\.colorScheme, .dark)
    }
}
