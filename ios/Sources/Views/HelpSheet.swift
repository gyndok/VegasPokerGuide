import SwiftUI

struct HelpSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            AppSheetHeader(title: "How to use", onDismiss: { dismiss() })

            ScrollView {
                VStack(spacing: AppSpacing.l) {
                    scheduleTabCard
                    eventDetailCard
                    myScheduleCard
                    playedCard
                    notificationsCard
                    dataCard
                }
                .padding(AppSpacing.l)
            }
            .background(AppColor.appBackground)
        }
        .background(AppColor.appBackground.ignoresSafeArea())
    }

    // MARK: - Section cards

    private var scheduleTabCard: some View {
        helpCard(icon: "list.bullet.rectangle", title: "SCHEDULE TAB") {
            bullet("Lists every tournament across all eight Vegas venues, grouped by day. Today auto-scrolls to the top on open.")
            bullet("Tap any row to open Event Detail.")
            bullet("Pull down to refresh from the latest pipeline run.")
            bullet("Search by event name, venue, or game (e.g., \"bounty\", \"plo\", \"wynn\").")
            bullet("The colored dot beside each buy-in mirrors standard poker-chip denominations: white < $5, red $5–24, green $25–99, black $100–499, purple $500–999, gold $1K–$5K, platinum $5K+.")
            bullet("Live late-reg countdown badge appears only on events running NOW — today in Pacific time, after the start time has passed.")
        }
    }

    private var eventDetailCard: some View {
        helpCard(icon: "doc.text.image", title: "EVENT DETAIL") {
            bullet("Tap the star (top right) to add to My Schedule AND schedule a notification 30 min before late reg closes. The \"NOTIFY 30 MIN BEFORE LR\" button does the exact same thing — both are wired to the same action.")
            bullet("Open Structure Sheet opens the venue's official PDF of blind structure + payouts.")
            bullet("Directions launches Apple Maps to the venue's address.")
            bullet("Add to Calendar writes the event to your iOS Calendar with the start time and late-reg-close as the start/end.")
            bullet("Notes auto-save on every keystroke.")
            bullet("Played Log section: toggle \"I played this\", then enter Entries (number of bullets — re-entries count), Cashed amount, and optionally Hours Played. Hours is used to compute hourly rate in the Played tab.")
        }
    }

    private var myScheduleCard: some View {
        helpCard(icon: "star.square.fill", title: "MY TABLE") {
            bullet("Shows only events you've starred. Auto-grouped by day.")
            bullet("Summary at the top totals your committed buy-in across every starred event.")
            bullet("Conflict banner appears when any two starred events overlap in their start → late-reg-close window. Use it to spot scheduling collisions before they bite.")
            bullet("Tap a row to re-open Event Detail.")
        }
    }

    private var playedCard: some View {
        helpCard(icon: "checkmark.rectangle.stack", title: "PLAYED") {
            bullet("Summary grid totals across every record you've logged: ENTRIES (total bullets fired across all tournaments), $ IN (buy-in × entries), $ OUT (total cashed), NET, ROI, HOURLY rate.")
            bullet("ROI and HOURLY only compute when $ IN > 0 and HOURS > 0; otherwise they show \"—\".")
            bullet("Each row shows the event name, date, total cost with a (2×) suffix when you fired multiple bullets, total cashed, and hours played if recorded.")
            bullet("Swipe left on any row: red Delete or foil Edit. Edit re-opens that tournament's Event Detail so you can adjust entries/cashed/hours.")
        }
    }

    private var notificationsCard: some View {
        helpCard(icon: "bell.badge", title: "NOTIFICATIONS") {
            bullet("Permission is requested on first launch. If you denied it, re-enable in iOS Settings → Notifications → Kenny's List.")
            bullet("Each starred event schedules one local notification, 30 min before late registration closes (Pacific time).")
            bullet("If the source schedule shifts an event's time, the next pipeline refresh rebuilds notifications automatically.")
            bullet("Un-star an event and its notification cancels.")
        }
    }

    private var dataCard: some View {
        helpCard(icon: "arrow.triangle.2.circlepath", title: "DATA & REFRESH") {
            bullet("Tournament data comes from a public Google Sheet maintained by SpaceyFCB. Their full credits + tip link are in this Settings sheet.")
            bullet("A GitHub Actions pipeline fetches + parses the sheet every 2 hours and publishes a JSON feed. The app reads that JSON.")
            bullet("Pull-to-refresh on the Schedule tab fetches the latest published JSON; Settings → Refresh now does the same.")
            bullet("Last updated timestamp shows when the app last successfully fetched.")
            bullet("Data warnings tell you when the sheet's format has drifted and some rows failed to parse cleanly.")
        }
    }

    // MARK: - Helpers

    private func helpCard<Content: View>(icon: String, title: String, @ViewBuilder _ content: () -> Content) -> some View {
        SectionCard {
            VStack(alignment: .leading, spacing: AppSpacing.s) {
                HStack(spacing: AppSpacing.s) {
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(AppColor.Foil.bright)
                    Text(title)
                        .font(AppFont.sectionLabel)
                        .tracking(1.4)
                        .foregroundStyle(AppColor.Text.secondary)
                }
                AppHairline.divider(opacity: 0.4)
                content()
            }
        }
    }

    private func bullet(_ text: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: AppSpacing.s) {
            Circle()
                .fill(AppColor.Foil.bright)
                .frame(width: 4, height: 4)
                .padding(.top, 7)
            Text(text)
                .font(AppFont.bodyCopy)
                .foregroundStyle(AppColor.Text.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview("HelpSheet — Dark") {
    HelpSheet()
        .environment(\.colorScheme, .dark)
}

#Preview("HelpSheet — Light") {
    HelpSheet()
        .environment(\.colorScheme, .light)
}
