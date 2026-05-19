import SwiftUI

struct FiltersSheet: View {
    @Environment(AppState.self) private var state
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        @Bindable var bindable = state

        NavigationStack {
            Form {
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
}
