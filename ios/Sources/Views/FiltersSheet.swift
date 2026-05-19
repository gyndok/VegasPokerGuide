import SwiftUI

struct FiltersSheet: View {
    @Environment(AppState.self) private var state
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        @Bindable var bindable = state

        NavigationStack {
            Form {
                Section("Date") {
                    Button("Today") { setRange(.today) }
                    Button("Tomorrow") { setRange(.tomorrow) }
                    Button("This Weekend") { setRange(.thisWeekend) }
                    Button("Next 7 Days") { setRange(.next7) }
                    Button("All dates") {
                        bindable.filters.dateStart = nil
                        bindable.filters.dateEnd = nil
                    }
                    if let start = state.filters.dateStart, let end = state.filters.dateEnd {
                        LabeledContent("Range") {
                            Text("\(start.formatted(date: .abbreviated, time: .omitted)) → \(end.formatted(date: .abbreviated, time: .omitted))")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Section("Venues") {
                    ForEach(state.venues) { v in
                        Toggle(v.displayName, isOn: Binding(
                            get: { state.filters.venues.contains(v.slug) },
                            set: { on in
                                if on { bindable.filters.venues.insert(v.slug) }
                                else { bindable.filters.venues.remove(v.slug) }
                            }
                        ))
                    }
                }

                Section("Game") {
                    ForEach(GameCategory.allCases, id: \.self) { c in
                        Toggle(GameCategoryStyle.abbreviation(c), isOn: Binding(
                            get: { state.filters.gameCategories.contains(c) },
                            set: { on in
                                if on { bindable.filters.gameCategories.insert(c) }
                                else { bindable.filters.gameCategories.remove(c) }
                            }
                        ))
                    }
                }

                Section("Buy-in") {
                    HStack {
                        Text("Min")
                        TextField("0", value: $bindable.filters.minBuyIn, format: .number)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("Max")
                        TextField("∞", value: $bindable.filters.maxBuyIn, format: .number)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                }

                Section("Guarantee") {
                    HStack {
                        Text("Min")
                        TextField("0", value: $bindable.filters.minGuarantee, format: .number)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                }

                Section("Re-entry") {
                    ForEach([ReEntry.Kind.unlimited, .limited, .perFlight, .singleEntry], id: \.self) { k in
                        Toggle(k.rawValue.capitalized, isOn: Binding(
                            get: { state.filters.reEntryTypes.contains(k) },
                            set: { on in
                                if on { bindable.filters.reEntryTypes.insert(k) }
                                else { bindable.filters.reEntryTypes.remove(k) }
                            }
                        ))
                    }
                }

                Section("Late registration") {
                    Picker("Status", selection: $bindable.filters.lateRegStatus) {
                        Text("Any").tag(FilterPredicate.LateRegStatus.any)
                        Text("Open now").tag(FilterPredicate.LateRegStatus.openNow)
                        Text("Closing within 2hr").tag(FilterPredicate.LateRegStatus.closingSoon)
                        Text("Closed").tag(FilterPredicate.LateRegStatus.closed)
                    }
                }

                Section {
                    Toggle("Show Day 2 / final tables", isOn: $bindable.filters.showDay2)
                }

                Section {
                    Button("Reset", role: .destructive) { bindable.filters = FilterPredicate() }
                }
            }
            .navigationTitle("Filters")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private enum DatePreset { case today, tomorrow, thisWeekend, next7 }

    private func setRange(_ preset: DatePreset) {
        @Bindable var bindable = state
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "America/Los_Angeles")!
        let today = cal.startOfDay(for: Date())
        switch preset {
        case .today:
            bindable.filters.dateStart = today
            bindable.filters.dateEnd = today
        case .tomorrow:
            let tomorrow = cal.date(byAdding: .day, value: 1, to: today)!
            bindable.filters.dateStart = tomorrow
            bindable.filters.dateEnd = tomorrow
        case .thisWeekend:
            let weekday = cal.component(.weekday, from: today)  // 1=Sun..7=Sat
            let daysToSaturday = (7 - weekday) % 7
            let saturday = cal.date(byAdding: .day, value: daysToSaturday, to: today)!
            let sunday = cal.date(byAdding: .day, value: 1, to: saturday)!
            bindable.filters.dateStart = saturday
            bindable.filters.dateEnd = sunday
        case .next7:
            bindable.filters.dateStart = today
            bindable.filters.dateEnd = cal.date(byAdding: .day, value: 6, to: today)!
        }
    }
}
