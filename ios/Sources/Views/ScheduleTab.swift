import SwiftUI

struct ScheduleTab: View {
    @Environment(AppState.self) private var state
    @State private var showingSettings = false
    @State private var showingFilters = false
    @State private var selected: Tournament? = nil

    var body: some View {
        @Bindable var bindable = state

        NavigationStack {
            List {
                ForEach(grouped(), id: \.0) { day, items in
                    Section(header: DayHeader(date: day)) {
                        ForEach(items) { t in
                            Button {
                                selected = t
                            } label: {
                                EventRow(tournament: t,
                                         venue: state.venue(slug: t.venue),
                                         isStarred: state.isStarred(t.id))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .listStyle(.plain)
            .searchable(text: $bindable.filters.search, prompt: "Search events")
            .refreshable { await state.refresh() }
            .navigationTitle("Schedule")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { showingSettings = true } label: {
                        Image(systemName: "gearshape")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showingFilters = true } label: {
                        Label("Filters (\(state.filters.activeCount))", systemImage: "line.3.horizontal.decrease.circle")
                    }
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsSheet().environment(state)
            }
            .sheet(isPresented: $showingFilters) {
                FiltersSheet().environment(state)
            }
            .sheet(item: $selected) { t in
                EventDetail(tournament: t).environment(state)
            }
        }
    }

    private func grouped() -> [(Date, [Tournament])] {
        let cal = Calendar(identifier: .gregorian)
        var byDay: [Date: [Tournament]] = [:]
        for t in state.filtered() {
            let start = cal.startOfDay(for: t.datePT)
            byDay[start, default: []].append(t)
        }
        return byDay.keys.sorted().map { ($0, byDay[$0]!) }
    }
}
