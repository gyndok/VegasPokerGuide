import SwiftUI

struct FiltersSheet: View {
    @Environment(AppState.self) private var state
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            AppSheetHeader(title: "Filters", onDismiss: { dismiss() })

            ScrollView {
                VStack(spacing: AppSpacing.l) {
                    dateSection
                    venuesSection
                    gameSection
                    buyInSection
                    guaranteeSection
                    reEntrySection
                    lateRegSection
                    miscSection
                    resetSection
                }
                .padding(AppSpacing.l)
            }
            .background(AppColor.appBackground)
        }
        .background(AppColor.appBackground.ignoresSafeArea())
    }

    // MARK: - Date section

    private var dateSection: some View {
        SectionCard(title: "DATE") {
            VStack(alignment: .leading, spacing: AppSpacing.s) {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: AppSpacing.s) {
                    presetButton("TODAY")        { setRange(.today) }
                    presetButton("TOMORROW")     { setRange(.tomorrow) }
                    presetButton("THIS WEEKEND") { setRange(.thisWeekend) }
                    presetButton("NEXT 7 DAYS")  { setRange(.next7) }
                }
                AppButton("ALL DATES", style: .secondary) {
                    state.filters.dateStart = nil
                    state.filters.dateEnd = nil
                    AppHaptics.filterApplied()
                }
                if let start = state.filters.dateStart, let end = state.filters.dateEnd {
                    HStack {
                        Text("ACTIVE RANGE")
                            .font(AppFont.sectionLabel)
                            .tracking(1.4)
                            .foregroundStyle(AppColor.Text.tertiary)
                        Spacer()
                        Text("\(start.formatted(date: .abbreviated, time: .omitted)) → \(end.formatted(date: .abbreviated, time: .omitted))")
                            .font(AppFont.timestamp)
                            .foregroundStyle(AppColor.Foil.bright)
                    }
                    .padding(.top, AppSpacing.xs)
                }
            }
        }
    }

    // MARK: - Venues section

    private var venuesSection: some View {
        SectionCard(title: "VENUES") {
            VStack(spacing: 0) {
                ForEach(state.venues) { v in
                    AppToggle(
                        title: v.displayName,
                        isOn: Binding(
                            get: { state.filters.venues.contains(v.slug) },
                            set: { on in
                                if on { state.filters.venues.insert(v.slug) }
                                else  { state.filters.venues.remove(v.slug) }
                            }
                        ),
                        accent: AppColor.venueAccent(hex: v.colorHex)
                    )
                }
            }
        }
    }

    // MARK: - Game section

    private var gameSection: some View {
        SectionCard(title: "GAME") {
            VStack(spacing: 0) {
                ForEach(GameCategory.allCases, id: \.self) { c in
                    AppToggle(
                        title: GameCategoryStyle.abbreviation(c),
                        isOn: Binding(
                            get: { state.filters.gameCategories.contains(c) },
                            set: { on in
                                if on { state.filters.gameCategories.insert(c) }
                                else  { state.filters.gameCategories.remove(c) }
                            }
                        ),
                        accent: GameCategoryStyle.color(c)
                    )
                }
            }
        }
    }

    // MARK: - Buy-in section

    private var buyInSection: some View {
        SectionCard(title: "BUY-IN") {
            @Bindable var bindable = state
            VStack(spacing: 0) {
                AppTextField(label: "Min", placeholder: "0", value: $bindable.filters.minBuyIn)
                AppTextField(label: "Max", placeholder: "∞", value: $bindable.filters.maxBuyIn)
            }
        }
    }

    // MARK: - Guarantee section

    private var guaranteeSection: some View {
        SectionCard(title: "GUARANTEE") {
            @Bindable var bindable = state
            AppTextField(label: "Min", placeholder: "0", value: $bindable.filters.minGuarantee)
        }
    }

    // MARK: - Re-entry section

    private var reEntrySection: some View {
        SectionCard(title: "RE-ENTRY") {
            VStack(spacing: 0) {
                ForEach([ReEntry.Kind.unlimited, .limited, .perFlight, .singleEntry], id: \.self) { kind in
                    AppToggle(
                        title: reEntryLabel(kind),
                        isOn: Binding(
                            get: { state.filters.reEntryTypes.contains(kind) },
                            set: { on in
                                if on { state.filters.reEntryTypes.insert(kind) }
                                else  { state.filters.reEntryTypes.remove(kind) }
                            }
                        )
                    )
                }
            }
        }
    }

    // MARK: - Late reg section

    private var lateRegSection: some View {
        SectionCard(title: "LATE REGISTRATION") {
            @Bindable var bindable = state
            AppPicker(options: [
                (FilterPredicate.LateRegStatus.any, "ANY"),
                (.openNow, "OPEN"),
                (.closingSoon, "<2H"),
                (.closed, "CLOSED")
            ], selection: $bindable.filters.lateRegStatus)
        }
    }

    // MARK: - Misc section

    private var miscSection: some View {
        SectionCard {
            @Bindable var bindable = state
            AppToggle(title: "Show Day 2 / final tables", isOn: $bindable.filters.showDay2)
        }
    }

    // MARK: - Reset section

    private var resetSection: some View {
        AppButton("RESET ALL FILTERS", systemImage: "arrow.counterclockwise", style: .destructive) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                state.filters = FilterPredicate()
            }
            AppHaptics.filterApplied()
        }
        .padding(.top, AppSpacing.s)
    }

    // MARK: - Preset chip button

    private func presetButton(_ label: String, action: @escaping () -> Void) -> some View {
        Button(action: {
            action()
            AppHaptics.filterApplied()
        }) {
            Text(label)
                .font(AppFont.sectionLabel)
                .tracking(1.2)
                .foregroundStyle(AppColor.Foil.bright)
                .padding(.horizontal, AppSpacing.m)
                .padding(.vertical, AppSpacing.s)
                .frame(maxWidth: .infinity)
                .background(AppColor.Foil.bright.opacity(0.10), in: Capsule())
                .overlay(Capsule().strokeBorder(AppColor.Foil.bright.opacity(0.5), lineWidth: 0.8))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Date preset logic

    private enum DatePreset { case today, tomorrow, thisWeekend, next7 }

    private func setRange(_ preset: DatePreset) {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "America/Los_Angeles")!
        let today = cal.startOfDay(for: Date())
        switch preset {
        case .today:
            state.filters.dateStart = today
            state.filters.dateEnd = today
        case .tomorrow:
            let tomorrow = cal.date(byAdding: .day, value: 1, to: today)!
            state.filters.dateStart = tomorrow
            state.filters.dateEnd = tomorrow
        case .thisWeekend:
            let weekday = cal.component(.weekday, from: today)  // 1=Sun..7=Sat
            let daysToSaturday = (7 - weekday) % 7
            let saturday = cal.date(byAdding: .day, value: daysToSaturday, to: today)!
            let sunday = cal.date(byAdding: .day, value: 1, to: saturday)!
            state.filters.dateStart = saturday
            state.filters.dateEnd = sunday
        case .next7:
            state.filters.dateStart = today
            state.filters.dateEnd = cal.date(byAdding: .day, value: 6, to: today)!
        }
    }

    private func reEntryLabel(_ kind: ReEntry.Kind) -> String {
        switch kind {
        case .unlimited:   return "Unlimited"
        case .limited:     return "Limited"
        case .perFlight:   return "Per flight"
        case .singleEntry: return "Single entry"
        case .unknown:     return "Unknown"
        }
    }
}
